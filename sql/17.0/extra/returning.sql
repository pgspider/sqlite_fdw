--SET log_min_messages TO DEBUG4;
--SET client_min_messages TO DEBUG4;
--Testcase 01:
CREATE EXTENSION sqlite_fdw;
--Testcase 02:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

--Testcase 03:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;
--Testcase 04:
IMPORT FOREIGN SCHEMA main EXCEPT ("types_PostGIS") FROM SERVER sqlite_svr INTO public;

--Testcase 05:
SELECT * FROM "type_STRING";
--Testcase 06:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE "type_STRING" SET col = '_' || substr(col, 2) RETURNING *;
--Testcase 07:
UPDATE "type_STRING" SET col = '_' || substr(col, 2) RETURNING *;
--Testcase 08:
SELECT * FROM "type_STRING";
--Testcase 09:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM "type_STRING" RETURNING *;
--Testcase 10:
DELETE FROM "type_STRING" RETURNING *;

--Testcase 11:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO "type_STRING"(col) VALUES ('string') ON CONFLICT DO NOTHING RETURNING *;
--Testcase 12:
INSERT INTO "type_STRING"(col) VALUES ('string') ON CONFLICT DO NOTHING RETURNING *;

--Testcase 13:
SELECT * FROM "type_BYTE";
--Testcase 14:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM "type_BYTE" RETURNING *;
--Testcase 15:
DELETE FROM "type_BYTE" RETURNING *;
--Testcase 16:
SELECT * FROM "type_SINT";
--Testcase 17:
DELETE FROM "type_SINT" RETURNING *;
--Testcase 18:
SELECT * FROM "type_BINT";
--Testcase 19:
DELETE FROM "type_BINT" RETURNING *;
--Testcase 20:
SELECT * FROM "type_INTEGER";
--Testcase 21:
DELETE FROM "type_INTEGER" RETURNING *;
--Testcase 22:
SELECT * FROM "type_FLOAT";
--Testcase 23:
DELETE FROM "type_FLOAT" RETURNING *;
--Testcase 24:
SELECT * FROM "type_DOUBLE";
--Testcase 25:
DELETE FROM "type_DOUBLE" RETURNING *;
--
set datestyle=ISO;
--Testcase 26:
SELECT * FROM "type_TIMESTAMP";
--Testcase 27:
DELETE FROM "type_TIMESTAMP" RETURNING *;
--Testcase 28:
SELECT * FROM "type_BLOB";
--Testcase 29:
DELETE FROM "type_BLOB" RETURNING *;
--Testcase 30:
ALTER TABLE "type_UUID" ALTER COLUMN "i" OPTIONS (ADD key 'true');
--Testcase 31:
DELETE FROM "type_UUID" RETURNING *;
--Testcase 32:
ALTER TABLE "type_BIT" ALTER COLUMN "i" OPTIONS (ADD key 'true');
--Testcase 33:
ALTER TABLE "type_BIT" ALTER COLUMN b TYPE bit(6);
--Testcase 34:
DELETE FROM "type_BIT" RETURNING *;

--Testcase 35:
SELECT * FROM typetest;
--Testcase 36:
INSERT INTO "type_STRING"(col) VALUES ('string') ON CONFLICT DO NOTHING RETURNING *;
--Testcase 37:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO "type_STRING"(col) VALUES ('string') ON CONFLICT DO NOTHING RETURNING *;
--Testcase 38:
INSERT INTO "type_BYTE"(col) VALUES ('c') RETURNING *;
--Testcase 39:
INSERT INTO "type_SINT"(col) VALUES (32767) RETURNING *;
--Testcase 40:
INSERT INTO "type_SINT"(col) VALUES (-32768) RETURNING *;
--Testcase 41:
INSERT INTO "type_BINT"(col) VALUES (9223372036854775807) RETURNING *;
--Testcase 42:
INSERT INTO "type_BINT"(col) VALUES (-9223372036854775808) RETURNING *;
--Testcase 43:
INSERT INTO "type_INTEGER"(col) VALUES (9223372036854775807) RETURNING *;

--Testcase 44:
INSERT INTO "type_FLOAT"(col) VALUES (3.1415) RETURNING *;
--Testcase 45:
INSERT INTO "type_DOUBLE"(col) VALUES (3.14159265) RETURNING *;
--Testcase 46:
INSERT INTO "type_TIMESTAMP" VALUES ('2017.11.06 12:34:56.789', '2017.11.06') RETURNING *;
--Testcase 47:
INSERT INTO "type_TIMESTAMP" VALUES ('2017.11.06 1:3:0', '2017.11.07') RETURNING *;
--Testcase 48:
INSERT INTO "type_BLOB"(col) VALUES (bytea('\xDEADBEEF')) RETURNING *;

