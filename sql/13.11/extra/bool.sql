--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 44:
CREATE EXTENSION sqlite_fdw;
--Testcase 45:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');

--Testcase 46:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

--Testcase 01:
CREATE FOREIGN TABLE "type_BOOLEAN" (i int OPTIONS (key 'true'), b text) SERVER sqlite_svr;
--Testcase 02:
INSERT INTO "type_BOOLEAN"(i, b) VALUES (1, TRUE);
--Testcase 03:
INSERT INTO "type_BOOLEAN"(i, b) VALUES (2, FALSE);
--Testcase 04:
CREATE FOREIGN TABLE "type_BOOLEAN+"( "i" int, "b" bool, "t" text, "l" smallint) SERVER sqlite_svr OPTIONS (table 'type_BOOLEAN+');
--Testcase 05:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (3, 'Yes');
--Testcase 06:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (4, 'YeS');
--Testcase 07:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (5, 'yes');
--Testcase 08:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (6, 'no');
--Testcase 09:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (7, 'No');
--Testcase 10:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (8, 'nO');
--Testcase 11:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (9, 'off');
--Testcase 12:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (10, 'oFf');
--Testcase 13:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (11, 'on');
--Testcase 14:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (12, 'ON');
--Testcase 15:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (13, 't');
--Testcase 16:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (14, 'T');
--Testcase 17:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (15, 'Y');
--Testcase 18:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (16, 'y');
--Testcase 19:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (17, 'F');
--Testcase 20:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (18, 'f');
--Testcase 21:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (19, 'x');
--Testcase 22:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (20, '0');
--Testcase 23:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (21, '1');
--Testcase 24:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (22, NULL);
--Testcase 25:
SELECT * FROM "type_BOOLEAN";
--Testcase 26:
ALTER FOREIGN TABLE "type_BOOLEAN" ALTER COLUMN "b" TYPE bool;
--Testcase 27:
EXPLAIN VERBOSE
SELECT * FROM "type_BOOLEAN";
--Testcase 28:
EXPLAIN VERBOSE
SELECT * FROM "type_BOOLEAN+";
--Testcase 29: ERR - invalid text affinity because not ISO:SQL text input
SELECT * FROM "type_BOOLEAN+";
--Testcase 30
DELETE FROM "type_BOOLEAN" WHERE i = 19;
--Testcase 31:
SELECT * FROM "type_BOOLEAN+";
--Testcase 32:
SELECT * FROM "type_BOOLEAN+" WHERE b IS NULL;
--Testcase 33:
SELECT * FROM "type_BOOLEAN+" WHERE b IS NOT NULL;
--Testcase 34:
SELECT * FROM "type_BOOLEAN+" WHERE b;
--Testcase 35:
SELECT * FROM "type_BOOLEAN+" WHERE NOT b;

--Testcase 47:
DROP EXTENSION sqlite_fdw CASCADE;
