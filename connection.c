/*-------------------------------------------------------------------------
 *
 * SQLite Foreign Data Wrapper for PostgreSQL
 *
 * Portions Copyright (c) 2018, TOSHIBA CORPORATION
 *
 * IDENTIFICATION
 *        connection.c
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"
#include "sqlite_fdw.h"

#include "access/xact.h"
#include "commands/defrem.h"
#if (PG_VERSION_NUM >= 140000 && PG_VERSION_NUM < 150000)
	#include "miscadmin.h"
#endif
#include "optimizer/cost.h"
#include "utils/builtins.h"
#include "utils/inval.h"
#include "utils/syscache.h"


/*
 * Connection cache hash table entry
 *
 * The lookup key in this hash table is the foreign server OID
 */
typedef Oid ConnCacheKey;

typedef struct ConnCacheEntry
{
	ConnCacheKey key;			/* hash key (must be first) */
	sqlite3	   *conn;			/* connection to foreign server, or NULL */
	/* Remaining fields are invalid when conn is NULL: */
	int			xact_depth;		/* 0 = no xact open, 1 = main xact open, 2 =
								 * one level of subxact open, etc */
	bool		keep_connections;	/* setting value of keep_connections
									 * server option */
	bool		truncatable;	/* check table can truncate or not */
	bool		readonly;		/* option force_readonly, readonly SQLite file mode */
	bool		invalidated;	/* true if reconnect is pending */
	Oid			serverid;		/* foreign server OID used to get server name */
	List	   *stmtList;		/* list stmt associated with conn */
	uint32		server_hashvalue;	/* hash value of foreign server OID */
	uint32		mapping_hashvalue;	/* hash value of user mapping OID */
} ConnCacheEntry;

/*
 * Connection cache (initialized on first use)
 */
static HTAB *ConnectionHash = NULL;

/* tracks whether any work is needed in callback functions */
static volatile bool xact_got_connection = false;

PG_FUNCTION_INFO_V1(sqlite_fdw_get_connections);
PG_FUNCTION_INFO_V1(sqlite_fdw_disconnect);
PG_FUNCTION_INFO_V1(sqlite_fdw_disconnect_all);

static sqlite3 *sqlite_open_db(const char *dbpath, int flags);
static void sqlite_make_new_connection(ConnCacheEntry *entry, ForeignServer *server);
void		sqlite_do_sql_command(sqlite3 * conn, const char *sql, int level, List **busy_connection);
static void sqlite_begin_remote_xact(ConnCacheEntry *entry);
static void sqlitefdw_xact_callback(XactEvent event, void *arg);
static void sqlitefdw_reset_xact_state(ConnCacheEntry *entry, bool toplevel);
static void sqlitefdw_subxact_callback(SubXactEvent event,
									   SubTransactionId mySubid,
									   SubTransactionId parentSubid,
									   void *arg);
static void sqlitefdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue);
static void sqlitefdw_abort_cleanup(ConnCacheEntry *entry, bool toplevel, List **busy_connection);
#if PG_VERSION_NUM >= 140000
static bool sqlite_disconnect_cached_connections(Oid serverid);
#endif
static void sqlite_finalize_list_stmt(List **list);
static List *sqlite_append_stmt_to_list(List *list, sqlite3_stmt * stmt);

typedef struct BusyHandlerArg
{
	sqlite3	   *conn;
	const char *sql;
	int			level;
} BusyHandlerArg;

/*
 * sqlite_get_connection:
 * 			Get a connection which can be used to execute queries on
 * the remote Sqlite server with the user's authorization. A new connection
 * is established if we don't already have a suitable one.
 */
