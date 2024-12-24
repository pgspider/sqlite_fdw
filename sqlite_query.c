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

#ifdef SQLITE_FDW_GIS_ENABLE
#include <spatialite.h>
#endif

#include <sqlite3.h>

#include "catalog/pg_type_d.h"
#include "commands/defrem.h"
#include "mb/pg_wchar.h"
#include "nodes/makefuncs.h"
#include "parser/parse_type.h"
#include "utils/builtins.h"
#include "utils/inet.h"
#include "utils/jsonb.h"
#include "utils/lsyscache.h"
#include "utils/timestamp.h"
#include "utils/uuid.h"


static char *
			get_column_option_string(Oid relid, int varattno, char *optionname);
static char *
			sqlite_text_value_to_pg_db_encoding(sqlite3_value *val);
static char *
			int642binstr(sqlite3_int64 num, char *s, size_t len);
static inline blobOutput
			sqlite_make_JSONb (char* s);

/*
 * sqlite_value_to_pg_error
 *		Human readable message about disallowed combination of PostgreSQL columnn
 *		data type and SQLite data value affinity
 */
static void
sqlite_value_to_pg_error()
{
	ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
					errmsg("SQLite value is not compatible with PostgreSQL column data type")));
}

/*
 * pg_column_void_text_error
 *		Human readable message about disallowed void text for the PostgreSQL columnn
 */
static void
pg_column_void_text_error()
{
	ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
					errmsg("Void text disallowed this column")));
}

/*
<<<<<<< HEAD
 * convert_sqlite_to_pg:
 * Convert SQLite data as sqlite3_value into PostgreSQL's compatible Datum
=======
 * convert_sqlite_to_pg
 *		Converts SQLite value into PostgreSQL's Datum
>>>>>>> fe112d6 (Add initial SpatiaLite ↔ PostGIS support (#96))
 */