--Testcase 49:
SELECT * FROM "type_DATE";
--Testcase 50:
INSERT INTO "type_DATE"(col) VALUES ('2021.02.23') RETURNING col;
--Testcase 51:
INSERT INTO "type_DATE"(col) VALUES ('2021/03/08') RETURNING col;
--Testcase 52:
INSERT INTO "type_DATE"(col) VALUES ('9999-12-30') RETURNING col;
--Testcase 53:
INSERT INTO "type_DATE"(col) VALUES ('2021.04.23') RETURNING col;
--Testcase 54:
INSERT INTO "type_DATE"(col) VALUES ('2021/03/09') RETURNING col;
--Testcase 55:
INSERT INTO "type_DATE"(col) VALUES ('9999-12-29') RETURNING col;
--Testcase 56:
SELECT * FROM "type_DATE";

--Testcase 57:
SELECT * FROM "type_TIME";
--Testcase 58:
INSERT INTO "type_TIME"(col) VALUES ('01:23:46') RETURNING col;
--Testcase 59:
INSERT INTO "type_TIME"(col) VALUES ('01:23:47.6789') RETURNING col;
--Testcase 60:
SELECT * FROM "type_TIME";

--Testcase 61:
CREATE FOREIGN TABLE type_JSON(col JSON OPTIONS (key 'true')) SERVER sqlite_svr OPTIONS (table 'type_TEXT');
--Testcase 62
SELECT * FROM type_JSON;
--Testcase 63:
INSERT INTO type_JSON(col) VALUES ('[1, 2, "foo", null]') RETURNING *;
--Testcase 64:
INSERT INTO type_JSON(col) VALUES ('{"bar": "baz", "balance": 7.77, "active": false}'::json) RETURNING *;
--Testcase 65:
SELECT * FROM type_JSON;
--Testcase 66:
DELETE FROM type_JSON RETURNING *;

--Testcase 70:
ALTER TABLE typetest ALTER COLUMN i OPTIONS (ADD key 'true');

--Testcase 71: (i integer, v varchar(10), c char(10), t text, d datetime, ti timestamp);
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO typetest VALUES (1, 'a', 'b', 'c', '2017.11.06 12:34:56.789', '2017.11.06 12:34:56.789') RETURNING *;
--Testcase 72: (i integer, v varchar(10), c char(10), t text, d datetime, ti timestamp);
INSERT INTO typetest VALUES (1, 'a', 'b', 'c', '2017.11.06 12:34:56.789', '2017.11.06 12:34:56.789') RETURNING *;
--Testcase 73:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO typetest VALUES (2, 'd', 'e', 'f', '2018.11.06 12:34:56.789', '2018.11.05 12:34:56.789') RETURNING d, c, t, i, ti, v;
--Testcase 74:
INSERT INTO typetest VALUES (2, 'd', 'e', 'f', '2018.11.06 12:34:56.789', '2018.11.05 12:34:56.789') RETURNING d, c, t, i, ti, v;
--Testcase 75:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO typetest VALUES (3, 'g', 'h', 'i', '2019.11.06 12:34:56.789', '2019.11.05 12:34:56.789') RETURNING d c_date, c c_char, t c_text, i c_int, ti c_timestamp, v c_varchar;
--Testcase 76:
INSERT INTO typetest VALUES (3, 'g', 'h', 'i', '2019.11.06 12:34:56.789', '2019.11.05 12:34:56.789') RETURNING d c_date, c c_char, t c_text, i c_int, ti c_timestamp, v c_varchar;
--Testcase 77:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO typetest VALUES (4, 'j', 'k', 'l', '2020.11.06 12:34:56.789', '2020.11.05 12:34:56.789') RETURNING ti c_timestamp;
--Testcase 78:
INSERT INTO typetest VALUES (4, 'j', 'k', 'l', '2020.11.06 12:34:56.789', '2020.11.05 12:34:56.789') RETURNING ti c_timestamp;
--Testcase 79:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO typetest VALUES (5, 'm', 'n', 'opqrs', '2020.11.06 12:34:56.789', '2020.11.05 12:34:56.789') RETURNING substr(t, 2) sst;
--Testcase 80:
INSERT INTO typetest VALUES (5, 'm', 'n', 'opqrs', '2020.11.06 12:34:56.789', '2020.11.05 12:34:56.789') RETURNING substr(t, 2) sst;