sqlite3 *
sqlite_get_connection(ForeignServer *server, bool truncatable)
{
	bool		found;
	ConnCacheEntry *entry;
	ConnCacheKey key;

	/* First time through, initialize connection cache hashtable */
	if (ConnectionHash == NULL)
	{
		HASHCTL		ctl;

		MemSet(&ctl, 0, sizeof(ctl));
		ctl.keysize = sizeof(ConnCacheKey);
		ctl.entrysize = sizeof(ConnCacheEntry);

		/* allocate ConnectionHash in the cache context */
		ctl.hcxt = CacheMemoryContext;
		ConnectionHash = hash_create("sqlite_fdw connections", 8,
									 &ctl,
#if (PG_VERSION_NUM >= 140000)
									 HASH_ELEM | HASH_BLOBS);
#else
									 HASH_ELEM | HASH_BLOBS | HASH_CONTEXT);
#endif

		/*
		 * Register some callback functions that manage connection cleanup.
		 * This should be done just once in each backend.
		 */
		RegisterXactCallback(sqlitefdw_xact_callback, NULL);
		RegisterSubXactCallback(sqlitefdw_subxact_callback, NULL);
		CacheRegisterSyscacheCallback(FOREIGNSERVEROID,
									  sqlitefdw_inval_callback, (Datum) 0);
	}

	/* Set flag that we did GetConnection during the current transaction */
	xact_got_connection = true;

	key = server->serverid;

	/*
	 * Find or create cached entry for requested connection.
	 */
	entry = hash_search(ConnectionHash, &key, HASH_ENTER, &found);
	if (!found)
	{
		/* If can not find any cached entry => initialize new hashtable entry */
		entry->conn = NULL;
	}

	/*
	 * If the connection needs to be remade due to invalidation, disconnect as
	 * soon as we're out of all transactions.
	 */
	if (entry->conn != NULL && entry->invalidated && entry->xact_depth == 0)
	{
		int			rc = sqlite3_close(entry->conn);

		elog(DEBUG1, "closing connection %p for option changes to take effect. sqlite3_close=%d",
			 entry->conn, rc);
		entry->conn = NULL;
	}

	/*
	 * If cache entry doesn't have a connection, we have to establish a new
	 * connection.  (If sqlite_open_db has an error, the cache entry will
	 * remain in a valid empty state, ie conn == NULL.)
	 */
	if (entry->conn == NULL)
		sqlite_make_new_connection(entry, server);

	entry->truncatable = truncatable;

	/*
	 * SQLite FDW support TRUNCATE command by executing DELETE statement
	 * without WHERE clause. In order to delete records in parent and child
	 * table subsequently, SQLite FDW executes "PRAGMA foreign_keys = ON"
	 * before executing DELETE statement. But "PRAGMA foreign_keys = ON"
	 * command does not have any affect when using within transaction.
	 * Therefore, do not create transaction when executing TRUNCATE.
	 */
	if (!entry->truncatable)

		/*
		 * Start a new transaction or subtransaction if needed.
		 */
		sqlite_begin_remote_xact(entry);

	return entry->conn;
}

/*
 * Open remote sqlite database using specified database path
 * and flags of opened file descriptor mode.
 */
static sqlite3 *
sqlite_open_db(const char *dbpath, int flags)
{
	sqlite3	   *conn = NULL;
	int			rc;
	char	   *err;
	const char *zVfs = NULL;
	rc = sqlite3_open_v2(dbpath, &conn, flags, zVfs);
	if (rc != SQLITE_OK)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
				 errmsg("Failed to open SQLite DB, file '%s', result code %d", dbpath, rc)));
	sqlite3_extended_result_codes(conn, true);
	/* make 'LIKE' of SQLite case sensitive like PostgreSQL */
	rc = sqlite3_exec(conn, "pragma case_sensitive_like=1",
					  NULL, NULL, &err);
	if (rc != SQLITE_OK)
	{
		char	   *perr = pstrdup(err);

		sqlite3_free(err);
		sqlite3_close(conn);
		conn = NULL;
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
				 errmsg("Failed to open SQLite DB, file '%s', SQLite error '%s', result code %d", dbpath, perr, rc)));
	}
	/* add included inner SQLite functions from separate c file
	 * for using in data unifying during deparsing
	 */
	sqlite_fdw_data_norm_functs_init(conn);
	return conn;
}


/*
 * Reset all transient state fields in the cached connection entry and
 * establish new connection to the remote server.
 */
