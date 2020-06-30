--
-- FLOAT4
--
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');
CREATE FOREIGN TABLE FLOAT4_TBL(f1 float4 OPTIONS (key 'true')) SERVER sqlite_svr;

--Testcase 1:
INSERT INTO FLOAT4_TBL(f1) VALUES ('    0.0');
--Testcase 2:
INSERT INTO FLOAT4_TBL(f1) VALUES ('1004.30   ');
--Testcase 3:
INSERT INTO FLOAT4_TBL(f1) VALUES ('     -34.84    ');
--Testcase 4:
INSERT INTO FLOAT4_TBL(f1) VALUES ('1.2345678901234e+20');
--Testcase 5:
INSERT INTO FLOAT4_TBL(f1) VALUES ('1.2345678901234e-20');

-- test for over and under flow
--Testcase 6:
INSERT INTO FLOAT4_TBL(f1) VALUES ('10e70');
--Testcase 7:
INSERT INTO FLOAT4_TBL(f1) VALUES ('-10e70');
--Testcase 8:
INSERT INTO FLOAT4_TBL(f1) VALUES ('10e-70');
--Testcase 9:
INSERT INTO FLOAT4_TBL(f1) VALUES ('-10e-70');

-- bad input
--Testcase 10:
INSERT INTO FLOAT4_TBL(f1) VALUES ('');
--Testcase 11:
INSERT INTO FLOAT4_TBL(f1) VALUES ('       ');
--Testcase 12:
INSERT INTO FLOAT4_TBL(f1) VALUES ('xyz');
--Testcase 13:
INSERT INTO FLOAT4_TBL(f1) VALUES ('5.0.0');
--Testcase 14:
INSERT INTO FLOAT4_TBL(f1) VALUES ('5 . 0');
--Testcase 15:
INSERT INTO FLOAT4_TBL(f1) VALUES ('5.   0');
--Testcase 16:
INSERT INTO FLOAT4_TBL(f1) VALUES ('     - 3.0');
--Testcase 17:
INSERT INTO FLOAT4_TBL(f1) VALUES ('123            5');

-- special inputs
BEGIN;
--Testcase 18:
DELETE FROM FLOAT4_TBL;
--Testcase 19:
INSERT INTO FLOAT4_TBL(f1) VALUES ('NaN'::float4);
--Testcase 20:
INSERT INTO FLOAT4_TBL(f1) VALUES ('nan'::float4);
--Testcase 21:
INSERT INTO FLOAT4_TBL(f1) VALUES ('   NAN  '::float4);
--Testcase 22:
INSERT INTO FLOAT4_TBL(f1) VALUES ('infinity'::float4);
--Testcase 23:
INSERT INTO FLOAT4_TBL(f1) VALUES ('          -INFINiTY   '::float4);
--Testcase 24:
SELECT * FROM FLOAT4_TBL;
ROLLBACK;

-- bad special inputs
--Testcase 25:
INSERT INTO FLOAT4_TBL(f1) VALUES ('N A N'::float4);
--Testcase 26:
INSERT INTO FLOAT4_TBL(f1) VALUES ('NaN x'::float4);
--Testcase 27:
INSERT INTO FLOAT4_TBL(f1) VALUES (' INFINITY    x'::float4);

BEGIN;
--Testcase 28:
DELETE FROM FLOAT4_TBL;
--Testcase 29:
INSERT INTO FLOAT4_TBL(f1) VALUES ('Infinity'::float4 + 100.0);
--Testcase 30:
INSERT INTO FLOAT4_TBL(f1) VALUES ('Infinity'::float4 / 'Infinity'::float4);
--Testcase 31:
INSERT INTO FLOAT4_TBL(f1) VALUES ('nan'::float4 / 'nan'::float4);
--Testcase 32:
INSERT INTO FLOAT4_TBL(f1) VALUES ('nan'::numeric::float4);
--Testcase 33:
SELECT * FROM FLOAT4_TBL;
ROLLBACK;

--Testcase 34:
SELECT '' AS five, * FROM FLOAT4_TBL;

--Testcase 35:
SELECT '' AS four, f.* FROM FLOAT4_TBL f WHERE '1004.3' >= f.f1;

--Testcase 36:
SELECT '' AS four, f.* FROM FLOAT4_TBL f WHERE  f.f1 <= '1004.3';

--Testcase 37:
SELECT '' AS three, f.f1, f.f1 * '-10' AS x FROM FLOAT4_TBL f
   WHERE f.f1 > '0.0';

--Testcase 38:
SELECT '' AS three, f.f1, f.f1 + '-10' AS x FROM FLOAT4_TBL f
   WHERE f.f1 > '0.0';

--Testcase 39:
SELECT '' AS three, f.f1, f.f1 / '-10' AS x FROM FLOAT4_TBL f
   WHERE f.f1 > '0.0';

--Testcase 40:
SELECT '' AS three, f.f1, f.f1 - '-10' AS x FROM FLOAT4_TBL f
   WHERE f.f1 > '0.0';

-- test divide by zero
--Testcase 41:
SELECT '' AS bad, f.f1 / '0.0' from FLOAT4_TBL f;

--Testcase 42:
SELECT '' AS five, * FROM FLOAT4_TBL;

-- test the unary float4abs operator
--Testcase 43:
SELECT '' AS five, f.f1, @f.f1 AS abs_f1 FROM FLOAT4_TBL f;

--Testcase 44:
UPDATE FLOAT4_TBL
   SET f1 = FLOAT4_TBL.f1 * '-1'
   WHERE FLOAT4_TBL.f1 > '0.0';

--Testcase 45:
SELECT '' AS five, * FROM FLOAT4_TBL;

DROP FOREIGN TABLE FLOAT4_TBL;
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw CASCADE;