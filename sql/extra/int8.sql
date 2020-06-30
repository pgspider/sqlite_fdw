--
-- INT8
-- Test int8 64-bit integers.
--
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');
CREATE FOREIGN TABLE INT8_TBL(
	q1 int8 OPTIONS (key 'true'),
	q2 int8 OPTIONS (key 'true')
) SERVER sqlite_svr;

--Testcase 1:
INSERT INTO INT8_TBL VALUES('  123   ','  456');
--Testcase 2:
INSERT INTO INT8_TBL VALUES('123   ','4567890123456789');
--Testcase 3:
INSERT INTO INT8_TBL VALUES('4567890123456789','123');
--Testcase 4:
INSERT INTO INT8_TBL VALUES(+4567890123456789,'4567890123456789');
--Testcase 5:
INSERT INTO INT8_TBL VALUES('+4567890123456789','-4567890123456789');

-- bad inputs
--Testcase 6:
INSERT INTO INT8_TBL(q1) VALUES ('      ');
--Testcase 7:
INSERT INTO INT8_TBL(q1) VALUES ('xxx');
--Testcase 8:
INSERT INTO INT8_TBL(q1) VALUES ('3908203590239580293850293850329485');
--Testcase 9:
INSERT INTO INT8_TBL(q1) VALUES ('-1204982019841029840928340329840934');
--Testcase 10:
INSERT INTO INT8_TBL(q1) VALUES ('- 123');
--Testcase 11:
INSERT INTO INT8_TBL(q1) VALUES ('  345     5');
--Testcase 12:
INSERT INTO INT8_TBL(q1) VALUES ('');

--Testcase 13:
SELECT * FROM INT8_TBL;

-- int8/int8 cmp
--Testcase 14:
SELECT * FROM INT8_TBL WHERE q2 = 4567890123456789;
--Testcase 15:
SELECT * FROM INT8_TBL WHERE q2 <> 4567890123456789;
--Testcase 16:
SELECT * FROM INT8_TBL WHERE q2 < 4567890123456789;
--Testcase 17:
SELECT * FROM INT8_TBL WHERE q2 > 4567890123456789;
--Testcase 18:
SELECT * FROM INT8_TBL WHERE q2 <= 4567890123456789;
--Testcase 19:
SELECT * FROM INT8_TBL WHERE q2 >= 4567890123456789;

-- int8/int4 cmp
--Testcase 20:
SELECT * FROM INT8_TBL WHERE q2 = 456;
--Testcase 21:
SELECT * FROM INT8_TBL WHERE q2 <> 456;
--Testcase 22:
SELECT * FROM INT8_TBL WHERE q2 < 456;
--Testcase 23:
SELECT * FROM INT8_TBL WHERE q2 > 456;
--Testcase 24:
SELECT * FROM INT8_TBL WHERE q2 <= 456;
--Testcase 25:
SELECT * FROM INT8_TBL WHERE q2 >= 456;

-- int4/int8 cmp
--Testcase 26:
SELECT * FROM INT8_TBL WHERE 123 = q1;
--Testcase 27:
SELECT * FROM INT8_TBL WHERE 123 <> q1;
--Testcase 28:
SELECT * FROM INT8_TBL WHERE 123 < q1;
--Testcase 29:
SELECT * FROM INT8_TBL WHERE 123 > q1;
--Testcase 30:
SELECT * FROM INT8_TBL WHERE 123 <= q1;
--Testcase 31:
SELECT * FROM INT8_TBL WHERE 123 >= q1;

-- int8/int2 cmp
--Testcase 32:
SELECT * FROM INT8_TBL WHERE q2 = '456'::int2;
--Testcase 33:
SELECT * FROM INT8_TBL WHERE q2 <> '456'::int2;
--Testcase 34:
SELECT * FROM INT8_TBL WHERE q2 < '456'::int2;
--Testcase 35:
SELECT * FROM INT8_TBL WHERE q2 > '456'::int2;
--Testcase 36:
SELECT * FROM INT8_TBL WHERE q2 <= '456'::int2;
--Testcase 37:
SELECT * FROM INT8_TBL WHERE q2 >= '456'::int2;

