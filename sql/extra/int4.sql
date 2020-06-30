--
-- INT4
--
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');
CREATE FOREIGN TABLE INT4_TBL(f1 int4 OPTIONS (key 'true')) SERVER sqlite_svr; 

--Testcase 1:
INSERT INTO INT4_TBL(f1) VALUES ('   0  ');

--Testcase 2:
INSERT INTO INT4_TBL(f1) VALUES ('123456     ');

--Testcase 3:
INSERT INTO INT4_TBL(f1) VALUES ('    -123456');

--Testcase 4:
INSERT INTO INT4_TBL(f1) VALUES ('34.5');

-- largest and smallest values
--Testcase 5:
INSERT INTO INT4_TBL(f1) VALUES ('2147483647');

--Testcase 6:
INSERT INTO INT4_TBL(f1) VALUES ('-2147483647');

-- bad input values -- should give errors
--Testcase 7:
INSERT INTO INT4_TBL(f1) VALUES ('1000000000000');
--Testcase 8:
INSERT INTO INT4_TBL(f1) VALUES ('asdf');
--Testcase 9:
INSERT INTO INT4_TBL(f1) VALUES ('     ');
--Testcase 10:
INSERT INTO INT4_TBL(f1) VALUES ('   asdf   ');
--Testcase 11:
INSERT INTO INT4_TBL(f1) VALUES ('- 1234');
--Testcase 12:
INSERT INTO INT4_TBL(f1) VALUES ('123       5');
--Testcase 13:
INSERT INTO INT4_TBL(f1) VALUES ('');


--Testcase 14:
SELECT '' AS five, * FROM INT4_TBL;

--Testcase 15:
SELECT '' AS four, i.* FROM INT4_TBL i WHERE i.f1 <> int2 '0';

--Testcase 16:
SELECT '' AS four, i.* FROM INT4_TBL i WHERE i.f1 <> int4 '0';

--Testcase 17:
SELECT '' AS one, i.* FROM INT4_TBL i WHERE i.f1 = int2 '0';

--Testcase 18:
SELECT '' AS one, i.* FROM INT4_TBL i WHERE i.f1 = int4 '0';

--Testcase 19:
SELECT '' AS two, i.* FROM INT4_TBL i WHERE i.f1 < int2 '0';

--Testcase 20:
SELECT '' AS two, i.* FROM INT4_TBL i WHERE i.f1 < int4 '0';

--Testcase 21:
SELECT '' AS three, i.* FROM INT4_TBL i WHERE i.f1 <= int2 '0';

--Testcase 22:
SELECT '' AS three, i.* FROM INT4_TBL i WHERE i.f1 <= int4 '0';

--Testcase 23:
SELECT '' AS two, i.* FROM INT4_TBL i WHERE i.f1 > int2 '0';

--Testcase 24:
SELECT '' AS two, i.* FROM INT4_TBL i WHERE i.f1 > int4 '0';

--Testcase 25:
SELECT '' AS three, i.* FROM INT4_TBL i WHERE i.f1 >= int2 '0';

--Testcase 26:
SELECT '' AS three, i.* FROM INT4_TBL i WHERE i.f1 >= int4 '0';

-- positive odds
--Testcase 27:
SELECT '' AS one, i.* FROM INT4_TBL i WHERE (i.f1 % int2 '2') = int2 '1';

-- any evens
--Testcase 28:
SELECT '' AS three, i.* FROM INT4_TBL i WHERE (i.f1 % int4 '2') = int2 '0';

--Testcase 29:
SELECT '' AS five, i.f1, i.f1 * int2 '2' AS x FROM INT4_TBL i;

--Testcase 30:
SELECT '' AS five, i.f1, i.f1 * int2 '2' AS x FROM INT4_TBL i
WHERE abs(f1) < 1073741824;

--Testcase 31:
SELECT '' AS five, i.f1, i.f1 * int4 '2' AS x FROM INT4_TBL i;

--Testcase 32:
SELECT '' AS five, i.f1, i.f1 * int4 '2' AS x FROM INT4_TBL i
WHERE abs(f1) < 1073741824;

--Testcase 33:
SELECT '' AS five, i.f1, i.f1 + int2 '2' AS x FROM INT4_TBL i;

--Testcase 34:
SELECT '' AS five, i.f1, i.f1 + int2 '2' AS x FROM INT4_TBL i
WHERE f1 < 2147483646;

--Testcase 35:
SELECT '' AS five, i.f1, i.f1 + int4 '2' AS x FROM INT4_TBL i;

--Testcase 36:
SELECT '' AS five, i.f1, i.f1 + int4 '2' AS x FROM INT4_TBL i
WHERE f1 < 2147483646;

--Testcase 37:
SELECT '' AS five, i.f1, i.f1 - int2 '2' AS x FROM INT4_TBL i;

--Testcase 38:
SELECT '' AS five, i.f1, i.f1 - int2 '2' AS x FROM INT4_TBL i
WHERE f1 > -2147483647;

--Testcase 39:
SELECT '' AS five, i.f1, i.f1 - int4 '2' AS x FROM INT4_TBL i;

--Testcase 40:
SELECT '' AS five, i.f1, i.f1 - int4 '2' AS x FROM INT4_TBL i
WHERE f1 > -2147483647;

--Testcase 41:
SELECT '' AS five, i.f1, i.f1 / int2 '2' AS x FROM INT4_TBL i;

--Testcase 42:
SELECT '' AS five, i.f1, i.f1 / int4 '2' AS x FROM INT4_TBL i;

--
-- more complex expressions
--

-- variations on unary minus parsing

BEGIN;

--Testcase 43:
DELETE FROM INT4_TBL;

--Testcase 44:
INSERT INTO INT4_TBL VALUES (-2+3);

--Testcase 45:
INSERT INTO INT4_TBL VALUES (4-2);

--Testcase 46:
INSERT INTO INT4_TBL VALUES (2- -1);

--Testcase 47:
INSERT INTO INT4_TBL VALUES (2 - -2);

--Testcase 48:
INSERT INTO INT4_TBL VALUES (4!);

--Testcase 49:
INSERT INTO INT4_TBL VALUES (!!3);

--Testcase 50:
INSERT INTO INT4_TBL VALUES (1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1);

--Testcase 51:
INSERT INTO INT4_TBL VALUES (2 + 2 / 2);

--Testcase 52:
INSERT INTO INT4_TBL VALUES ((2 + 2) / 2);

--Testcase 53:
SELECT * FROM INT4_TBL;

--Testcase 54:
DELETE FROM INT4_TBL;

-- corner case
--Testcase 55:
INSERT INTO INT4_TBL VALUES ((-1::int4<<31));
--Testcase 56:
INSERT INTO INT4_TBL VALUES (((-1::int4<<31)+1));
--Testcase 57:
SELECT * FROM INT4_TBL;
ROLLBACK;

-- check sane handling of INT_MIN overflow cases
--Testcase 58:
INSERT INTO INT4_TBL VALUES ((-2147483648)::int4 * (-1)::int4);
--Testcase 59:
INSERT INTO INT4_TBL VALUES ((-2147483648)::int4 / (-1)::int4);
--Testcase 60:
INSERT INTO INT4_TBL VALUES ((-2147483648)::int4 * (-1)::int2);
--Testcase 61:
INSERT INTO INT4_TBL VALUES ((-2147483648)::int4 / (-1)::int2);

DROP FOREIGN TABLE INT4_TBL;
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw CASCADE;