static void
sqlite_make_new_connection(ConnCacheEntry *entry, ForeignServer *server)
{
	const char *dbpath = NULL;
	ListCell   *lc;
	int flags = 0;

	Assert(entry->conn == NULL);

	entry->serverid = server->serverid;
	entry->xact_depth = 0;
	entry->invalidated = false;
	entry->stmtList = NULL;
	entry->keep_connections = true;
	entry->readonly = false;
	entry->server_hashvalue =
		GetSysCacheHashValue1(FOREIGNSERVEROID,
							  ObjectIdGetDatum(server->serverid));
	foreach(lc, server->options)
	{
		DefElem	   *def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, "database") == 0)
			dbpath = defGetString(def);
		else if (strcmp(def->defname, "keep_connections") == 0)
			entry->keep_connections = defGetBoolean(def);
		else if (strcmp(def->defname, "force_readonly") == 0)
			entry->readonly = defGetBoolean(def);
	}

	flags = flags | (entry->readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_READWRITE);
	/* Try to make the connection */
	entry->conn = sqlite_open_db(dbpath, flags);
}

/*
 * cleanup_connection:
 * Delete all the cache entries on backend exists.
 */
void
sqlite_cleanup_connection(void)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	int			rc;

	if (ConnectionHash == NULL)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		if (entry->conn == NULL)
			continue;

		sqlite_finalize_list_stmt(&entry->stmtList);

		elog(DEBUG1, "disconnecting sqlite_fdw connection %p", entry->conn);
		rc = sqlite3_close(entry->conn);
		entry->conn = NULL;
		if (rc != SQLITE_OK)
		{
			ereport(ERROR,
					(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
					 errmsg("Failed to close SQLite DB"),
					 errhint("SQLite error '%s', SQLite result code %d", sqlite3_errmsg(entry->conn), rc)
					));
		}
	}
}

/*
 * Convenience subroutine to issue a non-data-returning SQL command to remote
 */
void
sqlite_do_sql_command(sqlite3 * conn, const char *sql, int level, List **busy_connection)
{
	char	   *err = NULL;
	int			rc;

	elog(DEBUG3, "sqlite_fdw do_sql_command %s", sql);

	rc = sqlite3_exec(conn, sql, NULL, NULL, &err);

	if (busy_connection && rc == SQLITE_BUSY)
	{
		/* Busy case will be handled later, not here */
		BusyHandlerArg *arg = palloc0(sizeof(BusyHandlerArg));

		arg->conn = conn;
		arg->sql = sql;
		arg->level = level;
		*busy_connection = lappend(*busy_connection, arg);

		return;
	}

	if (rc != SQLITE_OK)
	{
		char	   *perr = NULL;

		if (err)
		{
			perr = pstrdup(err);
			sqlite3_free(err);

			if (perr)
			{
				ereport(level,
						(errcode(ERRCODE_FDW_ERROR),
						 errmsg("SQLite failed to execute a query"),
						 errcontext("SQL query: %s", sql),
						 errhint("SQLite error '%s'", perr)));

				pfree(perr);
			}
		}
		else
			ereport(level,
					(errcode(ERRCODE_FDW_ERROR),
					 errmsg("SQLite failed to execute a query"),
					 errcontext("SQL query: %s", sql)
					 ));
	}
}

/*
 * Start remote transaction or subtransaction, if needed.
 */
static void
sqlite_begin_remote_xact(ConnCacheEntry *entry)
{
	int			curlevel = GetCurrentTransactionNestLevel();

	/* Start main transaction if we haven't yet */
	if (entry->xact_depth <= 0)
	{
		const char *sql;

		elog(DEBUG3, "starting remote transaction on connection %p",
			 entry->conn);

		sql = "BEGIN";

		sqlite_do_sql_command(entry->conn, sql, ERROR, NULL);
		entry->xact_depth = 1;

	}

	/*
	 * If we're in a subtransaction, stack up savepoints to match our level.
	 * This ensures we can rollback just the desired effects when a
	 * subtransaction aborts.
	 */
	while (entry->xact_depth < curlevel)
	{
		char		sql[64];

		snprintf(sql, sizeof(sql), "SAVEPOINT s%d", entry->xact_depth + 1);
		sqlite_do_sql_command(entry->conn, sql, ERROR, NULL);
		entry->xact_depth++;
	}
}


/*
 * Report an sqlite execution error
 */