-- int2/int8 cmp
--Testcase 38:
SELECT * FROM INT8_TBL WHERE '123'::int2 = q1;
--Testcase 39:
SELECT * FROM INT8_TBL WHERE '123'::int2 <> q1;
--Testcase 40:
SELECT * FROM INT8_TBL WHERE '123'::int2 < q1;
--Testcase 41:
SELECT * FROM INT8_TBL WHERE '123'::int2 > q1;
--Testcase 42:
SELECT * FROM INT8_TBL WHERE '123'::int2 <= q1;
--Testcase 43:
SELECT * FROM INT8_TBL WHERE '123'::int2 >= q1;


--Testcase 44:
SELECT '' AS five, q1 AS plus, -q1 AS minus FROM INT8_TBL;

--Testcase 45:
SELECT '' AS five, q1, q2, q1 + q2 AS plus FROM INT8_TBL;
--Testcase 46:
SELECT '' AS five, q1, q2, q1 - q2 AS minus FROM INT8_TBL;
--Testcase 47:
SELECT '' AS three, q1, q2, q1 * q2 AS multiply FROM INT8_TBL;
--Testcase 48:
SELECT '' AS three, q1, q2, q1 * q2 AS multiply FROM INT8_TBL
 WHERE q1 < 1000 or (q2 > 0 and q2 < 1000);
--Testcase 49:
SELECT '' AS five, q1, q2, q1 / q2 AS divide, q1 % q2 AS mod FROM INT8_TBL;

--Testcase 50:
SELECT '' AS five, q1, float8(q1) FROM INT8_TBL;
--Testcase 51:
SELECT '' AS five, q2, float8(q2) FROM INT8_TBL;

--Testcase 52:
SELECT 37 + q1 AS plus4 FROM INT8_TBL;
--Testcase 53:
SELECT 37 - q1 AS minus4 FROM INT8_TBL;
--Testcase 54:
SELECT '' AS five, 2 * q1 AS "twice int4" FROM INT8_TBL;
--Testcase 55:
SELECT '' AS five, q1 * 2 AS "twice int4" FROM INT8_TBL;

-- int8 op int4
--Testcase 56:
SELECT q1 + 42::int4 AS "8plus4", q1 - 42::int4 AS "8minus4", q1 * 42::int4 AS "8mul4", q1 / 42::int4 AS "8div4" FROM INT8_TBL;
-- int4 op int8
--Testcase 57:
SELECT 246::int4 + q1 AS "4plus8", 246::int4 - q1 AS "4minus8", 246::int4 * q1 AS "4mul8", 246::int4 / q1 AS "4div8" FROM INT8_TBL;

-- int8 op int2
--Testcase 58:
SELECT q1 + 42::int2 AS "8plus2", q1 - 42::int2 AS "8minus2", q1 * 42::int2 AS "8mul2", q1 / 42::int2 AS "8div2" FROM INT8_TBL;
-- int2 op int8
--Testcase 59:
SELECT 246::int2 + q1 AS "2plus8", 246::int2 - q1 AS "2minus8", 246::int2 * q1 AS "2mul8", 246::int2 / q1 AS "2div8" FROM INT8_TBL;

--Testcase 60:
SELECT q2, abs(q2) FROM INT8_TBL;
--Testcase 61:
SELECT min(q1), min(q2) FROM INT8_TBL;
--Testcase 62:
SELECT max(q1), max(q2) FROM INT8_TBL;


-- TO_CHAR()
--
--Testcase 63:
SELECT '' AS to_char_1, to_char(q1, '9G999G999G999G999G999'), to_char(q2, '9,999,999,999,999,999')
	FROM INT8_TBL;

--Testcase 64:
SELECT '' AS to_char_2, to_char(q1, '9G999G999G999G999G999D999G999'), to_char(q2, '9,999,999,999,999,999.999,999')
	FROM INT8_TBL;

--Testcase 65:
SELECT '' AS to_char_3, to_char( (q1 * -1), '9999999999999999PR'), to_char( (q2 * -1), '9999999999999999.999PR')
	FROM INT8_TBL;

--Testcase 66:
SELECT '' AS to_char_4, to_char( (q1 * -1), '9999999999999999S'), to_char( (q2 * -1), 'S9999999999999999')
	FROM INT8_TBL;

