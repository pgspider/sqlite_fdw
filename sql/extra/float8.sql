--
-- FLOAT8
--
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');
CREATE FOREIGN TABLE FLOAT8_TBL(f1 float8 OPTIONS (key 'true')) SERVER sqlite_svr;

--Testcase 1:
INSERT INTO FLOAT8_TBL(f1) VALUES ('    0.0   ');
--Testcase 2:
INSERT INTO FLOAT8_TBL(f1) VALUES ('1004.30  ');
--Testcase 3:
INSERT INTO FLOAT8_TBL(f1) VALUES ('   -34.84');
--Testcase 4:
INSERT INTO FLOAT8_TBL(f1) VALUES ('1.2345678901234e+200');
--Testcase 5:
INSERT INTO FLOAT8_TBL(f1) VALUES ('1.2345678901234e-200');

-- test for underflow and overflow handling
--Testcase 6:
INSERT INTO FLOAT8_TBL(f1) VALUES ('10e400'::float8);
--Testcase 7:
INSERT INTO FLOAT8_TBL(f1) VALUES ('-10e400'::float8);
--Testcase 8:
INSERT INTO FLOAT8_TBL(f1) VALUES ('10e-400'::float8);
--Testcase 9:
INSERT INTO FLOAT8_TBL(f1) VALUES ('-10e-400'::float8);

-- bad input
--Testcase 10:
INSERT INTO FLOAT8_TBL(f1) VALUES ('');
--Testcase 11:
INSERT INTO FLOAT8_TBL(f1) VALUES ('     ');
--Testcase 12:
INSERT INTO FLOAT8_TBL(f1) VALUES ('xyz');
--Testcase 13:
INSERT INTO FLOAT8_TBL(f1) VALUES ('5.0.0');
--Testcase 14:
INSERT INTO FLOAT8_TBL(f1) VALUES ('5 . 0');
--Testcase 15:
INSERT INTO FLOAT8_TBL(f1) VALUES ('5.   0');
--Testcase 16:
INSERT INTO FLOAT8_TBL(f1) VALUES ('    - 3');
--Testcase 17:
INSERT INTO FLOAT8_TBL(f1) VALUES ('123           5');

-- special inputs
BEGIN;
--Testcase 18:
DELETE FROM FLOAT8_TBL;
--Testcase 19:
INSERT INTO FLOAT8_TBL VALUES ('NaN'::float8);
--Testcase 20:
INSERT INTO FLOAT8_TBL VALUES ('nan'::float8);
--Testcase 21:
INSERT INTO FLOAT8_TBL VALUES ('   NAN  '::float8);
--Testcase 22:
INSERT INTO FLOAT8_TBL VALUES ('infinity'::float8);
--Testcase 23:
INSERT INTO FLOAT8_TBL VALUES ('          -INFINiTY   '::float8);
--Testcase 24:
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

-- bad special inputs
--Testcase 25:
INSERT INTO FLOAT8_TBL VALUES ('N A N'::float8);
--Testcase 26:
INSERT INTO FLOAT8_TBL VALUES ('NaN x'::float8);
--Testcase 27:
INSERT INTO FLOAT8_TBL VALUES (' INFINITY    x'::float8);

BEGIN;
--Testcase 28:
DELETE FROM FLOAT8_TBL;
--Testcase 29:
INSERT INTO FLOAT8_TBL VALUES ('Infinity'::float8 + 100.0);
--Testcase 30:
INSERT INTO FLOAT8_TBL VALUES ('Infinity'::float8 / 'Infinity'::float8);
--Testcase 31:
INSERT INTO FLOAT8_TBL VALUES ('nan'::float8 / 'nan'::float8);
--Testcase 32:
INSERT INTO FLOAT8_TBL VALUES ('nan'::numeric::float8);
--Testcase 33:
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

--Testcase 34:
SELECT '' AS five, * FROM FLOAT8_TBL;

--Testcase 35:
SELECT '' AS four, f.* FROM FLOAT8_TBL f WHERE f.f1 <> '1004.3';

--Testcase 36:
SELECT '' AS one, f.* FROM FLOAT8_TBL f WHERE f.f1 = '1004.3';

--Testcase 37:
SELECT '' AS three, f.* FROM FLOAT8_TBL f WHERE '1004.3' > f.f1;

--Testcase 38:
SELECT '' AS three, f.* FROM FLOAT8_TBL f WHERE  f.f1 < '1004.3';

--Testcase 39:
SELECT '' AS four, f.* FROM FLOAT8_TBL f WHERE '1004.3' >= f.f1;

