--
-- FLOAT8
--
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');
CREATE FOREIGN TABLE FLOAT8_TBL(f1 float8 OPTIONS (key 'true')) SERVER sqlite_svr;

INSERT INTO FLOAT8_TBL(f1) VALUES ('    0.0   ');
INSERT INTO FLOAT8_TBL(f1) VALUES ('1004.30  ');
INSERT INTO FLOAT8_TBL(f1) VALUES ('   -34.84');
INSERT INTO FLOAT8_TBL(f1) VALUES ('1.2345678901234e+200');
INSERT INTO FLOAT8_TBL(f1) VALUES ('1.2345678901234e-200');

-- test for underflow and overflow handling
INSERT INTO FLOAT8_TBL(f1) VALUES ('10e400'::float8);
INSERT INTO FLOAT8_TBL(f1) VALUES ('-10e400'::float8);
INSERT INTO FLOAT8_TBL(f1) VALUES ('10e-400'::float8);
INSERT INTO FLOAT8_TBL(f1) VALUES ('-10e-400'::float8);

-- bad input
INSERT INTO FLOAT8_TBL(f1) VALUES ('');
INSERT INTO FLOAT8_TBL(f1) VALUES ('     ');
INSERT INTO FLOAT8_TBL(f1) VALUES ('xyz');
INSERT INTO FLOAT8_TBL(f1) VALUES ('5.0.0');
INSERT INTO FLOAT8_TBL(f1) VALUES ('5 . 0');
INSERT INTO FLOAT8_TBL(f1) VALUES ('5.   0');
INSERT INTO FLOAT8_TBL(f1) VALUES ('    - 3');
INSERT INTO FLOAT8_TBL(f1) VALUES ('123           5');

-- special inputs
BEGIN;
DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES ('NaN'::float8);
INSERT INTO FLOAT8_TBL VALUES ('nan'::float8);
INSERT INTO FLOAT8_TBL VALUES ('   NAN  '::float8);
INSERT INTO FLOAT8_TBL VALUES ('infinity'::float8);
INSERT INTO FLOAT8_TBL VALUES ('          -INFINiTY   '::float8);
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

-- bad special inputs
INSERT INTO FLOAT8_TBL VALUES ('N A N'::float8);
INSERT INTO FLOAT8_TBL VALUES ('NaN x'::float8);
INSERT INTO FLOAT8_TBL VALUES (' INFINITY    x'::float8);

BEGIN;
DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES ('Infinity'::float8 + 100.0);
INSERT INTO FLOAT8_TBL VALUES ('Infinity'::float8 / 'Infinity'::float8);
INSERT INTO FLOAT8_TBL VALUES ('nan'::float8 / 'nan'::float8);
INSERT INTO FLOAT8_TBL VALUES ('nan'::numeric::float8);
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

SELECT '' AS five, * FROM FLOAT8_TBL;

SELECT '' AS four, f.* FROM FLOAT8_TBL f WHERE f.f1 <> '1004.3';

SELECT '' AS one, f.* FROM FLOAT8_TBL f WHERE f.f1 = '1004.3';

SELECT '' AS three, f.* FROM FLOAT8_TBL f WHERE '1004.3' > f.f1;

SELECT '' AS three, f.* FROM FLOAT8_TBL f WHERE  f.f1 < '1004.3';

SELECT '' AS four, f.* FROM FLOAT8_TBL f WHERE '1004.3' >= f.f1;

SELECT '' AS four, f.* FROM FLOAT8_TBL f WHERE  f.f1 <= '1004.3';

SELECT '' AS three, f.f1, f.f1 * '-10' AS x
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

SELECT '' AS three, f.f1, f.f1 + '-10' AS x
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

SELECT '' AS three, f.f1, f.f1 / '-10' AS x
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

SELECT '' AS three, f.f1, f.f1 - '-10' AS x
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

SELECT '' AS one, f.f1 ^ '2.0' AS square_f1
   FROM FLOAT8_TBL f where f.f1 = '1004.3';

-- absolute value
SELECT '' AS five, f.f1, @f.f1 AS abs_f1
   FROM FLOAT8_TBL f;

-- truncate
SELECT '' AS five, f.f1, trunc(f.f1) AS trunc_f1
   FROM FLOAT8_TBL f;

-- round
SELECT '' AS five, f.f1, round(f.f1) AS round_f1
   FROM FLOAT8_TBL f;

-- ceil / ceiling
select ceil(f1) as ceil_f1 from float8_tbl f;
select ceiling(f1) as ceiling_f1 from float8_tbl f;

-- floor
select floor(f1) as floor_f1 from float8_tbl f;

-- sign
select sign(f1) as sign_f1 from float8_tbl f;

-- square root
BEGIN;
DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES (sqrt(float8 '64'));
INSERT INTO FLOAT8_TBL VALUES (|/ float8 '64');
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

SELECT '' AS three, f.f1, |/f.f1 AS sqrt_f1
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

