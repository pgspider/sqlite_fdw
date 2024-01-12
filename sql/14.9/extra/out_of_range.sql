--
-- INT4 + INT2
--
--Testcase 001:
CREATE EXTENSION sqlite_fdw;
--Testcase 002:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');

--Testcase 01:
CREATE FOREIGN TABLE INT4_TBL(f1 int4 OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 02:
CREATE FOREIGN TABLE INT4_TMP(f1 int4, f2 int4, id int OPTIONS (key 'true')) SERVER sqlite_svr; 

--Testcase 03:
DELETE FROM INT4_TMP;
--Testcase 04:
ALTER FOREIGN TABLE INT4_TMP ALTER COLUMN f1 TYPE int8;
--Testcase 05:
INSERT INTO INT4_TMP VALUES (x'7FFFFFFF'::int8 + 1, 0);
--Testcase 06:
ALTER FOREIGN TABLE INT4_TMP ALTER COLUMN f1 TYPE int4;
--Testcase 07:
SELECT * FROM INT4_TMP; -- overflow

--Testcase 08:
DELETE FROM INT4_TMP;
--Testcase 09:
ALTER FOREIGN TABLE INT4_TMP ALTER COLUMN f1 TYPE int8;
--Testcase 10:
INSERT INTO INT4_TMP VALUES (-(x'7FFFFFFF'::int8) - 2, 0);
--Testcase 11:
ALTER FOREIGN TABLE INT4_TMP ALTER COLUMN f1 TYPE int4;
--Testcase 12:
SELECT * FROM INT4_TMP; -- overflow

--Testcase 13:
CREATE FOREIGN TABLE INT2_TBL(f1 int2 OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 14:
CREATE FOREIGN TABLE INT2_TMP(f1 int2, f2 int2, id int OPTIONS (key 'true')) SERVER sqlite_svr; 

--Testcase 15:
DELETE FROM INT2_TMP;
--Testcase 16:
ALTER FOREIGN TABLE INT2_TMP ALTER COLUMN f1 TYPE int4;
--Testcase 17:
INSERT INTO INT2_TMP VALUES (x'7FFF'::int8 + 1, 0);
--Testcase 18:
ALTER FOREIGN TABLE INT2_TMP ALTER COLUMN f1 TYPE int2;
--Testcase 19:
SELECT * FROM INT2_TMP; -- overflow

--Testcase 20:
DELETE FROM INT2_TMP;
--Testcase 21:
ALTER FOREIGN TABLE INT2_TMP ALTER COLUMN f1 TYPE int4;
--Testcase 22:
INSERT INTO INT2_TMP VALUES (-(x'7FFF'::int8) - 2, 0);
--Testcase 23:
ALTER FOREIGN TABLE INT2_TMP ALTER COLUMN f1 TYPE int2;
--Testcase 24:
SELECT * FROM INT2_TMP; -- overflow

--Testcase 003:
DROP SERVER sqlite_svr CASCADE;
--Testcase 004:
DROP EXTENSION sqlite_fdw CASCADE;
