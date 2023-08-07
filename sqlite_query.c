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

#include "nodes/makefuncs.h"
#include "catalog/pg_type.h"
#include "parser/parse_type.h"
#include "mb/pg_wchar.h"

static int32
			sqlite_affinity_eqv_to_pgtype(Oid pgtyp);
static const char*
			sqlite_datatype(int t);
static void 
			sqlite_value_to_pg_error (Oid pgtyp, int pgtypmod, sqlite3_stmt * stmt, int stmt_colid, int sqlite_value_affinity, int affinity_for_pg_column, int value_byte_size_blob_or_utf8);
static char *
			sqlite_text_value_to_pg_db_encoding(sqlite3_stmt * stmt, int stmt_colid);
char *
			int2binstr(sqlite3_int64 num, char *s, size_t len);

/*
 * convert_sqlite_to_pg: Convert Sqlite data into PostgreSQL's compatible data types
 */
NullableDatum
sqlite_convert_to_pg(Oid pgtyp, int pgtypmod, sqlite3_stmt * stmt, int stmt_colid, AttInMetadata *attinmeta, AttrNumber attnum, int sqlite_value_affinity, int AffinityBehaviourFlags)
{
	Datum		value_datum = 0;
	char	   *valstr = NULL;
	int			affinity_for_pg_column = sqlite_affinity_eqv_to_pgtype(pgtyp);
	int		 	value_byte_size_blob_or_utf8 = sqlite3_column_bytes(stmt, stmt_colid); // Compute always, void text and void BLOB will be special cases

	if (affinity_for_pg_column != sqlite_value_affinity && sqlite_value_affinity == SQLITE3_TEXT)
	{
		sqlite_value_to_pg_error (pgtyp, pgtypmod, stmt, stmt_colid, sqlite_value_affinity, affinity_for_pg_column, value_byte_size_blob_or_utf8);
	}

	switch (pgtyp)
	{
		case BYTEAOID:
			{
				// int			value_byte_size_blob_or_utf = sqlite3_column_bytes(stmt, stmt_colid); // Calculated always for detectind void values
				value_datum = (Datum) palloc0(value_byte_size_blob_or_utf8 + VARHDRSZ);
				memcpy(VARDATA(value_datum), sqlite3_column_blob(stmt, stmt_colid), value_byte_size_blob_or_utf8);
				SET_VARSIZE(value_datum, value_byte_size_blob_or_utf8 + VARHDRSZ);
				return (struct NullableDatum) { PointerGetDatum(value_datum), false};
			}
		case INT2OID:
			{
				int			value = sqlite3_column_int(stmt, stmt_colid);

				return (struct NullableDatum) { Int16GetDatum(value), false};
			}
		case INT4OID:
			{
				int			value = sqlite3_column_int(stmt, stmt_colid);

				return (struct NullableDatum) { Int32GetDatum(value), false};
			}
		case INT8OID:
			{
				sqlite3_int64 value = sqlite3_column_int64(stmt, stmt_colid);

				return (struct NullableDatum) { Int64GetDatum(value), false};
			}
		case FLOAT4OID:
			{
				double		value = sqlite3_column_double(stmt, stmt_colid);

				return (struct NullableDatum) { Float4GetDatum((float4) value), false};
			}
		case FLOAT8OID:
			{
				double		value = sqlite3_column_double(stmt, stmt_colid);

				return (struct NullableDatum) { Float8GetDatum((float8) value), false};
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
				if (sqlite_value_affinity == SQLITE_INTEGER || sqlite_value_affinity == SQLITE_FLOAT)
				{
					double		value = sqlite3_column_double(stmt, stmt_colid);
					Datum		d = DirectFunctionCall1(float8_timestamptz, Float8GetDatum((float8) value));

					return (struct NullableDatum) { d, false};
				}
				else
				{
					valstr = sqlite_text_value_to_pg_db_encoding(stmt, stmt_colid);
				}
				break;
			}
		case NUMERICOID:
			{
				double		value = sqlite3_column_double(stmt, stmt_colid);

				valstr = DatumGetCString(DirectFunctionCall1(float8out, Float8GetDatum((float8) value)));
				break;
			}
		case VARBITOID:
		case BITOID:
			{
				char * buffer = palloc0(SQLITE_FDW_BIT_DATATYPE_BUF_SIZE);			
				sqlite3_int64 sqlti = sqlite3_column_int64(stmt, stmt_colid);				
				buffer = int2binstr(sqlti, buffer, SQLITE_FDW_BIT_DATATYPE_BUF_SIZE);
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
	return (struct NullableDatum) { value_datum, false};
}

/*
 * bind_sql_var:
 * Bind the values provided as DatumBind the values and nulls to modify the target table (INSERT/UPDATE)
 */
void
sqlite_bind_sql_var(Oid type, int attnum, Datum value, sqlite3_stmt * stmt, bool *isnull)
{
	int			ret = SQLITE_OK;

	attnum++;
	elog(DEBUG2, "sqlite_fdw : %s %d type=%u ", __func__, attnum, type);

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
				ret = sqlite3_bind_blob(stmt, attnum, dat, len, SQLITE_TRANSIENT);
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
							errhint("bit length %ld, maxmum %ld", strlen(outputString), SQLITE_FDW_BIT_DATATYPE_BUF_SIZE - 1)));
				}
				dat = binstr2int(outputString);
				ret = sqlite3_bind_int64(stmt, attnum, dat);
				break;
			}
		default:
			{
				ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
								errmsg("cannot convert constant value to Sqlite value %u", type),
								errhint("Constant value data type: %u", type)));
				break;
			}
	}
	if (ret != SQLITE_OK)
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
						errmsg("Can't convert constant value to Sqlite: %s",
							   sqlite3_errmsg(sqlite3_db_handle(stmt))),
						errhint("Constant value data type: %u", type)));

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
static const char* sqlite_datatype(int t)
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
static void sqlite_value_to_pg_error (Oid pgtyp, int pgtypmod, sqlite3_stmt * stmt, int stmt_colid, int sqlite_value_affinity, int affinity_for_pg_column, int value_byte_size_blob_or_utf8)
{
	const char	*sqlite_affinity = 0;
	const char	*pg_eqv_affinity = 0;
	const char	*pg_dataTypeName = 0;
	const int	 max_logged_byte_length = NAMEDATALEN;
	
	pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(pgtyp, pgtypmod));
	sqlite_affinity = sqlite_datatype(sqlite_value_affinity);
	pg_eqv_affinity = sqlite_datatype(affinity_for_pg_column);
	
	if (value_byte_size_blob_or_utf8 < max_logged_byte_length)
	{
		const unsigned char	*text_value = sqlite3_column_text(stmt, stmt_colid);
		elog(ERROR, "SQLite data affinity \"%s\" disallowed for PostgreSQL data type \"%s\" = SQLite \"%s\", value = '%s'", sqlite_affinity, pg_dataTypeName, pg_eqv_affinity, text_value);
	}
	else
	{
		elog(ERROR, "SQLite data affinity \"%s\" disallowed for PostgreSQL data type \"%s\" = SQLite \"%s\" for a long value (%d bytes)", sqlite_affinity, pg_dataTypeName, pg_eqv_affinity, value_byte_size_blob_or_utf8);
	}
}

static char * sqlite_text_value_to_pg_db_encoding(sqlite3_stmt * stmt, int stmt_colid)
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

char *int2binstr(sqlite3_int64 num, char *s, size_t len)
{
	s[--len] = '\0';
    do
		s[--len] = ((num & 1) ? '1' : '0');
	while ((num >>= 1) != 0);
    return s + len;
}

sqlite3_int64 binstr2int(const char *s)
{
    sqlite3_int64 rc;
    for (rc = 0; '\0' != *s; s++) {
		if ('1' == *s) {
            rc = (rc * 2) + 1;
        } else if ('0' == *s) {
            rc *= 2;
        } else {
            errno = EINVAL;
            return -1;
        }
    }
    return rc;
}
