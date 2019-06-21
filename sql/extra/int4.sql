--
-- INT4
--
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');
CREATE FOREIGN TABLE INT4_TBL(f1 int4 OPTIONS (key 'true')) SERVER sqlite_svr; 

INSERT INTO INT4_TBL(f1) VALUES ('   0  ');

INSERT INTO INT4_TBL(f1) VALUES ('123456     ');

INSERT INTO INT4_TBL(f1) VALUES ('    -123456');

INSERT INTO INT4_TBL(f1) VALUES ('34.5');

-- largest and smallest values
INSERT INTO INT4_TBL(f1) VALUES ('2147483647');

INSERT INTO INT4_TBL(f1) VALUES ('-2147483647');

-- bad input values -- should give errors
INSERT INTO INT4_TBL(f1) VALUES ('1000000000000');
INSERT INTO INT4_TBL(f1) VALUES ('asdf');
INSERT INTO INT4_TBL(f1) VALUES ('     ');
INSERT INTO INT4_TBL(f1) VALUES ('   asdf   ');
INSERT INTO INT4_TBL(f1) VALUES ('- 1234');
INSERT INTO INT4_TBL(f1) VALUES ('123       5');
INSERT INTO INT4_TBL(f1) VALUES ('');


SELECT '' AS five, * FROM INT4_TBL;

SELECT '' AS four, i.* FROM INT4_TBL i WHERE i.f1 <> int2 '0';

SELECT '' AS four, i.* FROM INT4_TBL i WHERE i.f1 <> int4 '0';

SELECT '' AS one, i.* FROM INT4_TBL i WHERE i.f1 = int2 '0';

SELECT '' AS one, i.* FROM INT4_TBL i WHERE i.f1 = int4 '0';

SELECT '' AS two, i.* FROM INT4_TBL i WHERE i.f1 < int2 '0';

SELECT '' AS two, i.* FROM INT4_TBL i WHERE i.f1 < int4 '0';

SELECT '' AS three, i.* FROM INT4_TBL i WHERE i.f1 <= int2 '0';

SELECT '' AS three, i.* FROM INT4_TBL i WHERE i.f1 <= int4 '0';

SELECT '' AS two, i.* FROM INT4_TBL i WHERE i.f1 > int2 '0';

SELECT '' AS two, i.* FROM INT4_TBL i WHERE i.f1 > int4 '0';

SELECT '' AS three, i.* FROM INT4_TBL i WHERE i.f1 >= int2 '0';

SELECT '' AS three, i.* FROM INT4_TBL i WHERE i.f1 >= int4 '0';

-- positive odds
SELECT '' AS one, i.* FROM INT4_TBL i WHERE (i.f1 % int2 '2') = int2 '1';

-- any evens
SELECT '' AS three, i.* FROM INT4_TBL i WHERE (i.f1 % int4 '2') = int2 '0';

SELECT '' AS five, i.f1, i.f1 * int2 '2' AS x FROM INT4_TBL i;

SELECT '' AS five, i.f1, i.f1 * int2 '2' AS x FROM INT4_TBL i
WHERE abs(f1) < 1073741824;

SELECT '' AS five, i.f1, i.f1 * int4 '2' AS x FROM INT4_TBL i;

SELECT '' AS five, i.f1, i.f1 * int4 '2' AS x FROM INT4_TBL i
WHERE abs(f1) < 1073741824;

SELECT '' AS five, i.f1, i.f1 + int2 '2' AS x FROM INT4_TBL i;

SELECT '' AS five, i.f1, i.f1 + int2 '2' AS x FROM INT4_TBL i
WHERE f1 < 2147483646;

SELECT '' AS five, i.f1, i.f1 + int4 '2' AS x FROM INT4_TBL i;

SELECT '' AS five, i.f1, i.f1 + int4 '2' AS x FROM INT4_TBL i
WHERE f1 < 2147483646;

SELECT '' AS five, i.f1, i.f1 - int2 '2' AS x FROM INT4_TBL i;

SELECT '' AS five, i.f1, i.f1 - int2 '2' AS x FROM INT4_TBL i
WHERE f1 > -2147483647;

SELECT '' AS five, i.f1, i.f1 - int4 '2' AS x FROM INT4_TBL i;

SELECT '' AS five, i.f1, i.f1 - int4 '2' AS x FROM INT4_TBL i
WHERE f1 > -2147483647;

SELECT '' AS five, i.f1, i.f1 / int2 '2' AS x FROM INT4_TBL i;

SELECT '' AS five, i.f1, i.f1 / int4 '2' AS x FROM INT4_TBL i;

--
-- more complex expressions
--

-- variations on unary minus parsing

BEGIN;

DELETE FROM INT4_TBL;

INSERT INTO INT4_TBL VALUES (-2+3);

INSERT INTO INT4_TBL VALUES (4-2);

INSERT INTO INT4_TBL VALUES (2- -1);

INSERT INTO INT4_TBL VALUES (2 - -2);

INSERT INTO INT4_TBL VALUES (4!);

INSERT INTO INT4_TBL VALUES (!!3);

INSERT INTO INT4_TBL VALUES (1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1);

INSERT INTO INT4_TBL VALUES (2 + 2 / 2);

INSERT INTO INT4_TBL VALUES ((2 + 2) / 2);

SELECT * FROM INT4_TBL;

DELETE FROM INT4_TBL;

-- corner case
INSERT INTO INT4_TBL VALUES ((-1::int4<<31));
INSERT INTO INT4_TBL VALUES (((-1::int4<<31)+1));
SELECT * FROM INT4_TBL;
ROLLBACK;

-- check sane handling of INT_MIN overflow cases
INSERT INTO INT4_TBL VALUES ((-2147483648)::int4 * (-1)::int4);
INSERT INTO INT4_TBL VALUES ((-2147483648)::int4 / (-1)::int4);
INSERT INTO INT4_TBL VALUES ((-2147483648)::int4 * (-1)::int2);
INSERT INTO INT4_TBL VALUES ((-2147483648)::int4 / (-1)::int2);

DROP FOREIGN TABLE INT4_TBL;
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw CASCADE;
