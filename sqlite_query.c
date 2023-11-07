/*-------------------------------------------------------------------------
 *
 * SQLite Foreign Data Wrapper for PostgreSQL
 *
 * Portions Copyright (c) 2018, TOSHIBA CORPORATION
 *
 * IDENTIFICATION
 * 		sqlite_query.c
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"
#include "sqlite_fdw.h"

#include <stdio.h>
#include <sqlite3.h>

#include "catalog/pg_type_d.h"
#include "utils/builtins.h"
#include "utils/lsyscache.h"
#include "utils/uuid.h"
#include "utils/timestamp.h"
#include "nodes/makefuncs.h"
#include "catalog/pg_type.h"
#include "parser/parse_type.h"
#include "mb/pg_wchar.h"
#include "commands/defrem.h"

static int32
			sqlite_affinity_eqv_to_pgtype(Oid pgtyp);
static const char*
			sqlite_datatype(int t);
static void
			sqlite_value_to_pg_error (Form_pg_attribute att, sqlite3_stmt * stmt, int stmt_colid, int sqlite_value_affinity, int affinity_for_pg_column, int value_byte_size_blob_or_utf8);
static char *
			get_column_option_string(Oid relid, int varattno, char *optionname);
int
			sqlite_bind_blob_algo (int attnum, Datum value, sqlite3_stmt * stmt);
static char *
			sqlite_text_value_to_pg_db_encoding(sqlite3_stmt * stmt, int stmt_colid);
static char *
			int642binstr(sqlite3_int64 num, char *s, size_t len);

/*
 * convert_sqlite_to_pg: Convert Sqlite data into PostgreSQL's compatible data types
 */