--Testcase 40:
SELECT '' AS four, f.* FROM FLOAT8_TBL f WHERE  f.f1 <= '1004.3';

--Testcase 41:
SELECT '' AS three, f.f1, f.f1 * '-10' AS x
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

--Testcase 42:
SELECT '' AS three, f.f1, f.f1 + '-10' AS x
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

--Testcase 43:
SELECT '' AS three, f.f1, f.f1 / '-10' AS x
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

--Testcase 44:
SELECT '' AS three, f.f1, f.f1 - '-10' AS x
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

--Testcase 45:
SELECT '' AS one, f.f1 ^ '2.0' AS square_f1
   FROM FLOAT8_TBL f where f.f1 = '1004.3';

-- absolute value
--Testcase 46:
SELECT '' AS five, f.f1, @f.f1 AS abs_f1
   FROM FLOAT8_TBL f;

-- truncate
--Testcase 47:
SELECT '' AS five, f.f1, trunc(f.f1) AS trunc_f1
   FROM FLOAT8_TBL f;

-- round
--Testcase 48:
SELECT '' AS five, f.f1, round(f.f1) AS round_f1
   FROM FLOAT8_TBL f;

-- ceil / ceiling
--Testcase 49:
select ceil(f1) as ceil_f1 from float8_tbl f;
--Testcase 50:
select ceiling(f1) as ceiling_f1 from float8_tbl f;

-- floor
--Testcase 51:
select floor(f1) as floor_f1 from float8_tbl f;

-- sign
--Testcase 52:
select sign(f1) as sign_f1 from float8_tbl f;

-- square root
BEGIN;
--Testcase 53:
DELETE FROM FLOAT8_TBL;
--Testcase 54:
INSERT INTO FLOAT8_TBL VALUES (sqrt(float8 '64'));
--Testcase 55:
INSERT INTO FLOAT8_TBL VALUES (|/ float8 '64');
--Testcase 56:
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

--Testcase 57:
SELECT '' AS three, f.f1, |/f.f1 AS sqrt_f1
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

-- power
BEGIN;
--Testcase 58:
DELETE FROM FLOAT8_TBL;
--Testcase 59:
INSERT INTO FLOAT8_TBL VALUES (power(float8 '144', float8 '0.5'));
--Testcase 60:
INSERT INTO FLOAT8_TBL VALUES (power(float8 'NaN', float8 '0.5'));
--Testcase 61:
INSERT INTO FLOAT8_TBL VALUES (power(float8 '144', float8 'NaN'));
--Testcase 62:
INSERT INTO FLOAT8_TBL VALUES (power(float8 'NaN', float8 'NaN'));
--Testcase 63:
INSERT INTO FLOAT8_TBL VALUES (power(float8 '-1', float8 'NaN'));
--Testcase 64:
INSERT INTO FLOAT8_TBL VALUES (power(float8 '1', float8 'NaN'));
--Testcase 65:
INSERT INTO FLOAT8_TBL VALUES (power(float8 'NaN', float8 '0'));
--Testcase 66:
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

-- take exp of ln(f.f1)
--Testcase 67:
SELECT '' AS three, f.f1, exp(ln(f.f1)) AS exp_ln_f1
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

-- cube root
BEGIN;
--Testcase 68:
DELETE FROM FLOAT8_TBL;
--Testcase 69:
INSERT INTO FLOAT8_TBL VALUES (||/ float8 '27');
--Testcase 70:
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

--Testcase 71:
SELECT '' AS five, f.f1, ||/f.f1 AS cbrt_f1 FROM FLOAT8_TBL f;


--Testcase 72:
SELECT '' AS five, * FROM FLOAT8_TBL;

--Testcase 73:
UPDATE FLOAT8_TBL
   SET f1 = FLOAT8_TBL.f1 * '-1'
   WHERE FLOAT8_TBL.f1 > '0.0';

--Testcase 74:
SELECT '' AS bad, f.f1 * '1e200' from FLOAT8_TBL f;

--Testcase 75:
SELECT '' AS bad, f.f1 ^ '1e200' from FLOAT8_TBL f;

BEGIN;
--Testcase 76:
DELETE FROM FLOAT8_TBL;
--Testcase 77:
INSERT INTO FLOAT8_TBL VALUES (0 ^ 0 + 0 ^ 1 + 0 ^ 0.0 + 0 ^ 0.5);
--Testcase 78:
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

--Testcase 79:
SELECT '' AS bad, ln(f.f1) from FLOAT8_TBL f where f.f1 = '0.0' ;

--Testcase 80:
SELECT '' AS bad, ln(f.f1) from FLOAT8_TBL f where f.f1 < '0.0' ;

