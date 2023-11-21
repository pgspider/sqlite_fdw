--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 000:
CREATE EXTENSION sqlite_fdw;
--Testcase 001:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
--Testcase 002:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

--Testcase 01:
CREATE FOREIGN TABLE "type_BOOLEAN" (i int OPTIONS (key 'true'), b bool) SERVER sqlite_svr;
--Testcase 02:
INSERT INTO "type_BOOLEAN"(i, b) VALUES (1, TRUE);
--Testcase 03:
INSERT INTO "type_BOOLEAN"(i, b) VALUES (2, FALSE);
--Testcase 04:
CREATE FOREIGN TABLE "type_BOOLEAN+"( "i" int, "b" bool, "t" text, "l" smallint) SERVER sqlite_svr OPTIONS (table 'type_BOOLEAN+');
--Testcase 05:
ALTER FOREIGN TABLE "type_BOOLEAN" ALTER COLUMN "b" TYPE text;
--Testcase 06:
INSERT INTO "type_BOOLEAN"(i, b) VALUES (3, TRUE);
--Testcase 07:
INSERT INTO "type_BOOLEAN"(i, b) VALUES (4, FALSE);
--Testcase 08:
INSERT INTO "type_BOOLEAN"(i, b) VALUES (5, true);
--Testcase 09:
INSERT INTO "type_BOOLEAN"(i, b) VALUES (6, false);
--Testcase 10:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (7, 'Yes');
--Testcase 11:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (8, 'YeS');
--Testcase 12:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (9, 'yes');
--Testcase 13:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (10, 'no');
--Testcase 14:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (11, 'No');
--Testcase 15:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (12, 'nO');
--Testcase 16:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (13, 'off');
--Testcase 17:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (14, 'oFf');
--Testcase 18:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (15, 'on');
--Testcase 19:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (16, 'ON');
--Testcase 20:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (17, 't');
--Testcase 21:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (18, 'T');
--Testcase 22:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (19, 'Y');
--Testcase 23:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (20, 'y');
--Testcase 24:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (21, 'F');
--Testcase 25:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (22, 'f');
--Testcase 26:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (23, 'x');
--Testcase 27:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (24, '0');
--Testcase 28:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (25, '1');
--Testcase 29:
INSERT INTO "type_BOOLEAN" (i, b) VALUES (26, NULL);
--Testcase 30:
SELECT * FROM "type_BOOLEAN";
--Testcase 31:
ALTER FOREIGN TABLE "type_BOOLEAN" ALTER COLUMN "b" TYPE bool;
--Testcase 32:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM "type_BOOLEAN";
--Testcase 33:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM "type_BOOLEAN+";
--Testcase 34: ERR - invalid text affinity because not ISO:SQL text input
SELECT * FROM "type_BOOLEAN+";
--Testcase 35
DELETE FROM "type_BOOLEAN" WHERE i = 23;
--Testcase 36:
SELECT * FROM "type_BOOLEAN+";
--Testcase 37:
SELECT * FROM "type_BOOLEAN+" WHERE b IS NULL;
--Testcase 38:
SELECT * FROM "type_BOOLEAN+" WHERE b IS NOT NULL;
--Testcase 39:
SELECT * FROM "type_BOOLEAN+" WHERE b;
--Testcase 40:
SELECT * FROM "type_BOOLEAN+" WHERE NOT b;

--Testcase 41:
CREATE FOREIGN TABLE "type_BOOLEANpk" (col bool OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 42:
INSERT INTO "type_BOOLEANpk" VALUES (TRUE);
--Testcase 43:
INSERT INTO "type_BOOLEANpk" VALUES (FALSE);
--Testcase 44: ERR - primary key
INSERT INTO "type_BOOLEANpk" VALUES (TRUE);
--Testcase 45:
DELETE FROM "type_BOOLEANpk";

--Testcase 003:
DROP EXTENSION sqlite_fdw CASCADE;
