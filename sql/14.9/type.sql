--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 44:
CREATE EXTENSION sqlite_fdw;
--Testcase 45:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');

--Testcase 46:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_svr INTO public;

--Testcase 1:
INSERT INTO "type_STRING"(col) VALUES ('string');
--Testcase 4:
INSERT INTO "type_BYTE"(col) VALUES ('c');
--Testcase 5:
INSERT INTO "type_SINT"(col) VALUES (32767);
--Testcase 6:
INSERT INTO "type_SINT"(col) VALUES (-32768);
--Testcase 7:
INSERT INTO "type_BINT"(col) VALUES (9223372036854775807);
--Testcase 8:
INSERT INTO "type_BINT"(col) VALUES (-9223372036854775808);
--Testcase 9:
INSERT INTO "type_INTEGER"(col) VALUES (9223372036854775807);

--Testcase 10:
INSERT INTO "type_FLOAT"(col) VALUES (3.1415);
--Testcase 11:
INSERT INTO "type_DOUBLE"(col) VALUES (3.14159265);
--Testcase 12:
INSERT INTO "type_TIMESTAMP" VALUES ('2017.11.06 12:34:56.789', '2017.11.06');
--Testcase 13:
INSERT INTO "type_TIMESTAMP" VALUES ('2017.11.06 1:3:0', '2017.11.07');
--Testcase 14:
INSERT INTO "type_BLOB"(col) VALUES (bytea('\xDEADBEEF'));
--Testcase 15:
INSERT INTO typetest VALUES(1,'a', 'b', 'c','2017.11.06 12:34:56.789', '2017.11.06 12:34:56.789' ) ;

--Testcase 16:
SELECT * FROM "type_STRING";
--Testcase 18:
SELECT * FROM "type_BYTE";
--Testcase 19:
SELECT * FROM "type_SINT";
--Testcase 20:
SELECT * FROM "type_BINT";
--Testcase 21:
SELECT * FROM "type_INTEGER";
--Testcase 22:
SELECT * FROM "type_FLOAT";
--Testcase 23:
SELECT * FROM "type_DOUBLE";
set datestyle=ISO;
--Testcase 24:
SELECT * FROM "type_TIMESTAMP";
--Testcase 25:
SELECT * FROM "type_BLOB";
--Testcase 26:
SELECT * FROM typetest;

--Testcase 27:
insert into "type_STRING" values('TYPE');
--Testcase 28:
insert into "type_STRING" values('type');

-- not pushdown
--Testcase 29:
SELECT  *FROM "type_STRING" WHERE col like 'TYP%';
--Testcase 30:
EXPLAIN SELECT  *FROM "type_STRING" WHERE col like 'TYP%';
-- pushdown
--Testcase 31:
SELECT  *FROM "type_STRING" WHERE col ilike 'typ%';
--Testcase 32:
EXPLAIN SELECT  *FROM "type_STRING" WHERE col ilike 'typ%';

--Testcase 33:
SELECT  *FROM "type_STRING" WHERE col ilike 'typ%' and col like 'TYPE';
--Testcase 34:
EXPLAIN SELECT  *FROM "type_STRING" WHERE col ilike 'typ%' and col like 'TYPE';

--Testcase 35:
SELECT * FROM "type_TIMESTAMP";

--Testcase 36:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM  "type_TIMESTAMP" WHERE col > date ('2017.11.06 12:34:56.789') ;
--Testcase 37:
SELECT * FROM  "type_TIMESTAMP" WHERE col > date ('2017.11.06 12:34:56.789') ;

--Testcase 38:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM  "type_TIMESTAMP" WHERE col::text > date ('2017.11.06 12:34:56.789')::text ;
--Testcase 39:
SELECT * FROM  "type_TIMESTAMP" WHERE col::text > date ('2017.11.06 12:34:56.789')::text ;

--Testcase 40:
EXPLAIN  (VERBOSE, COSTS OFF) SELECT * FROM  "type_TIMESTAMP" WHERE col > b - interval '1 hour'; 
--Testcase 41:
SELECT * FROM  "type_TIMESTAMP" WHERE col > b - interval '1 hour';

--Testcase 42:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM  "type_TIMESTAMP" WHERE col > b;
--Testcase 43:
SELECT * FROM  "type_TIMESTAMP" WHERE col > b;