void
sqlitefdw_report_error(int elevel, sqlite3_stmt * stmt, sqlite3 * conn,
					   const char *sql, int rc)
{
	const char *message = sqlite3_errmsg(conn);
	int			sqlstate = ERRCODE_FDW_ERROR;

	/* copy sql before callling another SQLite API */
	if (message)
		message = pstrdup(message);

	if (!sql && stmt)
	{
		sql = sqlite3_sql(stmt);
		if (sql)
			sql = pstrdup(sqlite3_sql(stmt));
	}
	ereport(ERROR,
			(errcode(sqlstate),
			 errmsg("Failed to execute remote SQL"),
			 errcontext("SQL query: %s", sql ? sql : ""),
			 errhint("SQLite error '%s', SQLite result code %d", message ? message : "", rc)
			));
}


/*
 * sqlitefdw_xact_callback --- cleanup at main-transaction end.
 */
static void
sqlitefdw_xact_callback(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	ListCell *lc;
	List *busy_connection = NIL;

	/* Quick exit if no connections were touched in this transaction. */
	if (!xact_got_connection)
		return;

	elog(DEBUG1, "sqlite_fdw xact_callback %d", event);

	/*
	 * Scan all connection cache entries to find open remote transactions, and
	 * close them.
	 */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		/* Ignore cache entry if no open connection right now */
		if (entry->conn == NULL)
			continue;

		/* If it has an open remote transaction, try to close it */
		if (entry->xact_depth > 0)
		{
			elog(DEBUG3, "closing remote transaction on connection %p",
				 entry->conn);

			switch (event)
			{
				case XACT_EVENT_PARALLEL_PRE_COMMIT:
				case XACT_EVENT_PRE_COMMIT:

					/* Commit all remote transactions during pre-commit */
					if (!sqlite3_get_autocommit(entry->conn))
						sqlite_do_sql_command(entry->conn, "COMMIT", ERROR, &busy_connection);
					/* Finalize all prepared statements */
					sqlite_finalize_list_stmt(&entry->stmtList);
					break;
				case XACT_EVENT_PRE_PREPARE:

					/*
					 * We disallow remote transactions that modified anything,
					 * since it's not very reasonable to hold them open until
					 * the prepared transaction is committed.  For the moment,
					 * throw error unconditionally; later we might allow
					 * read-only cases.  Note that the error will cause us to
					 * come right back here with event == XACT_EVENT_ABORT, so
					 * we'll clean up the connection state at that point.
					 */
					ereport(ERROR,
							(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
							 errmsg("cannot prepare a transaction that modified remote tables")));
					break;
				case XACT_EVENT_PARALLEL_COMMIT:
				case XACT_EVENT_COMMIT:
				case XACT_EVENT_PREPARE:
					/* Pre-commit should have closed the open transaction */
					elog(ERROR, "missed cleaning up connection during pre-commit");
					break;
				case XACT_EVENT_PARALLEL_ABORT:
				case XACT_EVENT_ABORT:
					{
						sqlitefdw_abort_cleanup(entry, true, &busy_connection);
						break;
					}
			}
		}

		/* Reset state to show we're out of a transaction */
		sqlitefdw_reset_xact_state(entry, true);
	}

	/* Execute again the query after server is available */
	foreach(lc, busy_connection)
	{
		BusyHandlerArg *arg = lfirst(lc);

		/*
		 * If there is still error, we can not do anything more, just raise it.
		 * requireBusyHandler is set to false, and NULL busy_connection list.
		 */
		sqlite_do_sql_command(arg->conn, arg->sql, arg->level, NULL);
	}

	list_free(busy_connection);

	/*
	 * Regardless of the event type, we can now mark ourselves as out of the
	 * transaction.  (Note: if we are here during PRE_COMMIT or PRE_PREPARE,
	 * this saves a useless scan of the hashtable during COMMIT or PREPARE.)
	 */
	xact_got_connection = false;
}

/*
 * sqlitefdw_reset_xact_state --- Reset state to show we're out of a (sub)transaction
 */