NullableDatum
sqlite_convert_to_pg(Form_pg_attribute att, sqlite3_stmt * stmt, int stmt_colid, AttInMetadata *attinmeta, AttrNumber attnum, int sqlite_value_affinity, int AffinityBehaviourFlags)
{
	Oid			pgtyp = att->atttypid;
	Datum		value_datum = 0;
	char	   *valstr = NULL;
	int			affinity_for_pg_column = sqlite_affinity_eqv_to_pgtype(pgtyp);
				/* Compute always, void text and void BLOB will be special cases */
	int		 	value_byte_size_blob_or_utf8 = sqlite3_column_bytes(stmt, stmt_colid);

	switch (pgtyp)
	{
		case BOOLOID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							int			value = sqlite3_column_int(stmt, stmt_colid);
							return (struct NullableDatum){BoolGetDatum(value), false};
						}
					case SQLITE_FLOAT:
					case SQLITE_BLOB:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL bool column");
						break;
					}
					default:
					{
						sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						break;
					}
				}
				break;
			}
		case BYTEAOID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER:
					case SQLITE_FLOAT:
					default:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE_BLOB: /* <-- proper and recommended SQLite affinity of value for pgtyp */
					case SQLITE3_TEXT: /* threated as UTF-8 text BLOB */
					{
						value_datum = (Datum) palloc0(value_byte_size_blob_or_utf8 + VARHDRSZ);
						memcpy(VARDATA(value_datum), sqlite3_column_blob(stmt, stmt_colid), value_byte_size_blob_or_utf8);
						SET_VARSIZE(value_datum, value_byte_size_blob_or_utf8 + VARHDRSZ);
						return (struct NullableDatum) {PointerGetDatum((const void *)value_datum), false};
					}
				}
				break;
			}
		case INT2OID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							int			value = sqlite3_column_int(stmt, stmt_colid);
							return (struct NullableDatum) {Int16GetDatum(value), false};
						}
					case SQLITE_FLOAT:
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL smallint column");
						break;
					}
				}
				break;
			}
		case INT4OID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER: /* <-- proper and recommended SQLite affinity of value for pgtyp */
					{
						int			value = sqlite3_column_int(stmt, stmt_colid);
						return (struct NullableDatum) {Int32GetDatum(value), false};
					}
					case SQLITE_FLOAT: /* TODO: This code is untill mod() pushdowning fix here*/
					{
						int			value = sqlite3_column_int(stmt, stmt_colid);

						elog(DEBUG2, "sqlite_fdw : real aff. was readed for pg int32");
						return (struct NullableDatum) {Int32GetDatum(value), false};
					}
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error (att, stmt, stmt_colid, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL int column");
						break;
					}
				}
				break;
			}
		case INT8OID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							sqlite3_int64 value = sqlite3_column_int64(stmt, stmt_colid);
							return (struct NullableDatum) {Int64GetDatum(value), false};
						}
					case SQLITE_FLOAT: /* TODO: This code is untill mod() pushdowning fix here*/
					{
						int			value = sqlite3_column_int(stmt, stmt_colid);

						elog(DEBUG2, "sqlite_fdw : real aff. was readed for pg int64");
						return (struct NullableDatum) {Int32GetDatum(value), false};
					}
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL bigint column");
						break;
					}
				}
				break;
			}
		case FLOAT4OID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_FLOAT: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							double		value = sqlite3_column_double(stmt, stmt_colid);
							return (struct NullableDatum) {Float4GetDatum((float4) value), false};
						}
					case SQLITE_INTEGER:
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL float4 column");
						break;
					}
				}
				break;
			}
		case FLOAT8OID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_FLOAT: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							double		value = sqlite3_column_double(stmt, stmt_colid);
							return (struct NullableDatum) {Float8GetDatum((float8) value), false};
						}
					case SQLITE_INTEGER:
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL float8 column");
						break;
					}
				}
				break;
			}
		case TIMESTAMPOID:
		case TIMESTAMPTZOID:
			{
				/*
				 * We add this conversion to allow add INTEGER/FLOAT SQLite
				 * Columns be added as TimeStamp in PostgreSQL. We just
				 * calling PostgreSQL function "to_timestamp(double value)""
				 * to convert each registry returned from INT/FLOAT value to
				 * TimeStamp string, so PosgtreSQL can handle/show without
				 * problems. If it's a TEXT SQLite column...we let them to the
				 * "regular" process because its already implemented and
				 * working properly.
				 */
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER:
						{
							Timestamp value = (Timestamp)sqlite3_column_int64(stmt, stmt_colid);
							return (struct NullableDatum) {TimestampGetDatum(value), false};
						}
					case SQLITE_FLOAT:
						{
							double		value = sqlite3_column_double(stmt, stmt_colid);
							Datum		d = DirectFunctionCall1(float8_timestamptz, Float8GetDatum((float8) value));
							return (struct NullableDatum) {d, false};
						}
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							valstr = sqlite_text_value_to_pg_db_encoding(stmt, stmt_colid);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL float4 column");
						break;
					}
				}
				break;
			}
		case NUMERICOID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER:
					case SQLITE_FLOAT: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							double		value = sqlite3_column_double(stmt, stmt_colid);

							valstr = DatumGetCString(DirectFunctionCall1(float8out, Float8GetDatum((float8) value)));
							break; /* !!! use valstr later! */
						}
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL numeric column");
						break;
					}
				}
				break;
			}
			case UUIDOID:
				{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER:
					case SQLITE_FLOAT:
						{
							sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
							break;
						}
					case SQLITE_BLOB: /* <-- first proper and recommended SQLite affinity of value for pgtyp */
						{
							if (value_byte_size_blob_or_utf8 != UUID_LEN)
							{
								ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
												errmsg("PostgreSQL uuid data type allows only %d bytes SQLite blob value", UUID_LEN),
												errhint("incorrect value is %d bytes length", value_byte_size_blob_or_utf8)));
								break;
							}
						else
							{
								const unsigned char * sqlite_blob = 0;
								pg_uuid_t  *retval = (pg_uuid_t *) palloc0(sizeof(pg_uuid_t));

								sqlite_blob = sqlite3_column_blob(stmt, stmt_colid);
								memcpy(retval->data, sqlite_blob, UUID_LEN);
								return (struct NullableDatum){UUIDPGetDatum(retval), false};
								break;
							}
						}
					case SQLITE3_TEXT: /* <-- second proper and recommended SQLite affinity of value for pgtyp */
					{
						if (value_byte_size_blob_or_utf8)
							valstr = sqlite_text_value_to_pg_db_encoding(stmt, stmt_colid);
						else
							elog(ERROR, "Void text disallowed for PostgreSQL uuid column");
						break;
					}
					default:
					{
						sqlite_value_to_pg_error (att, stmt, attnum, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
						break;
					}
				}
				break;
			}
		case VARBITOID:
		case BITOID:
			{
				char * buffer = (char *) palloc0(SQLITE_FDW_BIT_DATATYPE_BUF_SIZE);
				sqlite3_int64 sqlti = sqlite3_column_int64(stmt, stmt_colid);

				buffer = int642binstr(sqlti, buffer, SQLITE_FDW_BIT_DATATYPE_BUF_SIZE);
				valstr = buffer;
				elog(DEBUG4, "sqlite_fdw : BIT buf l=%ld v = %s", SQLITE_FDW_BIT_DATATYPE_BUF_SIZE, buffer);
				break;
			}
		/* some popular datatypes for default algorythm branch
		 * case BPCHAROID:
		 * case VARCHAROID:
		 * case TEXTOID:
		 * case JSONOID:
		 * case NAMEOID:
		 * case TIMEOID:
		 */
		default:
			{
				valstr = sqlite_text_value_to_pg_db_encoding(stmt, stmt_colid);
			}
	}
	/* convert string value to appropriate type value */
	value_datum = InputFunctionCall(&attinmeta->attinfuncs[attnum],
									valstr,
									attinmeta->attioparams[attnum],
									attinmeta->atttypmods[attnum]);
	return (struct NullableDatum){value_datum, false};
}