--Testcase 67:
SELECT '' AS to_char_5,  to_char(q2, 'MI9999999999999999')     FROM INT8_TBL;
--Testcase 68:
SELECT '' AS to_char_6,  to_char(q2, 'FMS9999999999999999')    FROM INT8_TBL;
--Testcase 69:
SELECT '' AS to_char_7,  to_char(q2, 'FM9999999999999999THPR') FROM INT8_TBL;
--Testcase 70:
SELECT '' AS to_char_8,  to_char(q2, 'SG9999999999999999th')   FROM INT8_TBL;
--Testcase 71:
SELECT '' AS to_char_9,  to_char(q2, '0999999999999999')       FROM INT8_TBL;
--Testcase 72:
SELECT '' AS to_char_10, to_char(q2, 'S0999999999999999')      FROM INT8_TBL;
--Testcase 73:
SELECT '' AS to_char_11, to_char(q2, 'FM0999999999999999')     FROM INT8_TBL;
--Testcase 74:
SELECT '' AS to_char_12, to_char(q2, 'FM9999999999999999.000') FROM INT8_TBL;
--Testcase 75:
SELECT '' AS to_char_13, to_char(q2, 'L9999999999999999.000')  FROM INT8_TBL;
--Testcase 76:
SELECT '' AS to_char_14, to_char(q2, 'FM9999999999999999.999') FROM INT8_TBL;
--Testcase 77:
SELECT '' AS to_char_15, to_char(q2, 'S 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 . 9 9 9') FROM INT8_TBL;
--Testcase 78:
SELECT '' AS to_char_16, to_char(q2, E'99999 "text" 9999 "9999" 999 "\\"text between quote marks\\"" 9999') FROM INT8_TBL;
--Testcase 79:
SELECT '' AS to_char_17, to_char(q2, '999999SG9999999999')     FROM INT8_TBL;

-- check min/max values and overflow behavior
--Testcase 80:
INSERT INTO INT8_TBL VALUES ('-9223372036854775808'::int8, 888);
--Testcase 81:
INSERT INTO INT8_TBL VALUES ('-9223372036854775809'::int8, 888);
--Testcase 82:
INSERT INTO INT8_TBL VALUES ('9223372036854775807'::int8, 888);
--Testcase 83:
INSERT INTO INT8_TBL VALUES ('9223372036854775808'::int8, 888);
--Testcase 84:
DELETE FROM INT8_TBL WHERE q2 = 888;

--Testcase 85:
INSERT INTO INT8_TBL VALUES (-('-9223372036854775807'::int8), 888);
--Testcase 86:
INSERT INTO INT8_TBL VALUES (-('-9223372036854775808'::int8), 888);

--Testcase 87:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 + '9223372036854775800'::int8, 888);
--Testcase 88:
INSERT INTO INT8_TBL VALUES ('-9223372036854775800'::int8 + '-9223372036854775800'::int8, 888);

--Testcase 89:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 - '-9223372036854775800'::int8, 888);
--Testcase 90:
INSERT INTO INT8_TBL VALUES ('-9223372036854775800'::int8 - '9223372036854775800'::int8, 888);

--Testcase 91:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 * '9223372036854775800'::int8, 888);

--Testcase 92:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 / '0'::int8, 888);
--Testcase 93:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 % '0'::int8, 888);

--Testcase 94:
INSERT INTO INT8_TBL VALUES (abs('-9223372036854775808'::int8), 888);

--Testcase 95:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 + '100'::int4, 888);
--Testcase 96:
INSERT INTO INT8_TBL VALUES ('-9223372036854775800'::int8 - '100'::int4, 888);
--Testcase 97:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 * '100'::int4, 888);

--Testcase 98:
INSERT INTO INT8_TBL VALUES ('100'::int4 + '9223372036854775800'::int8, 888);
--Testcase 99:
INSERT INTO INT8_TBL VALUES ('-100'::int4 - '9223372036854775800'::int8, 888);
--Testcase 100:
INSERT INTO INT8_TBL VALUES ('100'::int4 * '9223372036854775800'::int8, 888);