static void
sqlitefdw_reset_xact_state(ConnCacheEntry *entry, bool toplevel) {
	if (toplevel) {
		/* Reset state to show we're out of a transaction */
		entry->xact_depth = 0;

		/*
		 * If the connection isn't in a good idle state, it is marked as
		 * invalid or keep_connections option of its server is disabled, then
		 * discard it to recover. Next GetConnection will open a new
		 * connection.
		 */
		if (entry->invalidated ||
			!entry->keep_connections)
		{
			elog(DEBUG3, "discarding sqlite_fdw connection %p", entry->conn);
			sqlite3_close(entry->conn);
			entry->conn = NULL;
		}
	} else {
		/* Reset state to show we're out of a subtransaction */
		entry->xact_depth--;
	}
}
/*
 * sqlitefdw_subxact_callback --- cleanup at subtransaction end.
 */
static void
sqlitefdw_subxact_callback(SubXactEvent event, SubTransactionId mySubid,
						   SubTransactionId parentSubid, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	int			curlevel;
	ListCell 	   *lc;
	List *busy_connection = NIL;

	/* Nothing to do at subxact start, nor after commit. */
	if (!(event == SUBXACT_EVENT_PRE_COMMIT_SUB ||
		  event == SUBXACT_EVENT_ABORT_SUB))
		return;

	/* Quick exit if no connections were touched in this transaction. */
	if (!xact_got_connection)
		return;

	/*
	 * Scan all connection cache entries to find open remote subtransactions
	 * of the current level, and close them.
	 */
	curlevel = GetCurrentTransactionNestLevel();
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		char		sql[100];

		/*
		 * We only care about connections with open remote subtransactions of
		 * the current level.
		 */
		if (entry->conn == NULL || entry->xact_depth < curlevel)
			continue;

		if (entry->truncatable)
			continue;

		if (entry->xact_depth > curlevel)
			elog(ERROR, "missed cleaning up remote subtransaction at level %d",
				 entry->xact_depth);

		if (event == SUBXACT_EVENT_PRE_COMMIT_SUB)
		{
			/* Commit all remote subtransactions during pre-commit */
			snprintf(sql, sizeof(sql), "RELEASE SAVEPOINT s%d", curlevel);
			sqlite_do_sql_command(entry->conn, sql, ERROR, &busy_connection);

		}
		else if (in_error_recursion_trouble())
		{
			/*
			 * Don't try to clean up the connection if we're already in error
			 * recursion trouble.
			 */
		}
		else
		{
			/* Rollback all remote subtransactions during abort */
			sqlitefdw_abort_cleanup(entry, false, &busy_connection);
		}

		/* OK, we're outta that level of subtransaction */
		sqlitefdw_reset_xact_state(entry, false);
	}

	/* Execute again the query after server is available */
	foreach(lc, busy_connection)
	{
		BusyHandlerArg *arg = lfirst(lc);

		/*
		 * If there is still error, we can not do anything more, just raise it.
		 * requireBusyHandler is set to false, and NULL busy_connection list.
		 */
		sqlite_do_sql_command(arg->conn, arg->sql, arg->level, NULL);
	}

	list_free(busy_connection);
}

/*
 * Connection invalidation callback function
 *
 * After a change to a pg_foreign_server or pg_user_mapping catalog entry,
 * mark connections depending on that entry as needing to be remade.
 * We can't immediately destroy them, since they might be in the midst of
 * a transaction, but we'll remake them at the next opportunity.
 *
 * Although most cache invalidation callbacks blow away all the related stuff
 * regardless of the given hashvalue, connections are expensive enough that
 * it's worth trying to avoid that.
 *
 * NB: We could avoid unnecessary disconnection more strictly by examining
 * individual option values, but it seems too much effort for the gain.
 */
static void
sqlitefdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	Assert(cacheid == FOREIGNSERVEROID);

	/* ConnectionHash must exist already, if we're registered */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		/* Ignore invalid entries */
		if (entry->conn == NULL)
			continue;

		/* hashvalue == 0 means a cache reset, must clear all state */
		if (hashvalue == 0 ||
			(cacheid == FOREIGNSERVEROID &&
			 entry->server_hashvalue == hashvalue))
		{
			/*
			 * Close the connection immediately if it's not used yet in this
			 * transaction. Otherwise mark it as invalid so that
			 * sqlitefdw_xact_callback() can close it at the end of this
			 * transaction.
			 */
			if (entry->xact_depth == 0)
			{
				elog(DEBUG3, "discarding sqlite_fdw connection %p", entry->conn);
				sqlite3_close(entry->conn);
				entry->conn = NULL;
			}
			else
				entry->invalidated = true;
		}
	}
}

