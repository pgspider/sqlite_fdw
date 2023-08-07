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
--Testcase 2:
INSERT INTO "type_BOOLEAN"(col) VALUES (TRUE);
--Testcase 3:
INSERT INTO "type_BOOLEAN"(col) VALUES (FALSE);
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
--Testcase 17:
SELECT * FROM "type_BOOLEAN";
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
DROP FOREIGN TABLE "type_BOOLEAN";
--Testcase 63:
CREATE FOREIGN TABLE "type_BOOLEAN" (colx int, col boolean) SERVER sqlite_svr;
--Testcase 64:
ALTER FOREIGN TABLE "type_BOOLEAN" DROP COLUMN colx;
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

--Testcase 178:
DROP FOREIGN TABLE "type_BIT";
--Testcase 179:
CREATE FOREIGN TABLE "type_BIT"( "i" int OPTIONS (key 'true'), "b" bit(6)) SERVER sqlite_svr OPTIONS (table 'type_BIT');
--Testcase 180:
DROP FOREIGN TABLE "type_BIT+";
--Testcase 181:
CREATE FOREIGN TABLE "type_BIT+"( "i" int OPTIONS (key 'true'), "b" bit(6), "t" text, "l" smallint, "bi" bigint OPTIONS (column_name 'b')) SERVER sqlite_svr OPTIONS (table 'type_BIT+');
--Testcase 182:
INSERT INTO "type_BIT" ("i", "b") VALUES (1, 1);
--Testcase 183:
INSERT INTO "type_BIT" ("i", "b") VALUES (2, 2);
--Testcase 184:
INSERT INTO "type_BIT" ("i", "b") VALUES (3, '1');
--Testcase 185:
INSERT INTO "type_BIT" ("i", "b") VALUES (4, '10');
--Testcase 186:
INSERT INTO "type_BIT" ("i", "b") VALUES (5, '101');
--Testcase 187:
INSERT INTO "type_BIT" ("i", "b") VALUES (6, '110110');
--Testcase 188:
INSERT INTO "type_BIT" ("i", "b") VALUES (7, '111001');
--Testcase 189:
INSERT INTO "type_BIT" ("i", "b") VALUES (8, '110000');
--Testcase 190:
INSERT INTO "type_BIT" ("i", "b") VALUES (9, '100001');
--Testcase 191:
INSERT INTO "type_BIT" ("i", "b") VALUES (10, 53);
--Testcase 192:
SELECT * FROM "type_BIT+";
--Testcase 193:
SELECT * FROM "type_BIT" WHERE b < '110110';
--Testcase 194:
SELECT * FROM "type_BIT" WHERE b > '110110';
--Testcase 195:
SELECT * FROM "type_BIT" WHERE b = '110110';

--Testcase 196:
DROP FOREIGN TABLE "type_VARBIT";
--Testcase 197:
CREATE FOREIGN TABLE "type_VARBIT"( "i" int OPTIONS (key 'true'), "b" varbit(70)) SERVER sqlite_svr OPTIONS (table 'type_VARBIT');
--Testcase 199:
DROP FOREIGN TABLE "type_VARBIT+";
--Testcase 200:
CREATE FOREIGN TABLE "type_VARBIT+"( "i" int OPTIONS (key 'true'), "b" varbit(70), "t" text, "l" smallint) SERVER sqlite_svr OPTIONS (table 'type_VARBIT+');
--Testcase 201:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (1, '1');
--Testcase 202:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (2, '10');
--Testcase 203:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (3, '11');
--Testcase 204:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (4, '100');
--Testcase 205:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (5, '101');
--Testcase 206:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (6, '110110');
--Testcase 207:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (7, '111001');
--Testcase 208:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (8, '110000');
--Testcase 209:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (9, '100001');
--Testcase 210:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (10, '0100100101011001010010101000111110110101101101111011000101010');
--Testcase 211:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (11, '01001001010110010100101010001111101101011011011110110001010101');

--Testcase 212
SELECT * FROM "type_VARBIT+";
--Testcase 213:
SELECT * FROM "type_VARBIT+" WHERE b < '110110';
--Testcase 214:
SELECT * FROM "type_VARBIT+" WHERE b > '110110';
--Testcase 215:
SELECT * FROM "type_VARBIT+" WHERE b = '110110';

--Testcase 216:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (12, '010010010101100101001010100011111011010110110111101100010101010');
--Testcase 217:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (13, '0100100101011001010010101000111110110101101101111011000101010101');
--Testcase 218: 65 b
INSERT INTO "type_VARBIT" ("i", "b") VALUES (14, '01001001010110010100101010001111101101011011011110110001010101010');
--Testcase 219:
SELECT * FROM "type_VARBIT+" WHERE "i" > 10;

--Testcase 47:
DROP EXTENSION sqlite_fdw CASCADE;
