--Testcase 1:
CREATE EXTENSION sqlite_fdw;
--Testcase 2:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

--Testcase 10:
CREATE DOMAIN geometry AS bytea;
--Testcase 11:
CREATE DOMAIN geography AS bytea;
--Testcase 12:
CREATE DOMAIN addbandarg AS bytea;
--Testcase 13:
CREATE DOMAIN box2d AS bytea;
--Testcase 14:
CREATE DOMAIN box3d AS bytea;
--Testcase 15:
CREATE DOMAIN geometry_dump AS bytea;
--Testcase 16:
CREATE DOMAIN geomval AS bytea;
--Testcase 17:
CREATE DOMAIN getfaceedges_returntype AS bytea;
--Testcase 18:
CREATE DOMAIN rastbandarg AS bytea;
--Testcase 19:
CREATE DOMAIN raster AS bytea;
--Testcase 20:
CREATE DOMAIN reclassarg AS bytea;
--Testcase 21:
CREATE DOMAIN summarystats AS bytea;
--Testcase 22:
CREATE DOMAIN topoelement AS bytea;
--Testcase 23:
CREATE DOMAIN topoelementarray AS bytea;
--Testcase 24:
CREATE DOMAIN topogeometry AS bytea;
--Testcase 25:
CREATE DOMAIN unionarg AS bytea;
--Testcase 26:
CREATE DOMAIN validatetopology_returntype AS bytea;

--Testcase 40:
CREATE FOREIGN TABLE "types_PostGIS"( "i" int OPTIONS (key 'true'), gm geometry, gg geography, r raster, t text) SERVER sqlite_svr;

--Testcase 41: ERR unable to convert to unsupported PostGIS specific data type
INSERT INTO "types_PostGIS" ( "i", gm, gg, r, t ) VALUES (1, decode('0101000020e6100000fd5aa846f9733e406c054d4bacd74d40', 'hex'),  decode('0101000020e6100000fd5aa846f9733e406c054d4bacd74d40', 'hex'),  decode('1223456890', 'hex'), '{"genus": "Rhododendron", "taxon": "Rhododendron ledebourii", "natural": "shrub", "genus:ru": "Рододендрон", "taxon:ru": "Рододендрон Ледебура", "source:taxon": "board"}');
--Testcase 42:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gm" TYPE bytea;
--Testcase 43:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gg" TYPE bytea;

-- Insert SpatiaLite BLOB, but CANNOT read PostGIS/GEOS BLOB
--Testcase 44: OK
INSERT INTO "types_PostGIS" ( "i", gm, gg, t ) VALUES (1, decode('0001e6100000bf72ce99fe763e40ed4960730ed84d40bf72ce99fe763e40ed4960730ed84d407c01000000bf72ce99fe763e40ed4960730ed84d40fe', 'hex'),  decode('0001e6100000bf72ce99fe763e40ed4960730ed84d40bf72ce99fe763e40ed4960730ed84d407c01000000bf72ce99fe763e40ed4960730ed84d40fe', 'hex'), '{"genus": "Rhododendron", "taxon": "Rhododendron ledebourii", "natural": "shrub", "genus:ru": "Рододендрон", "taxon:ru": "Рододендрон Ледебура", "source:taxon": "board"}');
--Testcase 45:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gm" TYPE geometry;
--Testcase 46:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gg" TYPE geography;
--Testcase 47: read the same BLOBs
SELECT "i", gm, gg, t FROM "types_PostGIS";
--Testcase 48:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", gm, gg, t FROM "types_PostGIS";
--Testcase 49:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", gm, gg, t FROM "types_PostGIS" WHERE gm = '\x0001e6100000bf72ce99fe763e40ed4960730ed84d40bf72ce99fe763e40ed4960730ed84d407c01000000bf72ce99fe763e40ed4960730ed84d40fe'::geometry;
--Testcase 50:
SELECT "i", gm, gg, t FROM "types_PostGIS" WHERE gm = '\x0001e6100000bf72ce99fe763e40ed4960730ed84d40bf72ce99fe763e40ed4960730ed84d407c01000000bf72ce99fe763e40ed4960730ed84d40fe'::geometry;

-- Insert a BLOB, read SpatiaLite BLOB without any transformations
--Testcase 51: OK
INSERT INTO "types_PostGIS" ( "i", gm, gg, t ) VALUES (2, decode('0101000020e6100000bf72ce99fe763e40ed4960730ed84d40', 'hex'),  decode('0101000020e6100000bf72ce99fe763e40ed4960730ed84d40', 'hex'), '{"genus": "Rhododendron", "taxon": "Rhododendron ledebourii"}');
--Testcase 52:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gm" TYPE bytea;
--Testcase 53:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gg" TYPE bytea;
--Testcase 54: OK
SELECT "i", gm, gg, t FROM "types_PostGIS";

--Testcase 55:
CREATE FOREIGN TABLE "♂" (
	id int4 OPTIONS (key 'true'),
	"UAI" varchar(254),
	"⌖" geometry,
	geom geometry,
	"t₀" date,
	"class" text,
	"URL" varchar(80)
) SERVER sqlite_svr;