--Testcase 48:
INSERT INTO "type_DATE"(col) VALUES ('2021.02.23');
--Testcase 49:
INSERT INTO "type_DATE"(col) VALUES ('2021/03/08');
--Testcase 50:
INSERT INTO "type_DATE"(col) VALUES ('9999-12-30');
--Testcase 58:
SELECT * FROM "type_DATE";

--Testcase 51:
INSERT INTO "type_TIME"(col) VALUES ('01:23:45');
--Testcase 52:
INSERT INTO "type_TIME"(col) VALUES ('01:23:45.6789');
--Testcase 59:
SELECT * FROM "type_TIME";

--Testcase 60:
EXPLAIN VERBOSE
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c17, c18, c19, c2, c21, c22, c23, c24 FROM alltypetest;
--Testcase 61:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15,  c17, c18, c19, c2, c21, c22, c23, c24 FROM alltypetest;

--Testcase 53:
CREATE FOREIGN TABLE type_JSON(col JSON OPTIONS (key 'true')) SERVER sqlite_svr OPTIONS (table 'type_TEXT');
--Testcase 54:
INSERT INTO type_JSON(col) VALUES ('[1, 2, "foo", null]');
--Testcase 55:
INSERT INTO type_JSON(col) VALUES ('{"bar": "baz", "balance": 7.77, "active": false}'::json);
--Testcase 56
SELECT * FROM type_JSON;
--Testcase 57
DELETE FROM type_JSON;

-- drop column
--Testcase 62:
DROP FOREIGN TABLE IF EXISTS "type_BOOLEAN";
--Testcase 63:
CREATE FOREIGN TABLE "type_BOOLEAN" (i int, b boolean) SERVER sqlite_svr;
--Testcase 64:
ALTER FOREIGN TABLE "type_BOOLEAN" DROP COLUMN i;
--Testcase 65:
SELECT * FROM "type_BOOLEAN"; -- OK

-- define INTEGER as TEXT column
--Testcase 67:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE text;
--Testcase 68:
SELECT * FROM "type_INTEGER"; -- OK

-- define INTEGER as bpchar
--Testcase 69:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE char(30);
--Testcase 70:
SELECT * FROM "type_INTEGER"; -- OK
-- define INTEGER as varchar
--Testcase 71:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE varchar(30);
--Testcase 72:
SELECT * FROM "type_INTEGER"; -- OK

-- define INTEGER as name
--Testcase 73:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE name;
--Testcase 74:
SELECT * FROM "type_INTEGER"; -- OK

-- define INTEGER as json
--Testcase 75:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE json;
--Testcase 76:
SELECT * FROM "type_INTEGER"; -- OK

-- define INTEGER as time
--Testcase 77:
DELETE FROM "type_INTEGER";
--Testcase 78:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE int;
--Testcase 79:
INSERT INTO "type_INTEGER" VALUES (120506);
--Testcase 80:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE time;
--Testcase 81:
SELECT * FROM "type_INTEGER"; -- OK

-- define INTEGER as date
--Testcase 82:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE date;
--Testcase 83:
SELECT * FROM "type_INTEGER"; -- OK

--Testcase 84:
ALTER FOREIGN TABLE "type_INTEGER" ALTER COLUMN col TYPE int;

--Testcase 85:
INSERT INTO "type_DOUBLE" VALUES (1.3e-5);
--Testcase 86:
SELECT * FROM "type_DOUBLE";

-- define DOUBLE as TEXT column
--Testcase 87:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE text;
--Testcase 88:
SELECT * FROM "type_DOUBLE"; -- OK

-- define DOUBLE as bpchar
--Testcase 89:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE char(30);
--Testcase 90:
SELECT * FROM "type_DOUBLE"; -- OK
-- define DOUBLE as varchar
--Testcase 91:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE varchar(30);
--Testcase 92:
SELECT * FROM "type_DOUBLE"; -- OK

-- define DOUBLE as name
--Testcase 93:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE name;
--Testcase 94:
SELECT * FROM "type_DOUBLE"; -- OK

-- define DOUBLE as json
--Testcase 95:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE json;
--Testcase 96:
SELECT * FROM "type_DOUBLE"; -- OK

--Testcase 97:
DELETE FROM "type_DOUBLE";
--Testcase 98:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE float8;
--Testcase 99:
INSERT INTO "type_DOUBLE" VALUES (120506.12);

-- define DOUBLE as time
--Testcase 100:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE time;
--Testcase 101:
SELECT * FROM "type_DOUBLE"; -- OK

