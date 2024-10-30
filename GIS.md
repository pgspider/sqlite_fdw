GIS support in SQLite Foreign Data Wrapper for PostgreSQL
=========================================================

<img src="https://www.tmapy.cz/wp-content/uploads/2021/02/postgis-logo.png" align="center" height="80" alt="PostGIS"/>	+ <img src="https://www.gaia-gis.it/fossil/libspatialite/logo" align="center" height="80" alt="SpatiaLite"/>

SQLite FDW for PostgreSQL can connect PostgreSQL with or without [PostGIS](https://www.postgis.net/)
to [SpatiaLite](https://www.gaia-gis.it/fossil/libspatialite/index) SQLite database file.
This description contains only information about GIS support without common SQL and
system descriptions from [common FDW description](README.md).

Common conditions of GIS support
--------------------------------

1. SQLite FDW should be compiled with `ENABLE_GIS=1` environment variable value.
2. You must install SpatiaLite header files before compilation.
Linux packages like `libspatialite-dev` or `libspatialite-devel` can contain this files.
3. A column should have data type (domain) name from following list:
	* addbandarg
	* box2d
	* box3d
	* geography
	* geometry
	* geometry_dump
	* geomval
	* getfaceedges_returntype
	* rastbandarg
	* raster
	* reclassarg
	* summarystats
	* topoelement
	* topoelementarray
	* topogeometry
	* unionarg
	* validatetopology_returntype

	Only listed data types have full data transformation support:
	* geography
	* geometry

All other data types (domains) are treated as PostGIS specific, but unsupported.

You can use SpatiaLite GIS data support _without PostGIS installation_ after such
SQL commands as `CREATE DOMAIN geometry AS bytea;` and `CREATE DOMAIN geography AS bytea;`.
This allows to have in PostgreSQL PostGIS compatible `bytea` data easy
convertable to PostGIS storage format.

PostgGIS and SpatiaLite vector data formats
-------------------------------------------

Vector GIS data in PostGIS can be stored in a columns with `geography` or `geometry`
data type. This columns contains a binary data.
[Well-known binary (WKB)](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
data storage format is a standard of [Open Geospatial Consortium (OGC)](https://en.wikipedia.org/wiki/Open_Geospatial_Consortium)
and supported by [GEOS library](https://libgeos.org). PostGIS internal GIS data
storage format based on WKB with [SRID](https://en.wikipedia.org/wiki/Spatial_reference_system#Identifiers)
additions. This format is known as [EWKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Format_variations) and supported by
[GEOS library](https://libgeos.org) and SpatiaLite input/output functions.

Hexadecimal text representation of EWKB data is a transport form for `geography`
and `geometry` GIS data between PostgreSQL and *SpatiLite input/output functions*.
Hence no PostGIS input/output functions are necessary, but all of this functions
are supported.

EWKB hexadecimal text data transport is faster than
[EWKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
but slower than EWKB blob data transport.

SpatiaLite internal storage based on `blob` data [affinity](https://www.sqlite.org/datatype3.html)
and is not a standard of [OGC](https://en.wikipedia.org/wiki/Open_Geospatial_Consortium).
Also this format doesn't supported by [GEOS library](https://libgeos.org).

Limitations
-----------

* In opposition to PostGIS, **SpatiaLite doesn't allow to store any GIS vector data without SRID**.
Hence any well-formed SpatiaLite data can be converted for PostGIS, but
well-formed PostGIS data _without SRID_ cannot be converted for SpatiaLite.
All of SpatiaLite input functions will return `NULL` in this case.
Please use [ST_SetSRID PostGIS function](https://postgis.net/docs/ST_SetSRID.html)
in case of incomplete SRID data to prepare PostGIS data for importing to SpatiaLite
or comparing with SpatiaLite data.

* Only `=` PostgreSQL operator is pushed down to SQLite (SpatiaLite) for vector GIS data such
as `geography` or `geometry`. `<>` PostgreSQL operator is NOT pushed down.

End of description.
