--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 001:
CREATE EXTENSION sqlite_fdw;
--Testcase 002:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

-- --Testcase 01:
CREATE DOMAIN geometry AS bytea;
-- --Testcase 02:
CREATE DOMAIN geography AS bytea;
-- --Testcase 03:
CREATE DOMAIN addbandarg AS bytea;
-- --Testcase 04:
CREATE DOMAIN box2d AS bytea;
-- --Testcase 05:
CREATE DOMAIN box3d AS bytea;
-- --Testcase 06:
CREATE DOMAIN geometry_dump AS bytea;
-- --Testcase 07:
CREATE DOMAIN geomval AS bytea;
-- --Testcase 08:
CREATE DOMAIN getfaceedges_returntype AS bytea;
-- --Testcase 09:
CREATE DOMAIN rastbandarg AS bytea;
--Testcase 10:
CREATE DOMAIN raster AS bytea;
-- --Testcase 11:
CREATE DOMAIN reclassarg AS bytea;
-- --Testcase 12:
CREATE DOMAIN summarystats AS bytea;
-- --Testcase 13:
CREATE DOMAIN topoelement AS bytea;
-- --Testcase 14:
CREATE DOMAIN topoelementarray AS bytea;
-- --Testcase 15:
CREATE DOMAIN topogeometry AS bytea;
-- --Testcase 16:
CREATE DOMAIN unionarg AS bytea;
-- --Testcase 17:
CREATE DOMAIN validatetopology_returntype AS bytea;

--Testcase 30:
CREATE FOREIGN TABLE "types_PostGIS"( "i" int OPTIONS (key 'true'), gm geometry, gg geography, r raster, t text) SERVER sqlite_svr;

--Testcase 31:
INSERT INTO "types_PostGIS" ( "i", gm, gg, r, t ) VALUES (1, decode('0101000020e6100000fd5aa846f9733e406c054d4bacd74d40', 'hex'),  decode('0101000020e6100000fd5aa846f9733e406c054d4bacd74d40', 'hex'),  decode('1223456890', 'hex'), '{"genus": "Rhododendron", "taxon": "Rhododendron ledebourii", "natural": "shrub", "genus:ru": "Рододендрон", "taxon:ru": "Рододендрон Ледебура", "source:taxon": "board"}');
--Testcase 32:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gm" TYPE bytea;
--Testcase 33:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gg" TYPE bytea;

-- Insert SpatiaLite BLOB, but CANNOT read PostGIS/GEOS BLOB
--Testcase 34: OK
INSERT INTO "types_PostGIS" ( "i", gm, gg, t ) VALUES (1, decode('0001e6100000bf72ce99fe763e40ed4960730ed84d40bf72ce99fe763e40ed4960730ed84d407c01000000bf72ce99fe763e40ed4960730ed84d40fe', 'hex'),  decode('0001e6100000bf72ce99fe763e40ed4960730ed84d40bf72ce99fe763e40ed4960730ed84d407c01000000bf72ce99fe763e40ed4960730ed84d40fe', 'hex'), '{"genus": "Rhododendron", "taxon": "Rhododendron ledebourii", "natural": "shrub", "genus:ru": "Рододендрон", "taxon:ru": "Рододендрон Ледебура", "source:taxon": "board"}');
--Testcase 35:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gm" TYPE geometry;
--Testcase 36:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gg" TYPE geography;
--Testcase 37: read the same BLOBs
SELECT "i", gm, gg, t FROM "types_PostGIS";
--Testcase 38:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", gm, gg, t FROM "types_PostGIS";
--Testcase 39:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", gm, gg, t FROM "types_PostGIS" WHERE gm = '0001e6100000bf72ce99fe763e40ed4960730ed84d40bf72ce99fe763e40ed4960730ed84d407c01000000bf72ce99fe763e40ed4960730ed84d40fe'::geometry;
--Testcase 40:
SELECT "i", gm, gg, t FROM "types_PostGIS" WHERE gm = '0001e6100000bf72ce99fe763e40ed4960730ed84d40bf72ce99fe763e40ed4960730ed84d407c01000000bf72ce99fe763e40ed4960730ed84d40fe'::geometry;

-- Insert PostGIS/GEOS BLOB, read SpatiaLite BLOB
--Testcase 41: ERR - no GIS data support
INSERT INTO "types_PostGIS" ( "i", gm, gg, t ) VALUES (2, decode('0101000020e6100000bf72ce99fe763e40ed4960730ed84d40', 'hex'),  decode('0101000020e6100000bf72ce99fe763e40ed4960730ed84d40', 'hex'), '{"genus": "Rhododendron", "taxon": "Rhododendron ledebourii"}');
--Testcase 42:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gm" TYPE bytea;
--Testcase 43:
ALTER FOREIGN TABLE "types_PostGIS" ALTER COLUMN "gg" TYPE bytea;
--Testcase 44: OK
SELECT "i", gm, gg, t FROM "types_PostGIS";