NullableDatum
sqlite_convert_to_pg(Form_pg_attribute att,
					 sqlite3_value * val,
					 AttInMetadata *attinmeta,
					 AttrNumber attnum,
					 int sqlite_value_affinity,
					 int AffinityBehaviourFlags)
{
	Oid			pgtyp = att->atttypid;
	Datum		value_datum = 0;
	char	   *valstr = NULL;
				/* Compute always, void text and void BLOB is special cases */
	int		 	value_byte_size_blob_or_utf8 = sqlite3_value_bytes(val);

	switch (pgtyp)
	{
		/* popular first */
		case VARCHAROID:
		case CHAROID:
		case TEXTOID:
		case DATEOID:
		case TIMEOID:
		case NAMEOID:
		case BPCHAROID:
			{
				valstr = sqlite_text_value_to_pg_db_encoding(val);
				/* use valstr after switch */
				break;
			}
		case BOOLOID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							int			value = sqlite3_value_int(val);
							return (struct NullableDatum){BoolGetDatum(value), false};
						}
					case SQLITE_FLOAT:
					case SQLITE_BLOB:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error();
						else
							pg_column_void_text_error();
						break;
					}
					default:
					{
						sqlite_value_to_pg_error();
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
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE_BLOB: /* <-- proper and recommended SQLite affinity of value for pgtyp */
					case SQLITE3_TEXT: /* treated as UTF-8 text BLOB */
					{
						value_datum = (Datum) palloc0(value_byte_size_blob_or_utf8 + VARHDRSZ);
						memcpy(VARDATA(value_datum), sqlite3_value_blob(val), value_byte_size_blob_or_utf8);
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
							sqlite_int64 i64v = sqlite3_value_int64(val);
							Datum d = DirectFunctionCall1(int82, Int64GetDatum((int64) i64v));
							return (struct NullableDatum) {d, false};
						}
					case SQLITE_FLOAT:
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error();
						else
							pg_column_void_text_error();
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
						sqlite_int64 i64v = sqlite3_value_int64(val);
						Datum d = DirectFunctionCall1(int84, Int64GetDatum((int64) i64v));
						return (struct NullableDatum) {d, false};
					}
					case SQLITE_FLOAT: /* TODO: This code is untill mod() pushdowning fix here */
					{
						int			value = sqlite3_value_int(val);

						elog(DEBUG2, "sqlite_fdw : real aff. was readed for pg int32");
						return (struct NullableDatum) {Int32GetDatum(value), false};
					}
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error();
						else
							pg_column_void_text_error();
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
							sqlite3_int64 value = sqlite3_value_int64(val);
							return (struct NullableDatum) {Int64GetDatum(value), false};
						}
					case SQLITE_FLOAT: /* TODO: This code is untill mod() pushdowning fix here */
					{
						double		value = sqlite3_value_double(val);
						Datum	 	d = DirectFunctionCall1(dtoi8, Float8GetDatum((float8) value));
						elog(DEBUG2, "sqlite_fdw : real aff. was readed for pg int64");
						return (struct NullableDatum) {d, false};
					}
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error();
						else
							pg_column_void_text_error();
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
							double		value = sqlite3_value_double(val);
							Datum		d = DirectFunctionCall1(dtof, Float8GetDatum((float8)value));
							return (struct NullableDatum) {d, false};
						}
					case SQLITE3_TEXT:
						{
							if (value_byte_size_blob_or_utf8)
							{
								const char* text_value = (const char*) sqlite3_value_text(val);
								if (strcasecmp(text_value, "NaN") == 0)
									return (struct NullableDatum) {Float8GetDatum(NAN), false};
								else
									sqlite_value_to_pg_error();
				 			}
							else
								pg_column_void_text_error();
							break;
						}
					case SQLITE_INTEGER:
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error();
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
							double		value = sqlite3_value_double(val);
							return (struct NullableDatum) {Float8GetDatum((float8) value), false};
						}
					case SQLITE3_TEXT:
						{
							if (value_byte_size_blob_or_utf8)
							{
								const char* text_value = (const char*) sqlite3_value_text(val);
								if (strcasecmp(text_value, "NaN") == 0)
									return (struct NullableDatum) {Float8GetDatum(NAN), false};
								else
									sqlite_value_to_pg_error();
				 			}
							else
								pg_column_void_text_error();
							break;
						}
					case SQLITE_INTEGER:
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error();
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
							Timestamp value = (Timestamp)sqlite3_value_int64(val);
							return (struct NullableDatum) {TimestampGetDatum(value), false};
						}
					case SQLITE_FLOAT:
						{
							double		value = sqlite3_value_double(val);
							Datum		d = DirectFunctionCall1(float8_timestamptz, Float8GetDatum((float8) value));
							return (struct NullableDatum) {d, false};
						}
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							valstr = sqlite_text_value_to_pg_db_encoding(val);
							/* !!! use valstr later! */
						else
							pg_column_void_text_error();
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
							double		value = sqlite3_value_double(val);

							valstr = DatumGetCString(DirectFunctionCall1(float8out, Float8GetDatum((float8) value)));
							break; /* !!! use valstr later! */
						}
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
						{
							const char* text_value = (const char*) sqlite3_value_text(val);
							if (strcasecmp(text_value, "NaN") == 0)
								return (struct NullableDatum) {Float8GetDatum(NAN), false};
							else
								sqlite_value_to_pg_error();
			 			}
						else
							pg_column_void_text_error();
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
							sqlite_value_to_pg_error();
							break;
						}
					/*
					 * SQLite UUID output always normalized to blob.
					 * In sqlite_data_norm.c there is special additional C function.
					 */
					case SQLITE_BLOB: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							if (value_byte_size_blob_or_utf8 != UUID_LEN)
							{
								ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
												errmsg("PostgreSQL uuid data type allows only %d bytes SQLite blob value", UUID_LEN)));
								break;
							}
							else
							{
								const unsigned char * sqlite_blob = 0;
								pg_uuid_t  *retval = (pg_uuid_t *) palloc0(sizeof(pg_uuid_t));

								sqlite_blob = sqlite3_value_blob(val);
								memcpy(retval->data, sqlite_blob, UUID_LEN);
								return (struct NullableDatum){UUIDPGetDatum(retval), false};
								break;
							}
						}
					case SQLITE3_TEXT:
						{
							if (value_byte_size_blob_or_utf8)
								sqlite_value_to_pg_error();
							else
								pg_column_void_text_error();
							break;
						}
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
				}
				break;
			}
		case MACADDROID:
		case MACADDR8OID:
			{
				switch (sqlite_value_affinity)
				{
					/*
					 * SQLite MAC address output always normalized to int64.
					 * In sqlite_data_norm.c there is special additional C function.
					 */
					case SQLITE_INTEGER: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							sqlite3_int64		 value = sqlite3_value_int64(val);
							if (pgtyp == MACADDROID)
							{
								macaddr*			 retval;
								/* maximal int64 for macaddr 6b */
								const sqlite3_uint64 max = (1ULL << (6 * CHAR_BIT)) - 1ULL;

								if (value > max )
									ereport(ERROR,
											 (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
											  errmsg("int64 for macaddr out of range")));

								retval = (macaddr *) palloc(sizeof(macaddr));
								retval->a = (value >> (CHAR_BIT * 5)) & 0xFF;
								retval->b = (value >> (CHAR_BIT * 4)) & 0xFF;
								retval->c = (value >> (CHAR_BIT * 3)) & 0xFF;
								retval->d = (value >> (CHAR_BIT * 2)) & 0xFF;
								retval->e = (value >> (CHAR_BIT * 1)) & 0xFF;
								retval->f = (value >> (CHAR_BIT * 0)) & 0xFF;
								return (struct NullableDatum){MacaddrPGetDatum(retval), false};
							}
							else
							{
								macaddr8 *		retval = (macaddr8 *) palloc(sizeof(macaddr8));
								retval->a = (value >> (CHAR_BIT * 7)) & 0xFF;
								retval->b = (value >> (CHAR_BIT * 6)) & 0xFF;
								retval->c = (value >> (CHAR_BIT * 5)) & 0xFF;
								retval->d = (value >> (CHAR_BIT * 4)) & 0xFF;
								retval->e = (value >> (CHAR_BIT * 3)) & 0xFF;
								retval->f = (value >> (CHAR_BIT * 2)) & 0xFF;
								retval->g = (value >> (CHAR_BIT * 1)) & 0xFF;
								retval->h = (value >> (CHAR_BIT * 0)) & 0xFF;
								return (struct NullableDatum){Macaddr8PGetDatum(retval), false};
							}
						}
					case SQLITE_FLOAT:
					case SQLITE_BLOB:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:
						{
							if (value_byte_size_blob_or_utf8)
								sqlite_value_to_pg_error();
							else
								pg_column_void_text_error();
							break;
						}
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
				}
				break;
			}
		case VARBITOID:
		case BITOID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							char * buffer = (char *) palloc0(SQLITE_FDW_BIT_DATATYPE_BUF_SIZE);
							sqlite3_int64 sqlti = sqlite3_value_int64(val);

							buffer = int642binstr(sqlti, buffer, SQLITE_FDW_BIT_DATATYPE_BUF_SIZE);
							valstr = buffer;
							elog(DEBUG4, "sqlite_fdw : BIT buf l=%ld v = %s", SQLITE_FDW_BIT_DATATYPE_BUF_SIZE, buffer);
							break;
						}
					case SQLITE_FLOAT:
					case SQLITE_BLOB:
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:
					{
						if (value_byte_size_blob_or_utf8)
							sqlite_value_to_pg_error();
						else
							pg_column_void_text_error();
						break;
					}
				}
				break;
			}
		case JSONOID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER:
					case SQLITE_FLOAT:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE_BLOB:
						{
							ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
											errmsg("you should disable column_type = text for this column, because there is possible jsonb value")));
							break;
						}
					case SQLITE3_TEXT:/* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
							if (value_byte_size_blob_or_utf8)
							{
								valstr = sqlite_text_value_to_pg_db_encoding(val);
								/* use valstr after switch */
								break;
							}
							else
								pg_column_void_text_error();
							break;
						}
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
				}
				break;
			}
		case JSONBOID:
			{
				switch (sqlite_value_affinity)
				{
					case SQLITE_INTEGER:
					case SQLITE_FLOAT:
					case SQLITE_BLOB:
						{
							sqlite_value_to_pg_error();
							break;
						}
					case SQLITE3_TEXT:/* <-- there is normalization function for text affinity only output  */
						{
							if (value_byte_size_blob_or_utf8)
							{
								valstr = sqlite_text_value_to_pg_db_encoding(val);
								/* use valstr after switch */
								break;
							}
							else
								pg_column_void_text_error();
							break;
						}
					default:
						{
							sqlite_value_to_pg_error();
							break;
						}
				}
				break;
			}
		default:
			{
				/*
				 * PostGIS data types can be supported only by name
				 * This is very rare and not fast algorythm branch
				 */
				char *pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(att->atttypid, att->atttypmod));
				NameData	pgColND = att->attname;

				if (listed_datatype(pg_dataTypeName, postGisSpecificTypes))
				{
					elog(DEBUG4, "sqlite_fdw : is postGisSpecificType %s", pg_dataTypeName);
					ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
									errmsg("This data type is PostGIS specific and is not supported by SpatiaLite or sqlite_fdw"),
									errhint("Data type: \"%s\" in column \"%.*s\"", pg_dataTypeName, (int)sizeof(pgColND.data), pgColND.data)));
				}

				if (listed_datatype(pg_dataTypeName, postGisSQLiteCompatibleTypes))
				{
					elog(DEBUG4, "sqlite_fdw : is postGisSQLiteCompatibleType");
					switch (sqlite_value_affinity)
					{
						case SQLITE_INTEGER:
						case SQLITE_FLOAT:
						default:
							{
								sqlite_value_to_pg_error();
								break;
							}
						case SQLITE_BLOB: /* <-- proper and recommended SQLite affinity of value for pgtyp */
						{
#ifdef SQLITE_FDW_GIS_ENABLE
							unsigned const char * p_blob = sqlite3_value_blob(val);
							valstr = SpatiaLiteAsPostGISgeom (
								(struct blobOutput){(const char *)p_blob, value_byte_size_blob_or_utf8},
								att
							);
							/* !!! use valstr later! Hex Input */
#else
							Oid			atttypid = att->atttypid;
							int32		atttypmod = att->atttypmod;

							/*
							 * If a domain has been declared as bytea, it can support PostGIS data type
							 */
							atttypid = getBaseTypeAndTypmod(atttypid, &atttypmod);

							if (atttypid == BYTEAOID)
							{
								value_datum = (Datum) palloc0(value_byte_size_blob_or_utf8 + VARHDRSZ);
								memcpy(VARDATA(value_datum), sqlite3_value_blob(val), value_byte_size_blob_or_utf8);
								SET_VARSIZE(value_datum, value_byte_size_blob_or_utf8 + VARHDRSZ);
								return (struct NullableDatum) {PointerGetDatum((const void *)value_datum), false};
							}
							else
								ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
												errmsg("This PostGIS data type is supported by SpatiaLite, but FDW compiled without GIS data support"),
												errhint("Data type: \"%s\" in column \"%.*s\"", pg_dataTypeName, (int)sizeof(pgColND.data), pgColND.data)));
#endif
							break;
						}
						case SQLITE3_TEXT:
						{
							/* WKT data transport is not implemented */
							sqlite_value_to_pg_error();
							break;
						}
					}
				}
				else
				{
					/* common, not PostGIS case */
					valstr = sqlite_text_value_to_pg_db_encoding(val);
				}
			}
		break;
	}
	/* convert string value to appropriate type value */
	value_datum = InputFunctionCall(&attinmeta->attinfuncs[attnum],
									valstr,
									attinmeta->attioparams[attnum],
									attinmeta->atttypmods[attnum]);
	return (struct NullableDatum){value_datum, false};
}