--Testcase 81: (i integer, v varchar(10), c char(10), t text, d datetime, ti timestamp);
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE typetest SET t='upd' WHERE i=1 RETURNING *;
--Testcase 82: (i integer, v varchar(10), c char(10), t text, d datetime, ti timestamp);
UPDATE typetest SET t='upd' WHERE i=1 RETURNING *;
--Testcase 83:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE typetest SET t='upd' WHERE i=2 RETURNING d, c, t, i, ti, v;
--Testcase 84:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE typetest SET t='upd' WHERE i=2 RETURNING d, c, t, i, ti, v;
--Testcase 85:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE typetest SET t='upd' WHERE i=3 RETURNING d c_date, c c_char, t c_text, i c_int, ti c_timestamp, v c_varchar;
--Testcase 86:
UPDATE typetest SET t='upd' WHERE i=3 RETURNING d c_date, c c_char, t c_text, i c_int, ti c_timestamp, v c_varchar;
--Testcase 87:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE typetest SET t='upd' WHERE i=4 RETURNING ti c_timestamp;
--Testcase 88:
UPDATE typetest SET t='upd' WHERE i=4 RETURNING ti c_timestamp;
--Testcase 89:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE typetest SET t='upd' WHERE i=5 RETURNING substr(c, 2) sst;
--Testcase 90:
UPDATE typetest SET t='upd' WHERE i=5 RETURNING substr(c, 2) sst;

--Testcase 91: (i integer, v varchar(10), c char(10), t text, d datetime, ti timestamp);
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM typetest WHERE i=1 RETURNING *;
--Testcase 92: (i integer, v varchar(10), c char(10), t text, d datetime, ti timestamp);
DELETE FROM typetest WHERE i=1 RETURNING *;
--Testcase 93:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM typetest WHERE i=2 RETURNING d, c, t, i, ti, v;
--Testcase 94:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM typetest WHERE i=2 RETURNING d, c, t, i, ti, v;
--Testcase 95:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM typetest WHERE i=3 RETURNING d c_date, c c_char, t c_text, i c_int, ti c_timestamp, v c_varchar;
--Testcase 96:
DELETE FROM typetest WHERE i=3 RETURNING d c_date, c c_char, t c_text, i c_int, ti c_timestamp, v c_varchar;
--Testcase 97:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM typetest WHERE i=4 RETURNING ti c_timestamp;
--Testcase 98:
DELETE FROM typetest WHERE i=4 RETURNING ti c_timestamp;
--Testcase 99:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM typetest WHERE i=5 RETURNING substr(c, 2) sst;
--Testcase 100:
DELETE FROM typetest WHERE i=5 RETURNING substr(c, 2) sst;

--Testcase 101:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO typetest VALUES (6, 'p', 'q', 'r', '2021.11.06 12:34:56.789', '2021.11.05 12:34:56.789') RETURNING 'ok' t;
--Testcase 102:
INSERT INTO typetest VALUES (6, 'p', 'q', 'r', '2021.11.06 12:34:56.789', '2021.11.05 12:34:56.789') RETURNING 'ok' t;
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE typetest SET t='upd' WHERE i=6 RETURNING 'ok1';
--Testcase 103:
UPDATE typetest SET t='upd' WHERE i=6 RETURNING 'ok1';
--Testcase 104:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM typetest WHERE i=6 RETURNING 'del';
--Testcase 105:
DELETE FROM typetest WHERE i=6 RETURNING 'del';

-- Test UPDATE/DELETE with RETURNING on a three-table join
--Testcase 110:
INSERT INTO ret_base (c1,c2,c3)
  SELECT id, id - 1200, to_char(id, 'FM00000') FROM generate_series(1201, 1300) id RETURNING *;
--Testcase 111:
SELECT * FROM ret_base;
--Testcase 112:
INSERT INTO ret_j1t (c1, c2, c3) VALUES (8, 5, 14.2), (7, 2, -14.3), (12, 3, 0.001), (9, 3, -0.5) RETURNING *;
--Testcase 113:
SELECT * FROM ret_j1t;
--Testcase 114:
INSERT INTO ret_j2t (c1, c2, c3) VALUES (8, 18, 5.8), (7, 41, 2.1), (12, 28, -0.09), (9, 14, +17.4) RETURNING *;
--Testcase 115:
SELECT * FROM ret_j2t;

--Testcase 116:
UPDATE ret_base SET c3 = 'foo+' RETURNING ret_base.*, ret_base;