--Testcase 45:
CREATE FOREIGN TABLE "♂" (
	id int4 OPTIONS (key 'true'),
	"UAI" varchar(254),
	"⌖" geometry,
	geom geometry,
	"t₀" date,
	"class" text,
	"URL" varchar(80)
) SERVER sqlite_svr;

--Testcase 46:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "⌖" TYPE bytea;
--Testcase 47:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE bytea;
--Testcase 48:
SELECT * FROM "♂";
--Testcase 49:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "⌖" TYPE geometry;
--Testcase 50:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geometry;
--Testcase 51:
INSERT INTO "♂" (id, "UAI", "⌖", geom, "t₀", "class", "URL") VALUES(301, 'Nix Olympica', 'SRID=104904;POINT (230 19.7835659606)'::geometry, NULL, '1958-01-01', 'al', 'http://planetarynames.wr.usgs.gov/Feature/4314');
--Testcase 52:
SELECT * FROM "♂";

--Testcase 53:
CREATE FOREIGN TABLE "♁ FDW"(
	geom geometry NOT NULL,
	osm_type varchar(16) OPTIONS (key 'true') NOT NULL,
	osm_id int OPTIONS (key 'true') NOT NULL,
	ver int NOT NULL,
	arr text,
	t json
) SERVER sqlite_svr
OPTIONS (table '♁');

--Testcase 45:
INSERT INTO "♁ FDW" (geom, osm_type, osm_id, ver, arr, t) VALUES('SRID=4326;MULTIPOLYGON (((30.4601278 59.6905709, 30.4601291 59.6905676, 30.4601348 59.6905656, 30.4601415 59.6905663, 30.4601453 59.6905691, 30.460144 59.6905725, 30.4601383 59.6905745, 30.4601316 59.6905738, 30.4601278 59.6905709)))'::geometry, 'way', 989184163, 1, NULL, '{"building:colour":"white","building:part":"yes","height":"6","roof:shape":"flat"}');

--Testcase 57:
SELECT * FROM "♁ FDW";

--Testcase 58:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE box2d;
--Testcase 59: -- ERR
SELECT * FROM "♂";
--Testcase 60:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE box3d;
--Testcase 61: -- ERR
SELECT * FROM "♂";
--Testcase 62:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geometry_dump;
--Testcase 63: -- ERR
SELECT * FROM "♂";
--Testcase 64:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geomval;
--Testcase 65: -- ERR
SELECT * FROM "♂";
--Testcase 66:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE getfaceedges_returntype;
--Testcase 67: -- ERR
SELECT * FROM "♂";
--Testcase 68:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE rastbandarg;
--Testcase 69: -- ERR
SELECT * FROM "♂";
--Testcase 70:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE raster;
--Testcase 71: -- ERR
SELECT * FROM "♂";
--Testcase 72:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE reclassarg;
--Testcase 73: -- ERR
SELECT * FROM "♂";
--Testcase 74:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE summarystats;
--Testcase 75: -- ERR
SELECT * FROM "♂";
--Testcase 76:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE topoelement;
--Testcase 77: -- ERR
SELECT * FROM "♂";
--Testcase 78:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE topoelementarray;
--Testcase 79: -- ERR
SELECT * FROM "♂";
--Testcase 80:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE topogeometry;
--Testcase 81: -- ERR
SELECT * FROM "♂";
--Testcase 82:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE unionarg;
--Testcase 83: -- ERR
SELECT * FROM "♂";
--Testcase 84:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE validatetopology_returntype;
--Testcase 85: -- ERR
SELECT * FROM "♂";

--Testcase 86:
ALTER DOMAIN geometry RENAME TO geom0;
--Testcase 87:
ALTER DOMAIN geography RENAME TO geog0;
--Testcase 88:
CREATE DOMAIN geometry AS text;
--Testcase 89:
CREATE DOMAIN geography AS text;

--Testcase 90:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geometry;
--Testcase 91: -- ERR
SELECT * FROM "♂";
--Testcase 92:
ALTER FOREIGN TABLE "♂" ALTER COLUMN "geom" TYPE geography;
--Testcase 93: -- ERR
SELECT * FROM "♂";

--Testcase 004:
DROP EXTENSION sqlite_fdw CASCADE;