--Testcase 81:
SELECT '' AS bad, exp(f.f1) from FLOAT8_TBL f;

--Testcase 82:
SELECT '' AS bad, f.f1 / '0.0' from FLOAT8_TBL f;

--Testcase 83:
SELECT '' AS five, * FROM FLOAT8_TBL;

-- test for over- and underflow
--Testcase 84:
INSERT INTO FLOAT8_TBL(f1) VALUES ('10e400');

--Testcase 85:
INSERT INTO FLOAT8_TBL(f1) VALUES ('-10e400');

--Testcase 86:
INSERT INTO FLOAT8_TBL(f1) VALUES ('10e-400');

--Testcase 87:
INSERT INTO FLOAT8_TBL(f1) VALUES ('-10e-400');

-- maintain external table consistency across platforms
-- delete all values and reinsert well-behaved ones

--Testcase 88:
DELETE FROM FLOAT8_TBL;

--Testcase 89:
INSERT INTO FLOAT8_TBL(f1) VALUES ('0.0');

--Testcase 90:
INSERT INTO FLOAT8_TBL(f1) VALUES ('-34.84');

--Testcase 91:
INSERT INTO FLOAT8_TBL(f1) VALUES ('-1004.30');

--Testcase 92:
INSERT INTO FLOAT8_TBL(f1) VALUES ('-1.2345678901234e+200');

--Testcase 93:
INSERT INTO FLOAT8_TBL(f1) VALUES ('-1.2345678901234e-200');

--Testcase 94:
SELECT '' AS five, * FROM FLOAT8_TBL;

-- test exact cases for trigonometric functions in degrees
SET extra_float_digits = 3;

BEGIN;
--Testcase 95:
DELETE FROM FLOAT8_TBL;
--Testcase 96:
INSERT INTO FLOAT8_TBL VALUES (0), (30), (90), (150), (180),
      (210), (270), (330), (360);
--Testcase 97:
SELECT f1,
       sind(f1),
       sind(f1) IN (-1,-0.5,0,0.5,1) AS sind_exact
       FROM FLOAT8_TBL;

--Testcase 98:
DELETE FROM FLOAT8_TBL;
--Testcase 99:
INSERT INTO FLOAT8_TBL VALUES (0), (60), (90), (120), (180),
      (240), (270), (300), (360);
--Testcase 100:
SELECT f1,
       cosd(f1),
       cosd(f1) IN (-1,-0.5,0,0.5,1) AS cosd_exact
       FROM FLOAT8_TBL;

--Testcase 101:
DELETE FROM FLOAT8_TBL;
--Testcase 102:
INSERT INTO FLOAT8_TBL VALUES (0), (45), (90), (135), (180),
      (225), (270), (315), (360);
--Testcase 103:
SELECT f1,
       tand(f1),
       tand(f1) IN ('-Infinity'::float8,-1,0,
                   1,'Infinity'::float8) AS tand_exact,
       cotd(f1),
       cotd(f1) IN ('-Infinity'::float8,-1,0,
                   1,'Infinity'::float8) AS cotd_exact
          FROM FLOAT8_TBL;

--Testcase 104:
DELETE FROM FLOAT8_TBL;
--Testcase 105:
INSERT INTO FLOAT8_TBL VALUES (-1), (-0.5), (0), (0.5), (1);
--Testcase 106:
SELECT f1,
       asind(f1),
       asind(f1) IN (-90,-30,0,30,90) AS asind_exact,
       acosd(f1),
       acosd(f1) IN (0,60,90,120,180) AS acosd_exact
          FROM FLOAT8_TBL;

--Testcase 107:
DELETE FROM FLOAT8_TBL;
--Testcase 108:
INSERT INTO FLOAT8_TBL VALUES ('-Infinity'::float8), (-1), (0), (1),
      ('Infinity'::float8);
--Testcase 109:
SELECT f1,
       atand(f1),
       atand(f1) IN (-90,-45,0,45,90) AS atand_exact
          FROM FLOAT8_TBL;

--Testcase 110:
ROLLBACK;
BEGIN;
DELETE FROM FLOAT8_TBL;
--Testcase 111:
INSERT INTO FLOAT8_TBL SELECT * FROM generate_series(0, 360, 90);
--Testcase 112:
SELECT x, y,
       atan2d(y, x),
       atan2d(y, x) IN (-90,0,90,180) AS atan2d_exact
FROM (SELECT 10*cosd(f1), 10*sind(f1)
          FROM FLOAT8_TBL) AS t(x,y);

ROLLBACK;

RESET extra_float_digits;

DROP FOREIGN TABLE FLOAT8_TBL;
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw CASCADE;