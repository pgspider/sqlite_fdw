/*-------------------------------------------------------------------------
 *
 * SQLite Foreign Data Wrapper for PostgreSQL
 *
 * Portions Copyright (c) 2018, TOSHIBA CORPORATION
 *
 * IDENTIFICATION
 * 		sqlite_gis.c
 *
 * Routines that convert between SpatiaLite BLOB storage form and PostGIS EWKB
 * and some functions about detecting data type names from PostGIS set
 *-------------------------------------------------------------------------
 */

#include "postgres.h"
#include "sqlite_fdw.h"

#ifdef SQLITE_FDW_GIS_ENABLE
#include <spatialite.h>
#endif

#include <sqlite3.h>

#include "nodes/makefuncs.h"
#include "parser/parse_type.h"
#include "utils/lsyscache.h"

#ifdef SQLITE_FDW_GIS_ENABLE
static void
			common_EWKB_error (Form_pg_attribute att, int len, const char* data, bool direction_to_pg);
static char*
			getHexFormOfBlob(blobOutput b);
#endif

#define		EWKT_SRID_TEST_PREFIX_LEN 12

/*
 * This is data types from PostGIS 3.4. For a newer version use the following query
 * select pt.typname, pt."oid", pd.description,
 *		  pt.typinput, pt.typoutput
 *   from pg_catalog.pg_type pt
 *  inner join pg_catalog.pg_description pd
 *	 on pt."oid" = pd.objoid
 *  where pd.description like 'postgis %'
 */
const char *postGisSpecificTypes[] =
{
	"addbandarg", "box2d", "box3d", "geometry_dump", "geomval",
	"getfaceedges_returntype", "rastbandarg", "raster", "reclassarg",
	"summarystats", "topoelement", "topoelementarray", "topogeometry",
	"unionarg", "validatetopology_returntype", NULL
};

const char *postGisSQLiteCompatibleTypes[] = { "geometry", "geography", NULL };

#ifdef SQLITE_FDW_GIS_ENABLE
/*
 * SpatiaLiteAsPostGISgeom:
 * Gives SpatiaLite BLOB, returns hex value string for PostGIS/GEOS input function
 */
char *
SpatiaLiteAsPostGISgeom (blobOutput spatiaLiteBlob, Form_pg_attribute att)
{
	gaiaOutBuffer out_buf;
	gaiaGeomCollPtr geo = NULL;
	int gpkg_amphibious = 0;
	int gpkg_mode = 0;
	int res_len = 0;
	char *res = NULL;

	geo = gaiaFromSpatiaLiteBlobWkbEx ((unsigned char *)spatiaLiteBlob.dat,
										spatiaLiteBlob.len,
										gpkg_mode,
										gpkg_amphibious);

	if (!geo)
	{
		common_EWKB_error (att,
						   spatiaLiteBlob.len,
						   getHexFormOfBlob(spatiaLiteBlob),
						   true);
	}

	gaiaOutBufferInitialize (&out_buf);
	gaiaToEWKB (&out_buf, geo);
	if (out_buf.Error || out_buf.Buffer == NULL)
	{
		gaiaOutBufferReset (&out_buf);
		common_EWKB_error (att,
						   spatiaLiteBlob.len,
						   getHexFormOfBlob(spatiaLiteBlob),
						   true);
	}

	res_len = strlen(out_buf.Buffer);
	res = (char*) palloc(res_len*sizeof(char));
	strcpy(res, out_buf.Buffer);
	gaiaOutBufferReset (&out_buf);
	return res;
}

/*
 * getHexFormOfBlob:
 *
 * Return normal ASCII hex string for a bytes from given BLOB
 */
char*
getHexFormOfBlob(blobOutput b)
{
	const char hex[] = "0123456789abcdef";
	const char *bstr = b.dat;
	char* hstr = (char*)palloc(b.len * 2 + 1);
	unsigned char *phstr = (unsigned char *)hstr;

	for (int i = 0; i < b.len; i++)
	{
		if (bstr[i] == -128)
		{
			*phstr++ = '0';
			*phstr++ = '0';
		} else {
			*phstr++ = hex[((bstr[i] >> 4) & 0x0F)];
			*phstr++ = hex[((bstr[i]) & 0x0F)];
		}
	}
	*phstr++ = '\0';
	return hstr;
}

/*
 * hasSRID:
 * return true if there is any SRID data in hex input of EWKB
 */
static inline bool hasSRID (char *hexEWKB)
{
	unsigned char  *blob = NULL;
	int				blob_size;
	const int		wkbSRID = 0x20000000; /* PostGIS doc/ZMSgeoms.txt */
	int				endian;
	int				endian_arch = gaiaEndianArch ();
	int				srid;
	char			hexPrefix[EWKT_SRID_TEST_PREFIX_LEN];
	int				i;

	/* Copy only some initial hex byte images to get SRID flag and SRID */
	for (i = 0; i < EWKT_SRID_TEST_PREFIX_LEN && hexEWKB[i] != '\0'; i++) {
		hexPrefix[i] = hexEWKB[i];
	}
	hexPrefix[i] = '\0'; /* Null-terminate the substring */
	blob = gaiaParseHexEWKB ((const unsigned char *)hexPrefix, &blob_size);
	if (blob == NULL)
		return false;
	endian = (*(blob + 0) == 0x01);
	/* wkbSRID flag bytes 1-5. PostGIS doc/ZMSgeoms.txt */
	srid = gaiaImport32 (blob + 1, endian, endian_arch);
	free(blob);
	return (srid & wkbSRID) == wkbSRID;
}