/*
 * sqlite_bind_blob_algo:
 * Common part of extracting and preparing PostgreSQL bytea data
 * for SQLite binding as blob
 */
int
sqlite_bind_blob_algo (int attnum, Datum value, sqlite3_stmt * stmt)
{
	int			len;
	char	   *dat = NULL;
	char	   *result = DatumGetPointer(value);

	if (VARATT_IS_1B(result))
	{
		len = VARSIZE_1B(result) - VARHDRSZ_SHORT;
		dat = VARDATA_1B(result);
	}
	else
	{
		len = VARSIZE_4B(result) - VARHDRSZ;
		dat = VARDATA_4B(result);
	}
	return sqlite3_bind_blob(stmt, attnum, dat, len, SQLITE_TRANSIENT);
}

static char *
get_column_option_string(Oid relid, int varattno, char *optionname)
{
	char	   *coloptionvalue = NULL;
	List	   *options;
	ListCell   *lc;

	options = GetForeignColumnOptions(relid, varattno);
	foreach(lc, options)
	{
		DefElem	*def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, optionname) == 0)
		{
			coloptionvalue = defGetString(def);
			break;
		}
	}
	return coloptionvalue;
}

/*
 * bind_sql_var:
 * Bind the values provided as DatumBind the values and nulls to modify the target table (INSERT/UPDATE)
 */
