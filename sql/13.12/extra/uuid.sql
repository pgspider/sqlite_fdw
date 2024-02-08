--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 44:
CREATE EXTENSION sqlite_fdw;
--Testcase 45:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

--Testcase 46:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

--Testcase 109:
CREATE FOREIGN TABLE "type_UUID"( "i" int OPTIONS (key 'true'), "u" uuid) SERVER sqlite_svr OPTIONS (table 'type_UUID');
--Testcase 110:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE text;
--Testcase 111:
INSERT INTO "type_UUID" ("i", "u") VALUES (1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
--Testcase 112:
INSERT INTO "type_UUID" ("i", "u") VALUES (2, 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11');
--Testcase 113:
INSERT INTO "type_UUID" ("i", "u") VALUES (3, '{a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}');
--Testcase 114:
INSERT INTO "type_UUID" ("i", "u") VALUES (4, 'a0eebc999c0b4ef8bb6d6bb9bd380a11');
--Testcase 115:
INSERT INTO "type_UUID" ("i", "u") VALUES (5, 'a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11');
--Testcase 116:
INSERT INTO "type_UUID" ("i", "u") VALUES (6, '{a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}');
--Testcase 117:
INSERT INTO "type_UUID" ("i", "u") VALUES (7, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12');
--Testcase 118:
INSERT INTO "type_UUID" ("i", "u") VALUES (8, 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12');
--Testcase 119:
INSERT INTO "type_UUID" ("i", "u") VALUES (9, '{b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12}');
--Testcase 120:
INSERT INTO "type_UUID" ("i", "u") VALUES (10, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 121:
INSERT INTO "type_UUID" ("i", "u") VALUES (11, 'b0eebc999c0b4ef8bb6d6bb9bd380a12');
--Testcase 122:
INSERT INTO "type_UUID" ("i", "u") VALUES (12, 'b0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a12');
--Testcase 123:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE bytea;
--Testcase 124:
INSERT INTO "type_UUID" ("i", "u") VALUES (13, decode('a0eebc999c0b4ef8bb6d6bb9bd380a11', 'hex'));
--Testcase 125:
INSERT INTO "type_UUID" ("i", "u") VALUES (14, decode('b0eebc999c0b4ef8bb6d6bb9bd380a12', 'hex'));
--Testcase 126:
INSERT INTO "type_UUID" ("i", "u") VALUES (15, decode('a0eebc999c0b4ef8bb6d6bb9bd380a11', 'hex'));
--Testcase 127:
INSERT INTO "type_UUID" ("i", "u") VALUES (16, decode('b0eebc999c0b4ef8bb6d6bb9bd380a12', 'hex'));
--Testcase 128:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE uuid;
--Testcase 129:
INSERT INTO "type_UUID" ("i", "u") VALUES (17, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
--Testcase 130:
INSERT INTO "type_UUID" ("i", "u") VALUES (18, 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11');
--Testcase 131:
INSERT INTO "type_UUID" ("i", "u") VALUES (19, '{a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}');
--Testcase 132:
INSERT INTO "type_UUID" ("i", "u") VALUES (20, 'a0eebc999c0b4ef8bb6d6bb9bd380a11');
--Testcase 133:
INSERT INTO "type_UUID" ("i", "u") VALUES (21, 'a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11');
--Testcase 134:
INSERT INTO "type_UUID" ("i", "u") VALUES (22, '{a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}');
--Testcase 135:
INSERT INTO "type_UUID" ("i", "u") VALUES (23, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12');
--Testcase 136:
INSERT INTO "type_UUID" ("i", "u") VALUES (24, 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12');
--Testcase 137:
INSERT INTO "type_UUID" ("i", "u") VALUES (25, '{b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12}');
--Testcase 138:
INSERT INTO "type_UUID" ("i", "u") VALUES (26, 'b0eebc999c0b4ef8bb6d6bb9bd380a12');
--Testcase 139:
INSERT INTO "type_UUID" ("i", "u") VALUES (27, 'b0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a12');
--Testcase 140:
INSERT INTO "type_UUID" ("i", "u") VALUES (28, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 141:
EXPLAIN VERBOSE
INSERT INTO "type_UUID" ("i", "u") VALUES (28, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 142:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (ADD column_type 'BLOB');
--Testcase 143:
INSERT INTO "type_UUID" ("i", "u") VALUES (29, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
--Testcase 144:
INSERT INTO "type_UUID" ("i", "u") VALUES (30, 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11');
--Testcase 145:
INSERT INTO "type_UUID" ("i", "u") VALUES (31, '{a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}');
--Testcase 146:
INSERT INTO "type_UUID" ("i", "u") VALUES (32, 'a0eebc999c0b4ef8bb6d6bb9bd380a11');
--Testcase 147:
INSERT INTO "type_UUID" ("i", "u") VALUES (33, 'a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11');
--Testcase 148:
INSERT INTO "type_UUID" ("i", "u") VALUES (34, '{a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}');
--Testcase 149:
INSERT INTO "type_UUID" ("i", "u") VALUES (35, 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12');
--Testcase 150:
INSERT INTO "type_UUID" ("i", "u") VALUES (36, 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12');
--Testcase 151:
INSERT INTO "type_UUID" ("i", "u") VALUES (37, '{b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12}');
--Testcase 152:
INSERT INTO "type_UUID" ("i", "u") VALUES (38, 'b0eebc999c0b4ef8bb6d6bb9bd380a12');
--Testcase 153:
INSERT INTO "type_UUID" ("i", "u") VALUES (39, 'b0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a12');
--Testcase 154:
INSERT INTO "type_UUID" ("i", "u") VALUES (40, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a12}');
--Testcase 155:
EXPLAIN VERBOSE
INSERT INTO "type_UUID" ("i", "u") VALUES (39, 'b0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a12');
--Testcase 156:
CREATE FOREIGN TABLE "type_UUID+"( "i" int OPTIONS (key 'true'), "u" uuid, "t" text, "l" smallint) SERVER sqlite_svr OPTIONS (table 'type_UUID+');
--Testcase 157:
SELECT * FROM "type_UUID+";
--Testcase 158:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'BLOB');
--Testcase 159:
SELECT * FROM "type_UUID+" where "u" = 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11';
--Testcase 160:
EXPLAIN VERBOSE
SELECT * FROM "type_UUID+" where "u" = 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11';
--Testcase 161:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'TEXT');
--Testcase 162:
SELECT * FROM "type_UUID+" where "u" = 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11';
--Testcase 163:
EXPLAIN VERBOSE
SELECT * FROM "type_UUID+" where "u" = 'A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11';
--Testcase 164:
SELECT * FROM "type_UUID+" where "u" = 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12';
--Testcase 165:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'BLOB');
--Testcase 166:
SELECT * FROM "type_UUID+" where "u" = 'B0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A12';
--Testcase 167:
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}' WHERE "i" = 25;
--Testcase 168:
EXPLAIN VERBOSE
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}' WHERE "i" = 25;
--Testcase 169:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'TEXT');
--Testcase 170:
EXPLAIN VERBOSE
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}' WHERE "i" = 25;
--Testcase 171:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'BLOB');
--Testcase 172:
DELETE FROM "type_UUID" WHERE "u" = 'b0eebc999c0b4ef8bb6d6bb9bd380a12';
--Testcase 173:
EXPLAIN VERBOSE
DELETE FROM "type_UUID" WHERE "u" = 'b0eebc999c0b4ef8bb6d6bb9bd380a12';
--Testcase 174:
SELECT * FROM "type_UUID+";
--Testcase 175:
DELETE FROM "type_UUID" WHERE "u" = 'a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11';
--Testcase 176:
SELECT * FROM "type_UUID+";
--Testcase 177:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'TEXT');
--Testcase 175:
DELETE FROM "type_UUID" WHERE "u" = 'b0eebc999c0b4ef8bb6d6bb9bd380a15';
--Testcase 176:
EXPLAIN VERBOSE
DELETE FROM "type_UUID" WHERE "u" = 'b0eebc999c0b4ef8bb6d6bb9bd380a15';
--Testcase 177:
SELECT * FROM "type_UUID+";
--Testcase 178:
INSERT INTO "type_UUID" ("i", "u") VALUES (41, '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}');
--Testcase 179:
SELECT * FROM "type_UUID+" WHERE "i" = 41;
--Testcase 180:
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-00000a15}' WHERE "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}';
--Testcase 181:
EXPLAIN VERBOSE
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-00000a15}' WHERE "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}';
--Testcase 182:
SELECT * FROM "type_UUID+";
--Testcase 183:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" OPTIONS (SET column_type 'BLOB');
--Testcase 184:
EXPLAIN VERBOSE
UPDATE "type_UUID" SET "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-bd380a15}' WHERE "u" = '{b0eebc99-9c0b4ef8-bb6d6bb9-00000a15}';
--Testcase 185:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE bytea;
--Testcase 186:
INSERT INTO "type_UUID" ("i", "u") VALUES (42, decode('a0eebc999c0b4ef8bb6d6bb9bd380a11f1', 'hex'));
--Testcase 187:
INSERT INTO "type_UUID" ("i", "u") VALUES (43, decode('b0eebc999c0b4ef8bb6d6bb9bd380a', 'hex'));
--Testcase 188:
ALTER FOREIGN TABLE "type_UUID" ALTER COLUMN "u" TYPE uuid;
--Testcase 189:
SELECT * FROM "type_UUID+" WHERE "i" = 42;
--Testcase 190:
SELECT * FROM "type_UUID+" WHERE "i" = 43;
--Testcase 191:
EXPLAIN VERBOSE
DELETE FROM "type_UUID" WHERE "i" IN (42, 43);
--Testcase 192:
DELETE FROM "type_UUID" WHERE "i" IN (42, 43);
--Testcase 193:
INSERT INTO "type_UUID" ("i", "u") VALUES (44, NULL);
--Testcase 194:
SELECT * FROM "type_UUID+";
--Testcase 195:
SELECT * FROM "type_UUID+" WHERE "u" IS NULL;
--Testcase 196:
SELECT * FROM "type_UUID+" WHERE "u" IS NOT NULL;
--Testcase 197:
EXPLAIN VERBOSE
SELECT * FROM "type_UUID+" WHERE "u" IS NULL;
--Testcase 198:
EXPLAIN VERBOSE
SELECT * FROM "type_UUID+" WHERE "u" IS NOT NULL;

--Testcase 47:
DROP EXTENSION sqlite_fdw CASCADE;