/*
 * List active foreign server connections.
 *
 * This function takes no input parameter and returns setof record made of
 * following values:
 * - server_name - server name of active connection. In case the foreign server
 *   is dropped but still the connection is active, then the server name will
 *   be NULL in output.
 * - valid - true/false representing whether the connection is valid or not.
 * 	 Note that the connections can get invalidated in sqlitefdw_inval_callback.
 *
 * No records are returned when there are no cached connections at all.
 */
Datum
sqlite_fdw_get_connections(PG_FUNCTION_ARGS)
{
#if PG_VERSION_NUM < 140000
	ereport(ERROR,
			(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
			 errmsg("Function %s does not support in Postgres version %s", __func__, PG_VERSION)
			 ));
#else
#define SQLITE_FDW_GET_CONNECTIONS_COLS	2
	ReturnSetInfo *rsinfo = (ReturnSetInfo *) fcinfo->resultinfo;
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
#if PG_VERSION_NUM < 150000
	TupleDesc	tupdesc;
	Tuplestorestate *tupstore;
	MemoryContext per_query_ctx;
	MemoryContext oldcontext;
#endif

#if PG_VERSION_NUM >= 160000
	InitMaterializedSRF(fcinfo, 0);
#elif PG_VERSION_NUM >= 150000
	SetSingleFuncCall(fcinfo, 0);
#else
	/* check to see if caller supports us returning a tuplestore */
	if (rsinfo == NULL || !IsA(rsinfo, ReturnSetInfo))
		ereport(ERROR,
				(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
				 errmsg("set-valued function called in context that cannot accept a set")));
	if (!(rsinfo->allowedModes & SFRM_Materialize))
		ereport(ERROR,
				(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
				 errmsg("materialize mode required, but it is not allowed in this context")));

	/* Build a tuple descriptor for our result type */
	if (get_call_result_type(fcinfo, NULL, &tupdesc) != TYPEFUNC_COMPOSITE)
		elog(ERROR, "return type must be a row type");

	/* Build tuplestore to hold the result rows */
	per_query_ctx = rsinfo->econtext->ecxt_per_query_memory;
	oldcontext = MemoryContextSwitchTo(per_query_ctx);

	tupstore = tuplestore_begin_heap(true, false, work_mem);
	rsinfo->returnMode = SFRM_Materialize;
	rsinfo->setResult = tupstore;
	rsinfo->setDesc = tupdesc;

	MemoryContextSwitchTo(oldcontext);
#endif

	/* If cache doesn't exist, we return no records */
	if (!ConnectionHash)
	{
#if PG_VERSION_NUM < 150000
		/* clean up and return the tuplestore */
		tuplestore_donestoring(tupstore);
#endif

		PG_RETURN_VOID();
	}

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		ForeignServer *server;
		Datum		values[SQLITE_FDW_GET_CONNECTIONS_COLS] = {0};
		bool		nulls[SQLITE_FDW_GET_CONNECTIONS_COLS] = {0};

		/* We only look for open remote connections */
		if (!entry->conn)
			continue;

		server = GetForeignServerExtended(entry->serverid, FSV_MISSING_OK);


		/*
		 * The foreign server may have been dropped in current explicit
		 * transaction. It is not possible to drop the server from another
		 * session when the connection associated with it is in use in the
		 * current transaction, if tried so, the drop query in another session
		 * blocks until the current transaction finishes.
		 *
		 * Even though the server is dropped in the current transaction, the
		 * cache can still have associated active connection entry, say we
		 * call such connections dangling. Since we can not fetch the server
		 * name from system catalogs for dangling connections, instead we show
		 * NULL value for server name in output.
		 *
		 * We could have done better by storing the server name in the cache
		 * entry instead of server oid so that it could be used in the output.
		 * But the server name in each cache entry requires 64 bytes of
		 * memory, which is huge, when there are many cached connections and
		 * the use case i.e. dropping the foreign server within the explicit
		 * current transaction seems rare. So, we chose to show NULL value for
		 * server name in output.
		 *
		 * Such dangling connections get closed either in next use or at the
		 * end of current explicit transaction in sqlitefdw_xact_callback.
		 */
		if (!server)
		{
			/*
			 * If the server has been dropped in the current explicit
			 * transaction, then this entry would have been invalidated in
			 * sqlitefdw_inval_callback at the end of drop server command.
			 * Note that this connection would not have been closed in
			 * sqlitefdw_inval_callback because it is still being used in the
			 * current explicit transaction. So, assert that here.
			 */
			Assert(entry->conn && entry->xact_depth > 0 && entry->invalidated);

			/* Show null, if no server name was found */
			nulls[0] = true;
		}
		else
			values[0] = CStringGetTextDatum(server->servername);

		values[1] = BoolGetDatum(!entry->invalidated);
#if PG_VERSION_NUM >= 150000
		tuplestore_putvalues(rsinfo->setResult, rsinfo->setDesc, values, nulls);
#else
		tuplestore_putvalues(tupstore, tupdesc, values, nulls);
#endif
	}