--Testcase 102:
DELETE FROM "type_DOUBLE";
--Testcase 103:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE float8;
--Testcase 104:
INSERT INTO "type_DOUBLE" VALUES (1999.012);
-- define DOUBLE as date
--Testcase 105:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE date;
--Testcase 106:
SELECT * FROM "type_DOUBLE"; -- OK

--Testcase 107:
ALTER FOREIGN TABLE "type_DOUBLE" ALTER COLUMN col TYPE float8;

--Testcase 108:
DROP FOREIGN TABLE IF EXISTS "type_UUID";
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

--Testcase 199:
DROP FOREIGN TABLE IF EXISTS "type_BIT";
--Testcase 200:
CREATE FOREIGN TABLE "type_BIT"( "i" int OPTIONS (key 'true'), "b" bit(6)) SERVER sqlite_svr OPTIONS (table 'type_BIT');
--Testcase 201:
DROP FOREIGN TABLE IF EXISTS "type_BIT+";
--Testcase 202:
CREATE FOREIGN TABLE "type_BIT+"( "i" int OPTIONS (key 'true'), "b" bit(6), "t" text, "l" smallint, "bi" bigint OPTIONS (column_name 'b')) SERVER sqlite_svr OPTIONS (table 'type_BIT+');
--Testcase 203: type mismatch
INSERT INTO "type_BIT" ("i", "b") VALUES (1, 1);
--Testcase 204: type mismatch
INSERT INTO "type_BIT" ("i", "b") VALUES (2, 2);
--Testcase 205: improper data length
INSERT INTO "type_BIT" ("i", "b") VALUES (3, '1');
--Testcase 206: improper data length
INSERT INTO "type_BIT" ("i", "b") VALUES (4, '10');
--Testcase 207: improper data length
INSERT INTO "type_BIT" ("i", "b") VALUES (5, '101');
--Testcase 208:
INSERT INTO "type_BIT" ("i", "b") VALUES (6, '110110');
--Testcase 209:
INSERT INTO "type_BIT" ("i", "b") VALUES (7, '111001');
--Testcase 210:
INSERT INTO "type_BIT" ("i", "b") VALUES (8, '110000');
--Testcase 211:
INSERT INTO "type_BIT" ("i", "b") VALUES (9, '100001');
--Testcase 212: type mismatch with proper data length
INSERT INTO "type_BIT" ("i", "b") VALUES (10, 53);
--Testcase 213:
SELECT * FROM "type_BIT+";
--Testcase 214:
SELECT * FROM "type_BIT" WHERE b < '110110';
--Testcase 215:
SELECT * FROM "type_BIT" WHERE b > '110110';
--Testcase 216:
SELECT * FROM "type_BIT" WHERE b = '110110';

--Testcase 217:
DROP FOREIGN TABLE IF EXISTS "type_VARBIT";
--Testcase 218:
CREATE FOREIGN TABLE "type_VARBIT"( "i" int OPTIONS (key 'true'), "b" varbit(70)) SERVER sqlite_svr OPTIONS (table 'type_VARBIT');
--Testcase 219:
DROP FOREIGN TABLE IF EXISTS "type_VARBIT+";
--Testcase 220:
CREATE FOREIGN TABLE "type_VARBIT+"( "i" int OPTIONS (key 'true'), "b" varbit(70), "t" text, "l" smallint) SERVER sqlite_svr OPTIONS (table 'type_VARBIT+');
--Testcase 221:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (1, '1');
--Testcase 222:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (2, '10');
--Testcase 223:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (3, '11');
--Testcase 224:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (4, '100');
--Testcase 225:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (5, '101');
--Testcase 226:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (6, '110110');
--Testcase 227:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (7, '111001');
--Testcase 228:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (8, '110000');
--Testcase 229:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (9, '100001');
--Testcase 230:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (10, '0100100101011001010010101000111110110101101101111011000101010');
--Testcase 231:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (11, '01001001010110010100101010001111101101011011011110110001010101');

--Testcase 232
SELECT * FROM "type_VARBIT+";
--Testcase 233:
SELECT * FROM "type_VARBIT+" WHERE b < '110110';
--Testcase 234:
SELECT * FROM "type_VARBIT+" WHERE b > '110110';
--Testcase 235:
SELECT * FROM "type_VARBIT+" WHERE b = '110110';