void
sqlite_bind_sql_var(Form_pg_attribute att, int attnum, Datum value, sqlite3_stmt * stmt, bool *isnull, Oid relid)
{
	int			ret = SQLITE_OK;
	Oid			type = att->atttypid;
	int32		pgtypmod = att->atttypmod;
	attnum++;
	elog(DEBUG2, "sqlite_fdw : %s %d type=%u relid=%u typmod=%d ", __func__, attnum, type, relid, pgtypmod);

	if (*isnull)
	{
		ret = sqlite3_bind_null(stmt, attnum);
		if (ret != SQLITE_OK)
			elog(ERROR, "sqlite3_bind_null failed with rc=%d", ret);
		return;
	}

	switch (type)
	{
		case INT2OID:
			{
				int16		dat = DatumGetInt16(value);

				ret = sqlite3_bind_int(stmt, attnum, dat);
				break;
			}
		case INT4OID:
			{
				int32		dat = DatumGetInt32(value);

				ret = sqlite3_bind_int(stmt, attnum, dat);
				break;
			}
		case INT8OID:
			{
				int64		dat = DatumGetInt64(value);

				ret = sqlite3_bind_int64(stmt, attnum, dat);
				break;
			}

		case FLOAT4OID:

			{
				float4		dat = DatumGetFloat4(value);

				ret = sqlite3_bind_double(stmt, attnum, (double) dat);
				break;
			}
		case FLOAT8OID:
			{
				float8		dat = DatumGetFloat8(value);

				ret = sqlite3_bind_double(stmt, attnum, dat);
				break;
			}

		case NUMERICOID:
			{
				Datum		value_datum = DirectFunctionCall1(numeric_float8, value);
				float8		dat = DatumGetFloat8(value_datum);

				ret = sqlite3_bind_double(stmt, attnum, dat);
				break;
			}
		case BOOLOID:
			{
				int32		dat = DatumGetInt32(value);

				ret = sqlite3_bind_int(stmt, attnum, dat);
				break;
			}

		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
		case JSONOID:
		case NAMEOID:
		case TIMEOID:
		case TIMESTAMPOID:
		case TIMESTAMPTZOID:
		case DATEOID:
			{
				/* Bind as text because SQLite does not have these types */
				char	   *outputString = NULL;
				Oid			outputFunctionId = InvalidOid;
				bool		typeVarLength = false;
				int			pg_database_encoding = GetDatabaseEncoding(); /* very fast call, see PostgreSQL mbutils.c */
				char	   *utf8_text_value = NULL;

				getTypeOutputInfo(type, &outputFunctionId, &typeVarLength);
				outputString = OidOutputFunctionCall(outputFunctionId, value);
				if (pg_database_encoding == PG_UTF8)
					utf8_text_value = outputString;
				else
					utf8_text_value = (char *) pg_do_encoding_conversion((unsigned char *) outputString, strlen(outputString), pg_database_encoding, PG_UTF8);
				ret = sqlite3_bind_text(stmt, attnum, utf8_text_value, -1, SQLITE_TRANSIENT);
				break;
			}
		case BYTEAOID:
			{
				ret = sqlite_bind_blob_algo(attnum, value, stmt);
				break;
			}
		case UUIDOID:
			{
				bool		uuid_as_blob = false;

				if (relid)
				{
					char * optv = get_column_option_string (relid, attnum, "column_type");
					elog(DEBUG3, "sqlite_fdw : col type %s ", optv);
					if (optv != NULL && strcasecmp(optv, "BLOB") == 0)
						uuid_as_blob = true;
				}

				if (uuid_as_blob)
				{
					unsigned char *dat = palloc0(UUID_LEN);
					pg_uuid_t* pg_uuid = DatumGetUUIDP(value);
					elog(DEBUG2, "sqlite_fdw : bind uuid as blob");
					memcpy(dat, pg_uuid->data, UUID_LEN);
					ret = sqlite3_bind_blob(stmt, attnum, dat, UUID_LEN, SQLITE_TRANSIENT);
				}
				else
				{
					/* uuid as text */
					char	   *outputString = NULL;
					Oid			outputFunctionId = InvalidOid;
					bool		typeVarLength = false;
					getTypeOutputInfo(type, &outputFunctionId, &typeVarLength);
					outputString = OidOutputFunctionCall(outputFunctionId, value); /* uuid text belongs to ASCII subset, no need to translate encoding */
					ret = sqlite3_bind_text(stmt, attnum, outputString, -1, SQLITE_TRANSIENT);
				}
				break;
			}
		case VARBITOID:
		case BITOID:
			{
				sqlite3_int64 dat;
				char	   *outputString = NULL;
				Oid			outputFunctionId = InvalidOid;
				bool		typeVarLength = false;

				getTypeOutputInfo(type, &outputFunctionId, &typeVarLength);
				outputString = OidOutputFunctionCall(outputFunctionId, value);
				elog(DEBUG4, "sqlite_fdw : BIT bind  %s", outputString);
				if (strlen(outputString) > SQLITE_FDW_BIT_DATATYPE_BUF_SIZE - 1 )
				{
					ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
							errmsg("SQLite FDW dosens't support very long bit/varbit data"),
							errhint("bit length %ld, maximum %ld", strlen(outputString), SQLITE_FDW_BIT_DATATYPE_BUF_SIZE - 1)));
				}
				dat = binstr2int64(outputString);
				ret = sqlite3_bind_int64(stmt, attnum, dat);
				break;
			}
		default:
			{
				NameData	pgColND = att->attname;
				const char	*pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(type, pgtypmod));
				ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
								errmsg("cannot convert constant value to Sqlite value"),
								errhint("Constant value data type: \"%s\" in column \"%.*s\"", pg_dataTypeName, (int)sizeof(pgColND.data), pgColND.data)));
				break;
			}
	}
	if (ret != SQLITE_OK)
	{
		const char	*pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(type, pgtypmod));
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
						errmsg("Can't convert constant value to Sqlite: %s",
							   sqlite3_errmsg(sqlite3_db_handle(stmt))),
						errhint("Constant value data type: %s", pg_dataTypeName)));
	}
}

/*
 * Give nearest SQLite data affinity for PostgreSQL data type
 */
static int32
sqlite_affinity_eqv_to_pgtype(Oid type)
{
	switch (type)
	{
		case INT2OID:
		case INT4OID:
		case INT8OID:
		case BOOLOID:
			return SQLITE_INTEGER;
		case FLOAT4OID:
		case FLOAT8OID:
		case NUMERICOID:
			return SQLITE_FLOAT;
		case BYTEAOID:
			return SQLITE_BLOB;
		default:
			return SQLITE3_TEXT;
	}
}

