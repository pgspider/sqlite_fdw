--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 001:
CREATE EXTENSION sqlite_fdw;
--Testcase 002:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

--Testcase 003:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

--Testcase 009:
CREATE FOREIGN TABLE "type_UUID"( "i" int OPTIONS (key 'true'), "u" uuid) SERVER sqlite_svr OPTIONS (table 'type_UUID');
--Testcase 010:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE text;
--Testcase 011:
INSERT INTO "type_UUID" ("i", "u") VALUES (1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
--Testcase 012:
INSERT INTO "type_UUID" ("i", "u") VALUES (2, 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11');
--Testcase 013:
INSERT INTO "type_UUID" ("i", "u") VALUES (3, '{a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}');
--Testcase 014:
INSERT INTO "type_UUID" ("i", "u") VALUES (4, 'a0eebc999c0b4ef8bb6d6bb9bd380a11');
--Testcase 015:
INSERT INTO "type_UUID" ("i", "u") VALUES (5, 'a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11');
--Testcase 016:
INSERT INTO "type_UUID" ("i", "u") VALUES (6, '{a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}');
--Testcase 017:
INSERT INTO "type_UUID" ("i", "u") VALUES (7, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12');
--Testcase 018:
INSERT INTO "type_UUID" ("i", "u") VALUES (8, 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12');
--Testcase 019:
INSERT INTO "type_UUID" ("i", "u") VALUES (9, '{b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12}');
--Testcase 020:
INSERT INTO "type_UUID" ("i", "u") VALUES (10, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 021:
INSERT INTO "type_UUID" ("i", "u") VALUES (11, 'b0eebc999c0b4ef8bb6d6bb9bd380a12');
--Testcase 022:
INSERT INTO "type_UUID" ("i", "u") VALUES (12, 'b0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a12');
--Testcase 023:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE bytea;
--Testcase 024:
INSERT INTO "type_UUID" ("i", "u") VALUES (13, decode('a0eebc999c0b4ef8bb6d6bb9bd380a11', 'hex'));
--Testcase 025:
INSERT INTO "type_UUID" ("i", "u") VALUES (14, decode('b0eebc999c0b4ef8bb6d6bb9bd380a12', 'hex'));
--Testcase 026:
INSERT INTO "type_UUID" ("i", "u") VALUES (15, decode('a0eebc999c0b4ef8bb6d6bb9bd380a11', 'hex'));
--Testcase 027:
INSERT INTO "type_UUID" ("i", "u") VALUES (16, decode('b0eebc999c0b4ef8bb6d6bb9bd380a12', 'hex'));
--Testcase 028:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE uuid;
--Testcase 029:
INSERT INTO "type_UUID" ("i", "u") VALUES (17, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
--Testcase 030:
INSERT INTO "type_UUID" ("i", "u") VALUES (18, 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11');
--Testcase 031:
INSERT INTO "type_UUID" ("i", "u") VALUES (19, '{a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}');
--Testcase 032:
INSERT INTO "type_UUID" ("i", "u") VALUES (20, 'a0eebc999c0b4ef8bb6d6bb9bd380a11');
--Testcase 033:
INSERT INTO "type_UUID" ("i", "u") VALUES (21, 'a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11');
--Testcase 034:
INSERT INTO "type_UUID" ("i", "u") VALUES (22, '{a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}');
--Testcase 035:
INSERT INTO "type_UUID" ("i", "u") VALUES (23, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12');
--Testcase 036:
INSERT INTO "type_UUID" ("i", "u") VALUES (24, 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12');
--Testcase 037:
INSERT INTO "type_UUID" ("i", "u") VALUES (25, '{b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12}');
--Testcase 038:
INSERT INTO "type_UUID" ("i", "u") VALUES (26, 'b0eebc999c0b4ef8bb6d6bb9bd380a12');
--Testcase 039:
INSERT INTO "type_UUID" ("i", "u") VALUES (27, 'b0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a12');
--Testcase 040:
INSERT INTO "type_UUID" ("i", "u") VALUES (28, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 041:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO "type_UUID" ("i", "u") VALUES (28, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 042:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (ADD column_type 'BLOB');
--Testcase 043:
INSERT INTO "type_UUID" ("i", "u") VALUES (29, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
--Testcase 044:
INSERT INTO "type_UUID" ("i", "u") VALUES (30, 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11');
--Testcase 045:
INSERT INTO "type_UUID" ("i", "u") VALUES (31, '{a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}');
--Testcase 046:
INSERT INTO "type_UUID" ("i", "u") VALUES (32, 'a0eebc999c0b4ef8bb6d6bb9bd380a11');
--Testcase 047:
INSERT INTO "type_UUID" ("i", "u") VALUES (33, 'a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11');
--Testcase 048:
INSERT INTO "type_UUID" ("i", "u") VALUES (34, '{a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}');
--Testcase 049:
INSERT INTO "type_UUID" ("i", "u") VALUES (35, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12');
--Testcase 050:
INSERT INTO "type_UUID" ("i", "u") VALUES (36, 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12');
--Testcase 051:
INSERT INTO "type_UUID" ("i", "u") VALUES (37, '{b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12}');
--Testcase 052:
INSERT INTO "type_UUID" ("i", "u") VALUES (38, 'b0eebc999c0b4ef8bb6d6bb9bd380a12');
--Testcase 053:
INSERT INTO "type_UUID" ("i", "u") VALUES (39, 'b0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a12');
--Testcase 054:
INSERT INTO "type_UUID" ("i", "u") VALUES (40, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 055:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO "type_UUID" ("i", "u") VALUES (39, 'b0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a12');
--Testcase 056:
CREATE FOREIGN TABLE "type_UUID+"( "i" int OPTIONS (key 'true'), "u" uuid, "t" text, "l" smallint) SERVER sqlite_svr OPTIONS (table 'type_UUID+');
--Testcase 057:
SELECT * FROM "type_UUID+";
--Testcase 058:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'BLOB');
--Testcase 059:
SELECT * FROM "type_UUID+" where "u" = 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11';
--Testcase 060:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM "type_UUID+" where "u" = 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11';
--Testcase 061:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'TEXT');
--Testcase 062:
SELECT * FROM "type_UUID+" where "u" = 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11';
--Testcase 063:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM "type_UUID+" where "u" = 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11';
--Testcase 064:
SELECT * FROM "type_UUID+" where "u" = 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12';
--Testcase 065:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'BLOB');
--Testcase 066:
SELECT * FROM "type_UUID+" where "u" = 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12';
--Testcase 067:
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}' WHERE "i" = 25;
--Testcase 068:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}' WHERE "i" = 25;
--Testcase 069:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'TEXT');
--Testcase 070:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}' WHERE "i" = 25;
--Testcase 071:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'BLOB');
--Testcase 072:
DELETE FROM "type_UUID" WHERE "u" = 'b0eebc999c0b4ef8bb6d6bb9bd380a12';
--Testcase 073:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM "type_UUID" WHERE "u" = 'b0eebc999c0b4ef8bb6d6bb9bd380a12';
--Testcase 074:
SELECT * FROM "type_UUID+";
--Testcase 075:
DELETE FROM "type_UUID" WHERE "u" = 'a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11';
--Testcase 076:
SELECT * FROM "type_UUID+";
--Testcase 077:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'TEXT');
--Testcase 075:
DELETE FROM "type_UUID" WHERE "u" = 'b0eebc999c0b4ef8bb6d6bb9bd380a15';
--Testcase 076:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM "type_UUID" WHERE "u" = 'b0eebc999c0b4ef8bb6d6bb9bd380a15';
--Testcase 077:
SELECT * FROM "type_UUID+";
--Testcase 078:
INSERT INTO "type_UUID" ("i", "u") VALUES (41, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}');
--Testcase 079:
SELECT * FROM "type_UUID+" WHERE "i" = 41;
--Testcase 080:
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-00000a15}' WHERE "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}';
--Testcase 081:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-00000a15}' WHERE "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}';
--Testcase 082:
SELECT * FROM "type_UUID+";
--Testcase 083:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'BLOB');
--Testcase 084:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}' WHERE "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-00000a15}';
--Testcase 085:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE bytea;
--Testcase 086:
INSERT INTO "type_UUID" ("i", "u") VALUES (42, decode('a0eebc999c0b4ef8bb6d6bb9bd380a11f1', 'hex'));
--Testcase 087:
INSERT INTO "type_UUID" ("i", "u") VALUES (43, decode('b0eebc999c0b4ef8bb6d6bb9bd380a', 'hex'));
--Testcase 088:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE uuid;
--Testcase 089:
SELECT * FROM "type_UUID+" WHERE "i" = 42;
--Testcase 090:
SELECT * FROM "type_UUID+" WHERE "i" = 43;
--Testcase 091:
EXPLAIN (VERBOSE, COSTS OFF)
DELETE FROM "type_UUID" WHERE "i" IN (42, 43);
--Testcase 092:
DELETE FROM "type_UUID" WHERE "i" IN (42, 43);
--Testcase 093:
INSERT INTO "type_UUID" ("i", "u") VALUES (44, NULL);
--Testcase 094:
SELECT * FROM "type_UUID+";
--Testcase 095:
SELECT * FROM "type_UUID+" WHERE "u" IS NULL;
--Testcase 096:
SELECT * FROM "type_UUID+" WHERE "u" IS NOT NULL;
--Testcase 097:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM "type_UUID+" WHERE "u" IS NULL;
--Testcase 098:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM "type_UUID+" WHERE "u" IS NOT NULL;

--Testcase 100:
CREATE FOREIGN TABLE "type_UUIDpk" (col uuid OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 101:
ALTER FOREIGN TABLE "type_UUIDpk" ALTER COLUMN col OPTIONS (ADD column_type 'TEXT');
--Testcase 102:
INSERT INTO "type_UUIDpk" VALUES ('{a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}');
--Testcase 103:
INSERT INTO "type_UUIDpk" VALUES ('{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 104:
SELECT * FROM "type_UUIDpk";
--Testcase 105: ERR - primary key
INSERT INTO "type_UUIDpk" VALUES ('{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 106:
ALTER FOREIGN TABLE "type_UUIDpk" ALTER COLUMN col OPTIONS (SET column_type 'BLOB');
--Testcase 107: NO ERR, but the same semantics!
INSERT INTO "type_UUIDpk" VALUES ('{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 108:
SELECT * FROM "type_UUIDpk";
--Testcase 109:
DELETE FROM "type_UUIDpk";

--Testcase 200:
DROP EXTENSION sqlite_fdw CASCADE;