--Testcase 117:
EXPLAIN (verbose, costs off)
UPDATE ret_base SET c3 = 'foo'
  FROM ret_j1t INNER JOIN ret_j2t ON (ret_j1t.c1 = ret_j2t.c1)
  WHERE ret_base.c1 > 1200 AND ret_base.c2 = ret_j1t.c1
  RETURNING ret_base, ret_base.*, ret_j1t, ret_j1t.*;       -- can be pushed down
--Testcase 118:
UPDATE ret_base SET c3 = 'foo'
  FROM ret_j1t INNER JOIN ret_j2t ON (ret_j1t.c1 = ret_j2t.c1)
  WHERE ret_base.c1 > 1200 AND ret_base.c2 = ret_j1t.c1
  RETURNING ret_base, ret_base.*, ret_j1t, ret_j1t.*;
--Testcase 119:
EXPLAIN (verbose, costs off)
DELETE FROM ret_base
  USING ret_j1t LEFT JOIN ret_j2t ON (ret_j1t.c1 = ret_j2t.c1)
  WHERE ret_base.c1 > 1200 AND ret_base.c1 % 10 = 0 AND ret_base.c2 = ret_j1t.c1
  RETURNING 100;                          -- can be pushed down
--Testcase 120:
DELETE FROM ret_base
  USING ret_j1t LEFT JOIN ret_j2t ON (ret_j1t.c1 = ret_j2t.c1)
  WHERE ret_base.c1 > 1200 AND ret_base.c1 % 10 = 0 AND ret_base.c2 = ret_j1t.c1
  RETURNING 100;

--Testcase 121: 
DELETE FROM ret_base RETURNING ret_base.*, ret_base;

--Testcase 122: Test that trigger on remote table works as expected
CREATE OR REPLACE FUNCTION F_BRTRIG() RETURNS trigger AS $$
BEGIN
    NEW.c3 = NEW.c3 || '_trig_update';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--Testcase 123:
CREATE TRIGGER t1_br_insert BEFORE INSERT OR UPDATE
    ON ret_base FOR EACH ROW EXECUTE PROCEDURE F_BRTRIG();
--Testcase 124:
INSERT INTO ret_base (c1,c2,c3) VALUES (1208, 818, 'fff') RETURNING *;
--Testcase 125:
INSERT INTO ret_base (c1,c2,c3) VALUES (1218, 818, 'ggg') RETURNING *;
--Testcase 126:
EXPLAIN (verbose, costs off)
UPDATE ret_base SET c2 = c2 + 600 WHERE c1 % 10 = 8 AND c1 < 1300 RETURNING *;
--Testcase 127:
UPDATE ret_base SET c2 = c2 + 600 WHERE c1 % 10 = 8 AND c1 < 1300 RETURNING *;

--Testcase 128:
EXPLAIN (verbose, costs off)
DELETE FROM ret_base WHERE ret_base.c1 > 1200 RETURNING ret_base.*, ret_base;
--Testcase 129:
DELETE FROM ret_base WHERE ret_base.c1 > 1200 RETURNING ret_base.*, ret_base;

--Testcase 130:
CREATE SERVER sqlite_svr_ins FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/core.db');
--Testcase 131:
CREATE FOREIGN TABLE inserttest01 (col1 int4, col2 int4 NOT NULL, col3 text default 'testing') SERVER sqlite_svr_ins;
--Testcase 132:
CREATE VIEW inserttest01_view_wco AS
SELECT * FROM inserttest01 WHERE col1 > 20 AND col2 = 50
WITH CHECK OPTION;
--Testcase 133:
CREATE VIEW inserttest01_view AS
SELECT * FROM inserttest01 WHERE col1 > 20 AND col2 = 50;
--Testcase 134: ok
INSERT INTO inserttest01_view values(10, 40, 'uuuuu');
--Testcase 135: no!
INSERT INTO inserttest01_view_wco values(10, 50, 'uuuuu');
--Testcase 136: no!
INSERT INTO inserttest01_view_wco values(25, 40, 'uuuuu');
--Testcase 137: ok
INSERT INTO inserttest01_view values(11, 42, 'uuuuu') RETURNING *;
--Testcase 138:
ALTER TABLE inserttest01 ALTER COLUMN col1 OPTIONS (ADD key 'true');
--Testcase 139:
DELETE FROM inserttest01 RETURNING *;

--Testcase 140:
INSERT INTO "type_STRING"(col) VALUES ('string_ocdn') ON CONFLICT DO NOTHING;
--Testcase 141:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO "type_STRING"(col) VALUES ('string_ocdn') ON CONFLICT DO NOTHING;
--Testcase 142:
DELETE FROM "type_STRING";

--Testcase 200:
DROP EXTENSION sqlite_fdw CASCADE;