--Testcase 101:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 + '100'::int2, 888);
--Testcase 102:
INSERT INTO INT8_TBL VALUES ('-9223372036854775800'::int8 - '100'::int2, 888);
--Testcase 103:
INSERT INTO INT8_TBL VALUES ('9223372036854775800'::int8 * '100'::int2, 888);
--Testcase 104:
INSERT INTO INT8_TBL VALUES ('-9223372036854775808'::int8 / '0'::int2, 888);

--Testcase 105:
INSERT INTO INT8_TBL VALUES ('100'::int2 + '9223372036854775800'::int8, 888);
--Testcase 106:
INSERT INTO INT8_TBL VALUES ('-100'::int2 - '9223372036854775800'::int8, 888);
--Testcase 107:
INSERT INTO INT8_TBL VALUES ('100'::int2 * '9223372036854775800'::int8, 888);
--Testcase 108:
INSERT INTO INT8_TBL VALUES ('100'::int2 / '0'::int8, 888);

--Testcase 109:
DELETE FROM INT8_TBL WHERE q2 = 888;

--Testcase 110:
SELECT CAST(q1 AS int4) FROM int8_tbl WHERE q2 = 456;
--Testcase 111:
SELECT CAST(q1 AS int4) FROM int8_tbl WHERE q2 <> 456;

--Testcase 112:
SELECT CAST(q1 AS int2) FROM int8_tbl WHERE q2 = 456;
--Testcase 113:
SELECT CAST(q1 AS int2) FROM int8_tbl WHERE q2 <> 456;

--Testcase 114:
SELECT CAST(q1 AS float4), CAST(q2 AS float8) FROM INT8_TBL;

--Testcase 115:
SELECT CAST(q1 AS oid) FROM INT8_TBL;

-- bit operations

--Testcase 116:
SELECT q1, q2, q1 & q2 AS "and", q1 | q2 AS "or", q1 # q2 AS "xor", ~q1 AS "not" FROM INT8_TBL;
--Testcase 117:
SELECT q1, q1 << 2 AS "shl", q1 >> 3 AS "shr" FROM INT8_TBL;


-- generate_series

--Testcase 118:
INSERT INTO INT8_TBL SELECT q1, 888 FROM generate_series('+4567890123456789'::int8, '+4567890123456799'::int8) q1;
--Testcase 119:
SELECT q1 AS generate_series FROM INT8_TBL WHERE q2 = 888;
--Testcase 120:
DELETE FROM INT8_TBL WHERE q2 = 888;
--Testcase 121:
INSERT INTO INT8_TBL SELECT q1, 888 FROM generate_series('+4567890123456789'::int8, '+4567890123456799'::int8, 0) q1; -- should error
--Testcase 122:
INSERT INTO INT8_TBL SELECT q1, 888 FROM generate_series('+4567890123456789'::int8, '+4567890123456799'::int8, 2) q1;
--Testcase 123:
SELECT q1 AS generate_series FROM INT8_TBL WHERE q2 = 888;
--Testcase 124:
DELETE FROM INT8_TBL WHERE q2 = 888;

-- check sane handling of INT64_MIN overflow cases
--Testcase 125:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 * (-1)::int8, 888);
--Testcase 126:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 / (-1)::int8, 888);
--Testcase 127:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 % (-1)::int8, 888);
--Testcase 128:
SELECT q1 FROM INT8_TBL WHERE q2 = 888;
--Testcase 129:
DELETE FROM INT8_TBL WHERE q2 = 888;
--Testcase 130:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 * (-1)::int4, 888);
--Testcase 131:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 / (-1)::int4, 888);
--Testcase 132:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 % (-1)::int4, 888);
--Testcase 133:
SELECT q1 FROM INT8_TBL WHERE q2 = 888;
--Testcase 134:
DELETE FROM INT8_TBL WHERE q2 = 888;
--Testcase 135:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 * (-1)::int2, 888);
--Testcase 136:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 / (-1)::int2, 888);
--Testcase 137:
INSERT INTO INT8_TBL VALUES ((-9223372036854775808)::int8 % (-1)::int2, 888);
--Testcase 138:
SELECT q1 FROM INT8_TBL WHERE q2 = 888;
--Testcase 139:
DELETE FROM INT8_TBL WHERE q2 = 888;

DROP FOREIGN TABLE INT8_TBL;
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw CASCADE;