/*
 * sqlite_datum_to_blob
 *		Common part of extracting and preparing PostgreSQL bytea data
 *		for SQLite binding as blob
 */
blobOutput
sqlite_datum_to_blob (Datum value)
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
	return (struct blobOutput){dat, len};
}

/*
 * get_column_option_string
 *		By Oid of relation and varattno returns value of requested option
 *		of foreign table
 */
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
 * bind_sql_var
 *		Bind the values provided as DatumBind the values and nulls
 *		to modify the target table (INSERT/UPDATE)
 */
void
sqlite_bind_sql_var(Form_pg_attribute att, int attnum, Datum value, sqlite3_stmt * stmt, bool *isnull, Oid relid)
{
	int			ret = SQLITE_OK;
	Oid			type = att->atttypid;
	int32		pgtypmod = att->atttypmod;
	attnum++;
	elog(DEBUG2, "sqlite_fdw : %s %d type=%u typmod=%d", __func__, attnum, type, pgtypmod);

	if (*isnull)
	{
		ret = sqlite3_bind_null(stmt, attnum);
		if (ret != SQLITE_OK)
			elog(ERROR, "sqlite3_bind_null failed with rc=%d", ret);
		return;
	}

	switch (type)
	{
		/* popular first */
		case TEXTOID:
		case VARCHAROID:
		case JSONOID:
		case TIMESTAMPTZOID:
		case DATEOID:
		case NAMEOID:
		case TIMEOID:
		case TIMESTAMPOID:
		case BPCHAROID:
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
		case BYTEAOID:
			{
				blobOutput b = sqlite_datum_to_blob(value);
				ret = sqlite3_bind_blob(stmt, attnum, b.dat, b.len, SQLITE_TRANSIENT);
				break;
			}
		case UUIDOID:
			{
				int	sqlite_aff = SQLITE_NULL;

				if (relid)
				{
					char * optv = get_column_option_string (relid, attnum, "column_type");

					elog(DEBUG3, "sqlite_fdw : col type %s ", optv);
					sqlite_aff = sqlite_affinity_code(optv);
				}

				if (sqlite_aff == SQLITE_BLOB)
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
					outputString = OidOutputFunctionCall(outputFunctionId, value);
					/* uuid text belongs to ASCII subset, no need to translate encoding */
					ret = sqlite3_bind_text(stmt, attnum, outputString, -1, SQLITE_TRANSIENT);
				}
				break;
			}
		case MACADDROID:
		case MACADDR8OID:
			{
				int	sqlite_aff = SQLITE_INTEGER; /* default mac addr affinity */

				if (relid)
				{
					char * optv = get_column_option_string (relid, attnum, "column_type");

					elog(DEBUG3, "sqlite_fdw : column_type affinity %s ", optv);
					sqlite_aff = sqlite_affinity_code(optv);
				}

				if (sqlite_aff == SQLITE3_TEXT)
				{
					char	   *outputString = NULL;
					Oid			outputFunctionId = InvalidOid;
					bool		typeVarLength = false;
					elog(DEBUG2, "sqlite_fdw : bind mac as text");
					getTypeOutputInfo(type, &outputFunctionId, &typeVarLength);
					outputString = OidOutputFunctionCall(outputFunctionId, value);
					/* MAC text belongs to ASCII subset, no need to translate encoding */
					ret = sqlite3_bind_text(stmt, attnum, outputString, -1, SQLITE_TRANSIENT);
				}
				else if (sqlite_aff == SQLITE_BLOB)
				{
					if (type == MACADDROID)
					{
						unsigned char  *mca = palloc0(MACADDR_LEN);
						macaddr		   *m = DatumGetMacaddrP(value);

						elog(DEBUG2, "sqlite_fdw : bind mac as blob");
						mca[0] = m->a;
						mca[1] = m->b;
						mca[2] = m->c;
						mca[3] = m->d;
						mca[4] = m->e;
						mca[5] = m->f;
						ret = sqlite3_bind_blob(stmt, attnum, mca, MACADDR_LEN, SQLITE_TRANSIENT);
					}
					else
					{
						unsigned char  *mca = palloc0(MACADDR8_LEN);
						macaddr8	   *m = DatumGetMacaddr8P(value);

						elog(DEBUG2, "sqlite_fdw : bind mac8 as blob");
						mca[0] = m->a;
						mca[1] = m->b;
						mca[2] = m->c;
						mca[3] = m->d;
						mca[4] = m->e;
						mca[5] = m->f;
						mca[6] = m->g;
						mca[7] = m->h;
						ret = sqlite3_bind_blob(stmt, attnum, mca, MACADDR8_LEN, SQLITE_TRANSIENT);
					}
				}
				else /* default, INTEGER */
				{
					sqlite3_uint64 dat = 0;

					if (type == MACADDROID)
					{
						macaddr *m = DatumGetMacaddrP(value);

						dat = ((sqlite3_int64)(m->a) << (CHAR_BIT*5))
							+ ((sqlite3_int64)(m->b) << (CHAR_BIT*4))
							+ ((sqlite3_int64)(m->c) << (CHAR_BIT*3))
							+ ((sqlite3_int64)(m->d) << (CHAR_BIT*2))
							+ ((sqlite3_int64)(m->e) << (CHAR_BIT*1))
							+ ((sqlite3_int64)(m->f) << (CHAR_BIT*0));
						elog(DEBUG2, "sqlite_fdw : bind mac6 as integer %lld", dat);
						}
					else
					{
						macaddr8 *m = DatumGetMacaddr8P(value);

						dat = ((sqlite3_int64)(m->a) << (CHAR_BIT*7))
							+ ((sqlite3_int64)(m->b) << (CHAR_BIT*6))
							+ ((sqlite3_int64)(m->c) << (CHAR_BIT*5))
							+ ((sqlite3_int64)(m->d) << (CHAR_BIT*4))
							+ ((sqlite3_int64)(m->e) << (CHAR_BIT*3))
							+ ((sqlite3_int64)(m->f) << (CHAR_BIT*2))
							+ ((sqlite3_int64)(m->g) << (CHAR_BIT*1))
							+ ((sqlite3_int64)(m->h) << (CHAR_BIT*0));
						elog(DEBUG2, "sqlite_fdw : bind mac8 as integer %lld", dat);
					}
					ret = sqlite3_bind_int64(stmt, attnum, dat);
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
		case JSONBOID:
			{
				/* Bind as text because there are different JSONb presentation formats in PostgreSQL and SQLite */
				int			pg_database_encoding = GetDatabaseEncoding(); /* very fast call, see PostgreSQL mbutils.c */
				char	   *utf8_text_value = NULL;
				Datum		d = DirectFunctionCall1(jsonb_out, JsonbPGetDatum((const Jsonb *) value));
				char	   *outputString = DatumGetCString(d);
				blobOutput	jsonb;

				if (pg_database_encoding == PG_UTF8)
					utf8_text_value = outputString;
				else
					utf8_text_value = (char *)pg_do_encoding_conversion((unsigned char *) outputString, strlen(outputString), pg_database_encoding, PG_UTF8);
				jsonb = sqlite_make_JSONb(utf8_text_value);
				ret = sqlite3_bind_blob(stmt, attnum, jsonb.dat, jsonb.len, SQLITE_TRANSIENT);
				pfree((char *)jsonb.dat);
				break;
			}
		default:
			{
				NameData	pgColND = att->attname;
				char	*pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(type, pgtypmod));

				/*
				 * PostGIS data types can be supported only by name
				 * This is very rare and not fast algorythm branch
				 */
				if (listed_datatype(pg_dataTypeName, postGisSQLiteCompatibleTypes))
				{
#ifdef SQLITE_FDW_GIS_ENABLE
					blobOutput b = PostGISgeomAsSpatiaLite(value, att);
					ret = sqlite3_bind_blob(stmt, attnum, b.dat, b.len, SQLITE_TRANSIENT);
#else
					Oid			atttypid = att->atttypid;
					int32		atttypmod = att->atttypmod;

					/*
					 * If a domain has been declared as bytea,
					 * it can support PostGIS data type
					 */
					atttypid = getBaseTypeAndTypmod(atttypid, &atttypmod);

					if (atttypid == BYTEAOID)
					{
						blobOutput b = sqlite_datum_to_blob(value);
						ret = sqlite3_bind_blob(stmt, attnum, b.dat, b.len, SQLITE_TRANSIENT);
					}
					else
						ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
										errmsg("This PostGIS data type is supported by SpatiaLite, but FDW compiled without GIS data support"),
										errhint("Data type: \"%s\" in column \"%.*s\"", pg_dataTypeName, (int)sizeof(pgColND.data), pgColND.data)));
#endif
					break;
				}
				else if (listed_datatype(pg_dataTypeName, postGisSpecificTypes))
					ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
									errmsg("This data type is PostGIS specific and have not any SpatiaLite value"),
									errhint("Data type: \"%s\" in column \"%.*s\"", pg_dataTypeName, (int)sizeof(pgColND.data), pgColND.data)));
				else
					ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
									errmsg("cannot convert constant value to SQLite value"),
									errhint("Constant value data type: \"%s\" in column \"%.*s\"", pg_dataTypeName, (int)sizeof(pgColND.data), pgColND.data)));
				break;
			}
	}
	if (ret != SQLITE_OK)
	{
		char	*pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(type, pgtypmod));
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
						errmsg("Can't convert constant value to SQLite: %s",
							   sqlite3_errmsg(sqlite3_db_handle(stmt))),
						errhint("Constant value data type: %s", pg_dataTypeName)));
	}
}