--Testcase 56:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "⌖" TYPE bytea;
--Testcase 57:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE bytea;
--Testcase 58:
SELECT * FROM "♂";
--Testcase 59:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "⌖" TYPE geometry;
--Testcase 60:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geometry;
--Testcase 61:
INSERT INTO "♂" (id, "UAI", "⌖", geom, "t₀", "class", "URL") VALUES(301, 'Nix Olympica', 'SRID=104904;POINT (230 19.7835659606)'::geometry, NULL, '1958-01-01', 'al', 'http://planetarynames.wr.usgs.gov/Feature/4314');
--Testcase 62:
SELECT * FROM "♂";

--Testcase 63:
CREATE FOREIGN TABLE "♁ FDW"(
	geom geometry NOT NULL,
	osm_type varchar(16) OPTIONS (key 'true') NOT NULL,
	osm_id int OPTIONS (key 'true') NOT NULL,
	ver int NOT NULL,
	arr text,
	t json
) SERVER sqlite_svr
OPTIONS (table '♁');

--Testcase 55:
INSERT INTO "♁ FDW" (geom, osm_type, osm_id, ver, arr, t) VALUES('SRID=4326;MULTIPOLYGON (((30.4601278 59.6905709, 30.4601291 59.6905676, 30.4601348 59.6905656, 30.4601415 59.6905663, 30.4601453 59.6905691, 30.460144 59.6905725, 30.4601383 59.6905745, 30.4601316 59.6905738, 30.4601278 59.6905709)))'::geometry, 'way', 989184163, 1, NULL, '{"building:colour":"white","building:part":"yes","height":"6","roof:shape":"flat"}');

--Testcase 67:
SELECT * FROM "♁ FDW";

-- PostGIS specific data types, but SpatiaLite or sqlite_fdw unsupported 
--Testcase 68:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE box2d;
--Testcase 69: -- ERR
SELECT * FROM "♂";
--Testcase 70:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE box3d;
--Testcase 71: -- ERR
SELECT * FROM "♂";
--Testcase 72:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geometry_dump;
--Testcase 73: -- ERR
SELECT * FROM "♂";
--Testcase 74:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geomval;
--Testcase 75: -- ERR
SELECT * FROM "♂";
--Testcase 76:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE getfaceedges_returntype;
--Testcase 77: -- ERR
SELECT * FROM "♂";
--Testcase 78:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE rastbandarg;
--Testcase 79: -- ERR
SELECT * FROM "♂";
--Testcase 80:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE raster;
--Testcase 81: -- ERR
SELECT * FROM "♂";
--Testcase 82:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE reclassarg;
--Testcase 83: -- ERR
SELECT * FROM "♂";
--Testcase 84:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE summarystats;
--Testcase 85: -- ERR
SELECT * FROM "♂";
--Testcase 86:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE topoelement;
--Testcase 87: -- ERR
SELECT * FROM "♂";
--Testcase 88:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE topoelementarray;
--Testcase 89: -- ERR
SELECT * FROM "♂";
--Testcase 90:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE topogeometry;
--Testcase 91: -- ERR
SELECT * FROM "♂";
--Testcase 92:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE unionarg;
--Testcase 93: -- ERR
SELECT * FROM "♂";
--Testcase 94:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE validatetopology_returntype;
--Testcase 95: -- ERR
SELECT * FROM "♂";

-- PostGIS specific data types, not bytea mode, hence error
--Testcase 96:
ALTER DOMAIN geometry RENAME TO geom0;
--Testcase 97:
ALTER DOMAIN geography RENAME TO geog0;
--Testcase 98:
CREATE DOMAIN geometry AS text;
--Testcase 99:
CREATE DOMAIN geography AS text;

--Testcase 100:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geometry;
--Testcase 101: -- ERR
SELECT * FROM "♂";
--Testcase 102:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geography;
--Testcase 102: -- ERR
SELECT * FROM "♂";

--Testcase 103:
DROP DOMAIN geometry CASCADE;
--Testcase 104:
DROP DOMAIN geography CASCADE;
--Testcase 105:
DROP DOMAIN addbandarg;
--Testcase 106:
DROP DOMAIN box2d;
--Testcase 107:
DROP DOMAIN box3d;
--Testcase 108:
DROP DOMAIN geometry_dump;
--Testcase 109:
DROP DOMAIN geomval;
--Testcase 110:
DROP DOMAIN getfaceedges_returntype;
--Testcase 111:
DROP DOMAIN rastbandarg;
--Testcase 112:
DROP DOMAIN raster CASCADE;
--Testcase 113:
DROP DOMAIN reclassarg;
--Testcase 114:
DROP DOMAIN summarystats;
--Testcase 115:
DROP DOMAIN topoelement;
--Testcase 116:
DROP DOMAIN topoelementarray;
--Testcase 117:
DROP DOMAIN topogeometry;
--Testcase 118:
DROP DOMAIN unionarg;
--Testcase 119:
DROP DOMAIN validatetopology_returntype;
--Testcase 120:
DROP DOMAIN geom0 CASCADE;
--Testcase 121:
DROP DOMAIN geog0 CASCADE;

--Testcase 122:
DROP SERVER sqlite_svr CASCADE;
--Testcase 123:
DROP EXTENSION sqlite_fdw CASCADE;