/*
 * EWKB2SpatiaLiteBlobImage:
 * gives char* and len struncture for SQLite BLOB binding from
 * input hex string with possible EWKB presentation
 */
static inline blobOutput
EWKB2SpatiaLiteBlobImage (char *hexEWKB, Form_pg_attribute att)
{
	gaiaGeomCollPtr geo = NULL;
	int				gpkg_mode = 0;
	int				tiny_point = 0;
	unsigned char  *spatialite_blob = NULL;
	int				len = 0;
	char 		   *src = NULL;
	int				shift = 0;

	/* Ignore leading '\x' in hex data */
	if (hexEWKB[0] == '\\' && hexEWKB[1] == 'x')
		shift = 2;
	src = hexEWKB + shift;

	if (!hasSRID(src))
	{
		len = strlen(hexEWKB);
		if (att != NULL)
		{
			char *pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(att->atttypid, att->atttypmod));
			ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
							errmsg("SpatiaLite doesn't accept GIS data without SRID"),
							errhint("In column \"%.*s\" with data type \"%s\" there is incorrect value in %d bytes", (int)sizeof(att->attname.data), att->attname.data, pg_dataTypeName, len),
							errcontext("Hex data: %s", hexEWKB)));
		}
		else
			ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
							errmsg("SpatiaLite doesn't accept GIS data without SRID"),
							errhint("Not deparsable value for SpatiaLite in %d bytes", len),
							errcontext("Hex data: %s", hexEWKB)));
		pfree(hexEWKB);
		return (struct blobOutput){NULL, 0};
	}

	geo = gaiaFromEWKB ((const unsigned char *)src);
	if (NULL == geo)
	{
		common_EWKB_error(att, strlen(hexEWKB)/2, hexEWKB, false);
	}
	elog(DEBUG4, "sqlite_fdw : PostGIS -> SpatiaLite %s", hexEWKB);

	gaiaToSpatiaLiteBlobWkbEx2 (geo, &spatialite_blob, &len, gpkg_mode, tiny_point);
	gaiaFreeGeomColl (geo);
	pfree(hexEWKB);
	return (struct blobOutput){(char *)spatialite_blob, len};
}


/*
 * PostGISgeomAsSpatiaLite:
 * Gives PostGIS/GEOS BLOB, returns SpatiaLite BLOB
 */
blobOutput
PostGISgeomAsSpatiaLite (Datum d, Form_pg_attribute att)
{
	char	   *pgHexOutput = NULL;
	Oid			outputFunctionId = InvalidOid;
	bool		typeVarLength = false;

	getTypeOutputInfo(att->atttypid, &outputFunctionId, &typeVarLength);
	pgHexOutput = OidOutputFunctionCall(outputFunctionId, d);
	return EWKB2SpatiaLiteBlobImage (pgHexOutput, att);
}

/*
 * common_EWKB_error:
 *
 * Message about error inside of PostGIS/GEOS<->SpatiaLite transformation
 */
static void
common_EWKB_error (Form_pg_attribute att, int len, const char* data, bool direction_to_pg)
{
	Oid			pgtyp = att->atttypid;
	int32		pgtypmod = att->atttypmod;
	NameData	pgColND = att->attname;
	char	   *pg_dataTypeName = TypeNameToString(makeTypeNameFromOid(pgtyp, pgtypmod));

	if (direction_to_pg)
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
						errmsg("GIS data transformation error SpatiaLite->GEOS/PostGIS"),
						errhint("In column \"%.*s\" with data type \"%s\" there is incorrect value in %d bytes", (int)sizeof(pgColND.data), pgColND.data, pg_dataTypeName, len),
						errcontext("Hex data: %s", data)));
	else
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
						errmsg("GIS data transformation error GEOS/PostGIS->SpatiaLite"),
						((att != NULL) ? (errhint("In column \"%.*s\" with data type \"%s\" there is incorrect value in %d bytes", (int)sizeof(pgColND.data), pgColND.data, pg_dataTypeName, len)): (errhint("Not deparsable value for SpatiaLite in %d bytes", len))),
						errcontext("Hex data: %s", data)));
}

/*
 * sqlite_deparse_PostGIS_value:
 *
 * PostGIS gives a GEOS value and the function transforms a value to Spatialite constant
 * text input converted to EWKB and than EWKB converted to hex code.
 */
void
sqlite_deparse_PostGIS_value(char *extval, StringInfo buf)
{
	blobOutput bO = EWKB2SpatiaLiteBlobImage (extval, NULL);
	char* hexform = getHexFormOfBlob(bO);

	appendStringInfo(buf, "X\'%s\'", hexform);
	elog(DEBUG4, "sqlite_fdw : SpatialiteData %s", hexform);
	pfree(hexform);
}

#endif