/*
 * sqlite_text_value_to_pg_db_encoding
 *		Converts SQLite text to PostgreSQL text with database encoding
 */
static char *
sqlite_text_value_to_pg_db_encoding(sqlite3_value *val)
{
	int pg_database_encoding = GetDatabaseEncoding(); /* very fast call, see PostgreSQL mbutils.c */
	char *utf8_text_value;
	/* Text from this SQLite function is always UTF-8,
	 * see  https://www.sqlite.org/c3ref/column_blob.html
	 */
	utf8_text_value = (char *) sqlite3_value_text(val);
	if (pg_database_encoding == PG_UTF8)
		return utf8_text_value;
	else
	{
		/* There is no UTF16 in PostgreSQL for fast sqlite3_value_text16, hence always convert */
		char * res = (char *) pg_do_encoding_conversion((unsigned char *) utf8_text_value, strlen(utf8_text_value), PG_UTF8, pg_database_encoding);
		return res;
	}
}

/*
 * int642binstr
 *		Converts int64 from SQLite to PostgreSQL string from 0 and 1 only
 * 		s must be allocated with length not less than len + 1 bytes
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
 * binstr2int64
 *		Converts PostgreSQL string from 0 and 1 only to int64 for SQLite
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

/*
 * listed_datatype
 *		Checks if a name of data type belongs to array of special data type names
 *		used for PostGIS data type which have not stable Oid
 */