--Testcase 236:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (12, '010010010101100101001010100011111011010110110111101100010101010');
--Testcase 237:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (13, '0100100101011001010010101000111110110101101101111011000101010101');
--Testcase 238: very long bit string, expected ERROR, 65 bits
INSERT INTO "type_VARBIT" ("i", "b") VALUES (14, '01001001010110010100101010001111101101011011011110110001010101010');
--Testcase 239:
SELECT * FROM "type_VARBIT+" WHERE "i" > 10;

--Testcase 240:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" | b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 241:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" & b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 242:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" # b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 243:
SELECT "i", "b", "b" >> 2 "res" FROM "type_BIT";
--Testcase 244:
SELECT "i", "b", "b" << 3 "res" FROM "type_BIT";
--Testcase 245:
SELECT "i", "b", ~ "b" "res" FROM "type_BIT";
--Testcase 246:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" | b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 247:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" & b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 248:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" # b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 249:
EXPLAIN VERBOSE
SELECT "i", "b", "b" >> 2 "res" FROM "type_BIT";
--Testcase 250:
EXPLAIN VERBOSE
SELECT "i", "b", "b" << 3 "res" FROM "type_BIT";
--Testcase 251:
EXPLAIN VERBOSE
SELECT "i", "b", ~ "b" "res" FROM "type_BIT";

--Testcase 252:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" | b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 253:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" & b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 254:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" # b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 255:
SELECT "i", "b", "b" >> 2 "res" FROM "type_VARBIT";
--Testcase 256:
SELECT "i", "b", "b" << 3 "res" FROM "type_VARBIT";
--Testcase 257:
SELECT "i", "b", ~ "b" "res" FROM "type_VARBIT";
--Testcase 258:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" | b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 259:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" & b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 260:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" # b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 261:
EXPLAIN VERBOSE
SELECT "i", "b", "b" >> 2 "res" FROM "type_VARBIT";
--Testcase 262:
EXPLAIN VERBOSE
SELECT "i", "b", "b" << 3 "res" FROM "type_VARBIT";
--Testcase 263:
EXPLAIN VERBOSE
SELECT "i", "b", ~ "b" "res" FROM "type_VARBIT";

--Testcase 264:
SELECT "i", "b", "b" & B'101011' "res" FROM "type_BIT";
--Testcase 265:
SELECT "i", "b", "b" | B'101011' "res" FROM "type_BIT";
--Testcase 266:
SELECT "i", "b", "b" # B'101011' "res" FROM "type_BIT";
--Testcase 267:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" & B'101011') IS NOT NULL;
--Testcase 268:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" | B'101011') IS NOT NULL;
--Testcase 269:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" # B'101011') IS NOT NULL;
--Testcase 270:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" >> 1) IS NOT NULL;
--Testcase 271:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" << 2) IS NOT NULL;
--Testcase 272:
SELECT "i", "b" FROM "type_BIT" WHERE (~ "b") IS NOT NULL;
--Testcase 273:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" & B'101011') IS NOT NULL;
--Testcase 274:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" | B'101011') IS NOT NULL;
--Testcase 275:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" # B'101011') IS NOT NULL;
--Testcase 276:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" >> 1) IS NOT NULL;
--Testcase 277:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" << 2) IS NOT NULL;
--Testcase 278:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE (~ "b") IS NOT NULL;

--Testcase 279:
SELECT "i", "b", "b" & B'101011' "res" FROM "type_BIT";
--Testcase 280:
SELECT "i", "b", "b" | B'101011' "res" FROM "type_BIT";
--Testcase 281:
SELECT "i", "b", "b" # B'101011' "res" FROM "type_BIT";
--Testcase 282:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" & B'101011') IS NOT NULL;
--Testcase 283:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" | B'101011') IS NOT NULL;
--Testcase 284:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" # B'101011') IS NOT NULL;
--Testcase 285:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" >> 1) IS NOT NULL;
--Testcase 286:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" << 2) IS NOT NULL;
--Testcase 287:
SELECT "i", "b" FROM "type_BIT" WHERE (~ "b") IS NOT NULL;
--Testcase 288:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" & B'101011') IS NOT NULL;
--Testcase 289:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" | B'101011') IS NOT NULL;
--Testcase 290:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" # B'101011') IS NOT NULL;
--Testcase 291:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" >> 1) IS NOT NULL;
--Testcase 292:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" << 2) IS NOT NULL;
--Testcase 293:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE (~ "b") IS NOT NULL;

--Testcase 47:
DROP EXTENSION sqlite_fdw CASCADE;
