--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');

CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_svr INTO public;

INSERT INTO "type_STRING"(col) VALUES ('string');
INSERT INTO "type_BOOLEAN"(col) VALUES (TRUE);
INSERT INTO "type_BOOLEAN"(col) VALUES (FALSE);
INSERT INTO "type_BYTE"(col) VALUES ('c');
INSERT INTO "type_SINT"(col) VALUES (32767);
INSERT INTO "type_SINT"(col) VALUES (-32768);
INSERT INTO "type_BINT"(col) VALUES (9223372036854775807);
INSERT INTO "type_BINT"(col) VALUES (-9223372036854775808);
INSERT INTO "type_INTEGER"(col) VALUES (9223372036854775807);

INSERT INTO "type_FLOAT"(col) VALUES (3.1415);
INSERT INTO "type_DOUBLE"(col) VALUES (3.14159265);
INSERT INTO "type_TIMESTAMP" VALUES ('2017.11.06 12:34:56.789', '2017.11.06');
INSERT INTO "type_TIMESTAMP" VALUES ('2017.11.06 1:3:0', '2017.11.07');
INSERT INTO "type_BLOB"(col) VALUES (bytea('\xDEADBEEF'));
INSERT INTO typetest VALUES(1,'a', 'b', 'c','2017.11.06 12:34:56.789', '2017.11.06 12:34:56.789' ) ;

SELECT * FROM "type_STRING";
SELECT * FROM "type_BOOLEAN";
SELECT * FROM "type_BYTE";
SELECT * FROM "type_SINT";
SELECT * FROM "type_BINT";
SELECT * FROM "type_INTEGER";
SELECT * FROM "type_FLOAT";
SELECT * FROM "type_DOUBLE";
set datestyle=ISO;
SELECT * FROM "type_TIMESTAMP";
SELECT * FROM "type_BLOB";
SELECT * FROM typetest;

insert into "type_STRING" values('TYPE');
insert into "type_STRING" values('type');

-- not pushdown
SELECT  *FROM "type_STRING" WHERE col like 'TYP%';
EXPLAIN SELECT  *FROM "type_STRING" WHERE col like 'TYP%';
-- pushdown
SELECT  *FROM "type_STRING" WHERE col ilike 'typ%';
EXPLAIN SELECT  *FROM "type_STRING" WHERE col ilike 'typ%';

SELECT  *FROM "type_STRING" WHERE col ilike 'typ%' and col like 'TYPE';
EXPLAIN SELECT  *FROM "type_STRING" WHERE col ilike 'typ%' and col like 'TYPE';

SELECT * FROM "type_TIMESTAMP";

EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM  "type_TIMESTAMP" WHERE col > date ('2017.11.06 12:34:56.789') ;
SELECT * FROM  "type_TIMESTAMP" WHERE col > date ('2017.11.06 12:34:56.789') ;

EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM  "type_TIMESTAMP" WHERE col::text > date ('2017.11.06 12:34:56.789')::text ;
SELECT * FROM  "type_TIMESTAMP" WHERE col::text > date ('2017.11.06 12:34:56.789')::text ;

EXPLAIN  (VERBOSE, COSTS OFF) SELECT * FROM  "type_TIMESTAMP" WHERE col > b - interval '1 hour'; 
SELECT * FROM  "type_TIMESTAMP" WHERE col > b - interval '1 hour';

EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM  "type_TIMESTAMP" WHERE col > b;
SELECT * FROM  "type_TIMESTAMP" WHERE col > b;

DROP EXTENSION sqlite_fdw CASCADE;