-- power
BEGIN;
DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES (power(float8 '144', float8 '0.5'));
INSERT INTO FLOAT8_TBL VALUES (power(float8 'NaN', float8 '0.5'));
INSERT INTO FLOAT8_TBL VALUES (power(float8 '144', float8 'NaN'));
INSERT INTO FLOAT8_TBL VALUES (power(float8 'NaN', float8 'NaN'));
INSERT INTO FLOAT8_TBL VALUES (power(float8 '-1', float8 'NaN'));
INSERT INTO FLOAT8_TBL VALUES (power(float8 '1', float8 'NaN'));
INSERT INTO FLOAT8_TBL VALUES (power(float8 'NaN', float8 '0'));
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

-- take exp of ln(f.f1)
SELECT '' AS three, f.f1, exp(ln(f.f1)) AS exp_ln_f1
   FROM FLOAT8_TBL f
   WHERE f.f1 > '0.0';

-- cube root
BEGIN;
DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES (||/ float8 '27');
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

SELECT '' AS five, f.f1, ||/f.f1 AS cbrt_f1 FROM FLOAT8_TBL f;


SELECT '' AS five, * FROM FLOAT8_TBL;

UPDATE FLOAT8_TBL
   SET f1 = FLOAT8_TBL.f1 * '-1'
   WHERE FLOAT8_TBL.f1 > '0.0';

SELECT '' AS bad, f.f1 * '1e200' from FLOAT8_TBL f;

SELECT '' AS bad, f.f1 ^ '1e200' from FLOAT8_TBL f;

BEGIN;
DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES (0 ^ 0 + 0 ^ 1 + 0 ^ 0.0 + 0 ^ 0.5);
SELECT * FROM FLOAT8_TBL;
ROLLBACK;

SELECT '' AS bad, ln(f.f1) from FLOAT8_TBL f where f.f1 = '0.0' ;

SELECT '' AS bad, ln(f.f1) from FLOAT8_TBL f where f.f1 < '0.0' ;

SELECT '' AS bad, exp(f.f1) from FLOAT8_TBL f;

SELECT '' AS bad, f.f1 / '0.0' from FLOAT8_TBL f;

SELECT '' AS five, * FROM FLOAT8_TBL;

-- test for over- and underflow
INSERT INTO FLOAT8_TBL(f1) VALUES ('10e400');

INSERT INTO FLOAT8_TBL(f1) VALUES ('-10e400');

INSERT INTO FLOAT8_TBL(f1) VALUES ('10e-400');

INSERT INTO FLOAT8_TBL(f1) VALUES ('-10e-400');

-- maintain external table consistency across platforms
-- delete all values and reinsert well-behaved ones

DELETE FROM FLOAT8_TBL;

INSERT INTO FLOAT8_TBL(f1) VALUES ('0.0');

INSERT INTO FLOAT8_TBL(f1) VALUES ('-34.84');

INSERT INTO FLOAT8_TBL(f1) VALUES ('-1004.30');

INSERT INTO FLOAT8_TBL(f1) VALUES ('-1.2345678901234e+200');

INSERT INTO FLOAT8_TBL(f1) VALUES ('-1.2345678901234e-200');

SELECT '' AS five, * FROM FLOAT8_TBL;

-- test exact cases for trigonometric functions in degrees
SET extra_float_digits = 3;

BEGIN;
DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES (0), (30), (90), (150), (180),
      (210), (270), (330), (360);
SELECT f1,
       sind(f1),
       sind(f1) IN (-1,-0.5,0,0.5,1) AS sind_exact
       FROM FLOAT8_TBL;

DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES (0), (60), (90), (120), (180),
      (240), (270), (300), (360);
SELECT f1,
       cosd(f1),
       cosd(f1) IN (-1,-0.5,0,0.5,1) AS cosd_exact
       FROM FLOAT8_TBL;

DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES (0), (45), (90), (135), (180),
      (225), (270), (315), (360);
SELECT f1,
       tand(f1),
       tand(f1) IN ('-Infinity'::float8,-1,0,
                   1,'Infinity'::float8) AS tand_exact,
       cotd(f1),
       cotd(f1) IN ('-Infinity'::float8,-1,0,
                   1,'Infinity'::float8) AS cotd_exact
          FROM FLOAT8_TBL;

DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES (-1), (-0.5), (0), (0.5), (1);
SELECT f1,
       asind(f1),
       asind(f1) IN (-90,-30,0,30,90) AS asind_exact,
       acosd(f1),
       acosd(f1) IN (0,60,90,120,180) AS acosd_exact
          FROM FLOAT8_TBL;

DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL VALUES ('-Infinity'::float8), (-1), (0), (1),
      ('Infinity'::float8);
SELECT f1,
       atand(f1),
       atand(f1) IN (-90,-45,0,45,90) AS atand_exact
          FROM FLOAT8_TBL;

DELETE FROM FLOAT8_TBL;
INSERT INTO FLOAT8_TBL SELECT * FROM generate_series(0, 360, 90);
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