#if PG_VERSION_NUM < 150000
	/* clean up and return the tuplestore */
	tuplestore_donestoring(tupstore);
#endif

	PG_RETURN_VOID();
#endif
}

/*
 * Disconnect the specified cached connections.
 *
 * This function discards the open connections that are established by
 * sqlite_fdw from the local session to the foreign server with
 * the given name. Note that there can be multiple connections to
 * the given server using different user mappings. If the connections
 * are used in the current local transaction, they are not disconnected
 * and warning messages are reported. This function returns true
 * if it disconnects at least one connection, otherwise false. If no
 * foreign server with the given name is found, an error is reported.
 */
Datum
sqlite_fdw_disconnect(PG_FUNCTION_ARGS)
{
#if PG_VERSION_NUM < 140000
	ereport(ERROR,
			(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
			 errmsg("Function %s does not support in Postgres version %s", __func__, PG_VERSION)
			 ));
#else
	ForeignServer *server;
	char	   *servername;

	servername = text_to_cstring(PG_GETARG_TEXT_PP(0));
	server = GetForeignServerByName(servername, false);

	PG_RETURN_BOOL(sqlite_disconnect_cached_connections(server->serverid));
#endif
}

/*
 * Disconnect all the cached connections.
 *
 * This function discards all the open connections that are established by
 * sqlite_fdw from the local session to the foreign servers.
 * If the connections are used in the current local transaction, they are
 * not disconnected and warning messages are reported. This function
 * returns true if it disconnects at least one connection, otherwise false.
 */
Datum
sqlite_fdw_disconnect_all(PG_FUNCTION_ARGS)
{
#if PG_VERSION_NUM < 140000
	ereport(ERROR,
			(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
			 errmsg("Function %s does not support in Postgres version %s", __func__, PG_VERSION)
			 ));
#else
	PG_RETURN_BOOL(sqlite_disconnect_cached_connections(InvalidOid));
#endif
}

/*
 * Abort remote transaction or subtransaction.
 *
 * "toplevel" should be set to true if toplevel (main) transaction is
 * rollbacked, false otherwise.
 */
static void
sqlitefdw_abort_cleanup(ConnCacheEntry *entry, bool toplevel, List **busy_connection)
{
	if (toplevel)
	{
		elog(DEBUG3, "abort transaction");

		/* Finalize all prepared statements */
		sqlite_finalize_list_stmt(&entry->stmtList);

		/*
		* rollback if in transaction because SQLite may
		* already rollback
		*/
		if (!sqlite3_get_autocommit(entry->conn))
			sqlite_do_sql_command(entry->conn, "ROLLBACK", WARNING, busy_connection);
	}
	else
	{
		char		sql[100];
		int			curlevel = GetCurrentTransactionNestLevel();
		snprintf(sql,
				 sizeof(sql),
				 "ROLLBACK TO SAVEPOINT s%d; RELEASE SAVEPOINT s%d",
				 curlevel,
				 curlevel
				);
		if (!sqlite3_get_autocommit(entry->conn))
			sqlite_do_sql_command(entry->conn, sql, ERROR, busy_connection);
	}
}