bool
listed_datatype (const char * tn, const char ** arr)
{
	int i = 0;
	char * n = strchr(tn, '.');

	if ( n != NULL )
		n = n + sizeof(char);
	else
		n = (char *)tn;
	while(arr[i])
	{
		if(!strcmp(arr[i], n))
		{
			elog(DEBUG4, "sqlite_fdw : %s \"%s\" = \"%s\" ", __func__, tn, arr[i]);
			return true;
		}
		i++;
	}
	return false;
}

/*
 * listed_datatype_oid
 *		Checks if Oid of data type is one of Oids of listed data types
 *		listed in given array.
 */
bool
listed_datatype_oid(Oid atttypid, int32 atttypmod, const char** arr)
{
	const char *pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(atttypid, atttypmod));
	bool		listed = listed_datatype(pg_dataTypeName, arr);

	elog(DEBUG2, "sqlite_fdw : %s : unusual data type %s, listed = %d", __func__, pg_dataTypeName, listed);
	return listed;
}

static inline blobOutput
sqlite_make_JSONb (char* s)
{
	int			len = 0;
	char	   *dat = NULL;
	sqlite3	   *conn = NULL;
	const char *err;
	sqlite3_stmt *res;
	char	   *query;
	int			rc = sqlite3_open_v2("", &conn, SQLITE_OPEN_MEMORY|SQLITE_OPEN_READONLY, NULL);

	if (rc != SQLITE_OK) {
		sqlite3_close(conn);
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
				 errmsg("Failed to open in-memory SQLite for JSONB creating, result code %d", rc)));
	}

	query = psprintf("select jsonb('%s') j;", s);
	rc = sqlite3_prepare_v2(conn, query, -1, &res, 0);

	if (rc != SQLITE_OK) {
		err = sqlite3_errmsg(conn);
		sqlite3_close(conn);
		pfree(query);
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
				 errmsg("Failed to fetch JSONb, result code %d, error %s", rc, err)));
	}

	rc = sqlite3_step(res);
	if (rc == SQLITE_ROW) {
		sqlite3_value	   *val = sqlite3_column_value(res, 0);
		int					sqlite_value_affinity = sqlite3_value_type(val);
		const char		   *dat1 = sqlite3_value_blob(val);

		if(sqlite_value_affinity != SQLITE_BLOB)
		{
			sqlite3_finalize(res);
			pfree(query);
			sqlite3_close(conn);
			ereport(ERROR,
					(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
					 errmsg("Failed to fetch JSONb, not a BLOB result, affinity code %d, %s", sqlite_value_affinity, query)));
		}

		len = sqlite3_column_bytes(res, 0);
		dat = palloc(len + 1);
		memcpy(dat, dat1, len);
	}

	sqlite3_finalize(res);
	pfree(query);
	sqlite3_close(conn);
	return (struct blobOutput){dat, len};
}