/*
 * Give equivalent string for SQLite data affinity by int from enum
 * SQLITE_INTEGER etc.
 */
static const char*
sqlite_datatype(int t)
{
	static const char *azType[] = { "?", "integer", "real", "text", "blob", "null" };
	switch (t)
	{
		case SQLITE_INTEGER:
			return azType[1];
		case SQLITE_FLOAT:
			return azType[2];
		case SQLITE3_TEXT:
			return azType[3];
		case SQLITE_BLOB:
			return azType[4];
		case SQLITE_NULL:
			return azType[5];
		default:
			return azType[0];
	}
}

/*
 * Human readable message about disallowed combination of PostgreSQL columnn
 * data type and SQLite data value affinity
 */
static void
sqlite_value_to_pg_error (Form_pg_attribute att, sqlite3_stmt * stmt, int stmt_colid, int sqlite_value_affinity, int affinity_for_pg_column, int value_byte_size_blob_or_utf8)
{
	Oid			pgtyp = att->atttypid;
	int32		pgtypmod = att->atttypmod;
	NameData	pgColND = att->attname;
	const char *sqlite_affinity = 0;
	const char *pg_eqv_affinity = 0;
	const char *pg_dataTypeName = 0;
	const int	max_logged_byte_length = NAMEDATALEN;

	pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(pgtyp, pgtypmod));
	sqlite_affinity = sqlite_datatype(sqlite_value_affinity);
	pg_eqv_affinity = sqlite_datatype(affinity_for_pg_column);

	if (value_byte_size_blob_or_utf8 < max_logged_byte_length)
	{
		const unsigned char	*text_value = sqlite3_column_text(stmt, stmt_colid);
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
						errmsg("SQLite data affinity \"%s\" disallowed for PostgreSQL data type \"%s\"", sqlite_affinity, pg_dataTypeName),
						errhint("In column \"%.*s\" expected SQLite affinity \"%s\", incorrect value = '%s'", (int)sizeof(pgColND.data), pgColND.data, pg_eqv_affinity, text_value)));
	}
	else
	{
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
						errmsg("SQLite data affinity \"%s\" disallowed for PostgreSQL data type \"%s\"", sqlite_affinity, pg_dataTypeName),
						errhint("In column \"%.*s\" expected SQLite affinity \"%s\", a long incorrect value (%d bytes)", (int)sizeof(pgColND.data), pgColND.data, pg_eqv_affinity, value_byte_size_blob_or_utf8)));
	}
}

static char *
sqlite_text_value_to_pg_db_encoding(sqlite3_stmt * stmt, int stmt_colid)
{
	int pg_database_encoding = GetDatabaseEncoding(); /* very fast call, see PostgreSQL mbutils.c */
	char *utf8_text_value;
	/* Text from this SQLite function is always UTF-8,
	 * see  https://www.sqlite.org/c3ref/column_blob.html
	 */
	utf8_text_value = (char *) sqlite3_column_text(stmt, stmt_colid);
	if (pg_database_encoding == PG_UTF8)
		return utf8_text_value;
	else
		/* There is no UTF16 in PostgreSQL for fast sqlite3_column_text16, hence always convert */
		return (char *) pg_do_encoding_conversion((unsigned char *) utf8_text_value, strlen(utf8_text_value), PG_UTF8, pg_database_encoding);
}

/*
 * Converts int64 from SQLite to PostgreSQL string from 0 and 1 only
 * s must be allocated with length not less than len + 1 bytes
 */
static char *
int642binstr(sqlite3_int64 num, char *s, size_t len)
{
	s[--len] = '\0';
    do
		s[--len] = ((num & 1) ? '1' : '0');
	while ((num >>= 1) != 0);
    return s + len;
}

/*
 * Converts PostgreSQL string from 0 and 1 only to int64 for SQLite
 */
sqlite3_int64
binstr2int64(const char *s)
{
    sqlite3_int64 rc = 0;
	char *bs = (char *)s;

    for (; '\0' != *bs; bs++)
    {
		if ('1' == *bs)
		{
            rc = (rc * 2) + 1;
        }
        else if ('0' == *bs)
        {
            rc *= 2;
        }
        else
        {
			ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
							errmsg("Not 0 or 1 in bit string"),
							errhint("value: %s", s)));
        }
    }
    return rc;
}