#if PG_VERSION_NUM >= 140000
/*
 * Workhorse to disconnect cached connections.
 *
 * This function scans all the connection cache entries and disconnects
 * the open connections whose foreign server OID matches with
 * the specified one. If InvalidOid is specified, it disconnects all
 * the cached connections.
 *
 * This function emits a warning for each connection that's used in
 * the current transaction and doesn't close it. It returns true if
 * it disconnects at least one connection, otherwise false.
 *
 * Note that this function disconnects even the connections that are
 * established by other users in the same local session using different
 * user mappings. This leads even non-superuser to be able to close
 * the connections established by superusers in the same local session.
 *
 * XXX As of now we don't see any security risk doing this. But we should
 * set some restrictions on that, for example, prevent non-superuser
 * from closing the connections established by superusers even
 * in the same session?
 */
static bool
sqlite_disconnect_cached_connections(Oid serverid)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	bool		all = !OidIsValid(serverid);
	bool		result = false;

	/*
	 * Connection cache hashtable has not been initialized yet in this
	 * session, so return false.
	 */
	if (!ConnectionHash)
		return false;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		/* Ignore cache entry if no open connection right now. */
		if (!entry->conn)
			continue;

		if (all || entry->serverid == serverid)
		{
			/*
			 * Emit a warning because the connection to close is used in the
			 * current transaction and cannot be disconnected right now.
			 */
			if (entry->xact_depth > 0)
			{
				ForeignServer *server;

				server = GetForeignServerExtended(entry->serverid,
												  FSV_MISSING_OK);

				if (!server)
				{
					/*
					 * If the foreign server was dropped while its connection
					 * was used in the current transaction, the connection
					 * must have been marked as invalid by
					 * sqlitefdw_inval_callback at the end of DROP SERVER
					 * command.
					 */
					Assert(entry->invalidated);

					ereport(WARNING,
							(errmsg("cannot close dropped server connection because it is still in use")));
				}
				else
					ereport(WARNING,
							(errmsg("cannot close connection for server \"%s\" because it is still in use",
									server->servername)));
			}
			else
			{
				elog(DEBUG3, "discarding sqlite_fdw connection %p", entry->conn);
				sqlite_finalize_list_stmt(&entry->stmtList);
				sqlite3_close(entry->conn);
				entry->conn = NULL;
				result = true;
			}
		}
	}
	return result;
}
#endif

/*
 * cache sqlite3 statement to finalize at the end of transaction
 */
void
sqlite_cache_stmt(ForeignServer *server, sqlite3_stmt * *stmt)
{
	bool		found;
	ConnCacheEntry *entry;
	ConnCacheKey key = server->serverid;

	/*
	 * Find cached entry for requested connection.
	 */
	entry = hash_search(ConnectionHash, &key, HASH_ENTER, &found);

	/* We must always have found the entry */
	Assert(found);

	entry->stmtList = sqlite_append_stmt_to_list(entry->stmtList, *stmt);
}

/*
 * finalize all sqlite statement
 */
static void
sqlite_finalize_list_stmt(List **list)
{
	ListCell   *lc;

	foreach(lc, *list)
	{
		sqlite3_stmt *stmt = (sqlite3_stmt *) lfirst(lc);

		elog(DEBUG1, "sqlite_fdw: finalize %s", sqlite3_sql(stmt));
		sqlite3_finalize(stmt);
	}

	list_free(*list);
	*list = NULL;
}

/*
 * append sqlite3 stmt to the head of linked list
 */
static List *
sqlite_append_stmt_to_list(List *list, sqlite3_stmt * stmt)
{
	/*
	 * CurrentMemoryContext is released before cleanup transaction (when the
	 * list is called), so, use TopMemoryContext instead.
	 */
	MemoryContext oldcontext = MemoryContextSwitchTo(TopMemoryContext);

	list = lappend(list, stmt);
	MemoryContextSwitchTo(oldcontext);
	return list;
}
