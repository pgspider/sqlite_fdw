--
-- INT4 Based on PostgreSQL tests, please don't add additional tests here, use other test files
--
--Testcase 61:
CREATE EXTENSION sqlite_fdw;
--Testcase 62:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/core.db');
--Testcase 63:
CREATE FOREIGN TABLE INT4_TBL(f1 int4 OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 64:
CREATE FOREIGN TABLE INT4_TMP(f1 int4, f2 int4, id int OPTIONS (key 'true')) SERVER sqlite_svr; 
 
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
SELECT * FROM INT4_TBL;

-- Also try it with non-error-throwing API
--Testcase 137:
CREATE FOREIGN TABLE NON_ERROR_THROWING_API_INT4(f1 text, id serial OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 138:
INSERT INTO NON_ERROR_THROWING_API_INT4 VALUES ('34', 1), ('asdf', 2), ('1000000000000', 3);
--Testcase 139:
SELECT pg_input_is_valid(f1, 'int4') FROM NON_ERROR_THROWING_API_INT4 WHERE id = 1;
--Testcase 140:
SELECT pg_input_is_valid(f1, 'int4') FROM NON_ERROR_THROWING_API_INT4 WHERE id = 2;
--Testcase 141:
SELECT pg_input_is_valid(f1, 'int4') FROM NON_ERROR_THROWING_API_INT4 WHERE id = 3;
--Testcase 142:
SELECT * FROM pg_input_error_info((SELECT f1 FROM NON_ERROR_THROWING_API_INT4 WHERE id = 3), 'int4');

--Testcase 15:
SELECT i.* FROM INT4_TBL i WHERE i.f1 <> int2 '0';

--Testcase 16:
SELECT i.* FROM INT4_TBL i WHERE i.f1 <> int4 '0';

--Testcase 17:
SELECT i.* FROM INT4_TBL i WHERE i.f1 = int2 '0';

--Testcase 18:
SELECT i.* FROM INT4_TBL i WHERE i.f1 = int4 '0';

--Testcase 19:
SELECT i.* FROM INT4_TBL i WHERE i.f1 < int2 '0';

--Testcase 20:
SELECT i.* FROM INT4_TBL i WHERE i.f1 < int4 '0';

--Testcase 21:
SELECT i.* FROM INT4_TBL i WHERE i.f1 <= int2 '0';

--Testcase 22:
SELECT i.* FROM INT4_TBL i WHERE i.f1 <= int4 '0';

--Testcase 23:
SELECT i.* FROM INT4_TBL i WHERE i.f1 > int2 '0';

--Testcase 24:
SELECT i.* FROM INT4_TBL i WHERE i.f1 > int4 '0';

--Testcase 25:
SELECT i.* FROM INT4_TBL i WHERE i.f1 >= int2 '0';

--Testcase 26:
SELECT i.* FROM INT4_TBL i WHERE i.f1 >= int4 '0';

-- positive odds
--Testcase 27:
SELECT i.* FROM INT4_TBL i WHERE (i.f1 % int2 '2') = int2 '1';

-- any evens
--Testcase 28:
SELECT i.* FROM INT4_TBL i WHERE (i.f1 % int4 '2') = int2 '0';

--Testcase 29:
SELECT i.f1, i.f1 * int2 '2' AS x FROM INT4_TBL i;

--Testcase 30:
SELECT i.f1, i.f1 * int2 '2' AS x FROM INT4_TBL i
WHERE abs(f1) < 1073741824;

--Testcase 31:
SELECT i.f1, i.f1 * int4 '2' AS x FROM INT4_TBL i;

--Testcase 32:
SELECT i.f1, i.f1 * int4 '2' AS x FROM INT4_TBL i
WHERE abs(f1) < 1073741824;

--Testcase 33:
SELECT i.f1, i.f1 + int2 '2' AS x FROM INT4_TBL i;

--Testcase 34:
SELECT i.f1, i.f1 + int2 '2' AS x FROM INT4_TBL i
WHERE f1 < 2147483646;

--Testcase 35:
SELECT i.f1, i.f1 + int4 '2' AS x FROM INT4_TBL i;

--Testcase 36:
SELECT i.f1, i.f1 + int4 '2' AS x FROM INT4_TBL i
WHERE f1 < 2147483646;

--Testcase 37:
SELECT i.f1, i.f1 - int2 '2' AS x FROM INT4_TBL i;

--Testcase 38:
SELECT i.f1, i.f1 - int2 '2' AS x FROM INT4_TBL i
WHERE f1 > -2147483647;

--Testcase 39:
SELECT i.f1, i.f1 - int4 '2' AS x FROM INT4_TBL i;

--Testcase 40:
SELECT i.f1, i.f1 - int4 '2' AS x FROM INT4_TBL i
WHERE f1 > -2147483647;

--Testcase 41:
SELECT i.f1, i.f1 / int2 '2' AS x FROM INT4_TBL i;

--Testcase 42:
SELECT i.f1, i.f1 / int4 '2' AS x FROM INT4_TBL i;

--
-- more complex expressions
--

-- variations on unary minus parsing

--Testcase 65:
DELETE FROM INT4_TMP;
--Testcase 66:
INSERT INTO INT4_TMP VALUES (-2, 3);
--Testcase 67:
SELECT f1 + f2 as one FROM INT4_TMP;

--Testcase 68:
DELETE FROM INT4_TMP;
--Testcase 69:
INSERT INTO INT4_TMP VALUES (4, 2);
--Testcase 70:
SELECT f1 - f2 as two FROM INT4_TMP;

--Testcase 46:
DELETE FROM INT4_TMP;
--Testcase 71:
INSERT INTO INT4_TMP VALUES (2, 1);
--Testcase 72:
SELECT f1- -f2 as three FROM INT4_TMP;

--Testcase 47:
DELETE FROM INT4_TMP;
--Testcase 73:
INSERT INTO INT4_TMP VALUES (2, 2);
--Testcase 74:
SELECT f1 - -f2 as four FROM INT4_TMP;

--Testcase 75:
DELETE FROM INT4_TMP;
--Testcase 76:
INSERT INTO INT4_TMP VALUES ('2'::int2 * '2'::int2, '16'::int2 / '4'::int2);
--Testcase 77:
SELECT f1 = f2 AS true FROM INT4_TMP;

--Testcase 78:
DELETE FROM INT4_TMP;
--Testcase 79:
INSERT INTO INT4_TMP VALUES ('2'::int2 * '2'::int4, '16'::int2 / '4'::int4);
--Testcase 80:
SELECT f1 = f2 AS true FROM INT4_TMP;

--Testcase 81:
DELETE FROM INT4_TMP;
--Testcase 82:
INSERT INTO INT4_TMP VALUES ('2'::int4 * '2'::int2, '16'::int4 / '4'::int2);
--Testcase 83:
SELECT f1 = f2 AS true FROM INT4_TMP;

--Testcase 84:
DELETE FROM INT4_TMP;
--Testcase 85:
INSERT INTO INT4_TMP VALUES ('1000'::int4, '999'::int4);
--Testcase 86:
SELECT f1 < f2 AS false FROM INT4_TMP;

--Testcase 50:
DELETE FROM INT4_TMP;
--Testcase 91:
INSERT INTO INT4_TMP VALUES (1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1);
--Testcase 92:
SELECT f1 as ten FROM INT4_TMP;

--Testcase 51:
DELETE FROM INT4_TMP;
--Testcase 93:
INSERT INTO INT4_TMP VALUES (2 , 2);
--Testcase 94:
SELECT f1 + f1/f2 as three FROM INT4_TMP;

--Testcase 52:
DELETE FROM INT4_TMP;
--Testcase 95:
INSERT INTO INT4_TMP VALUES (2 , 2);
--Testcase 96:
SELECT (f1 + f2)/f2 as two FROM INT4_TMP;

-- corner case
--Testcase 54:
DELETE FROM INT4_TMP;
--Testcase 97:
INSERT INTO INT4_TMP VALUES (-1);
--Testcase 98:
SELECT (f1<<31)::text FROM INT4_TMP;

--Testcase 56:
DELETE FROM INT4_TMP;
--Testcase 99:
INSERT INTO INT4_TMP VALUES (-1);
--Testcase 100:
SELECT ((f1<<31)+1)::text FROM INT4_TMP;

-- check sane handling of INT_MIN overflow cases
--Testcase 58:
DELETE FROM INT4_TMP;
--Testcase 101:
INSERT INTO INT4_TMP VALUES ((-2147483648)::int4, (-1)::int4);
--Testcase 102:
SELECT f1 * f2 FROM INT4_TMP;
--Testcase 103:
SELECT f1 / f2 FROM INT4_TMP;
--Testcase 104:
SELECT f1 % f2 FROM INT4_TMP;

--Testcase 60:
DELETE FROM INT4_TMP;
--Testcase 105:
INSERT INTO INT4_TMP VALUES ((-2147483648)::int4, (-1)::int2);
--Testcase 106:
SELECT f1 * f2 FROM INT4_TMP;
--Testcase 107:
SELECT f1 / f2 FROM INT4_TMP;
--Testcase 108:
SELECT f1 % f2 FROM INT4_TMP;

-- check rounding when casting from float
--Testcase 109:
CREATE FOREIGN TABLE FLOAT8_TMP(f1 float8, id int OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 110:
DELETE FROM FLOAT8_TMP;
--Testcase 111:
INSERT INTO FLOAT8_TMP VALUES 
             (-2.5::float8),
             (-1.5::float8),
             (-0.5::float8),
             (0.0::float8),
             (0.5::float8),
             (1.5::float8),
             (2.5::float8);

--Testcase 112:
SELECT f1 as x, f1::int4 as int4_value FROM FLOAT8_TMP;

-- check rounding when casting from numeric
--Testcase 113:
CREATE FOREIGN TABLE NUMERIC_TMP(f1 numeric, id int OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 114:
DELETE FROM NUMERIC_TMP;
--Testcase 115:
INSERT INTO NUMERIC_TMP VALUES
             (-2.5::numeric),
             (-1.5::numeric),
             (-0.5::numeric),
             (0.0::numeric),
             (0.5::numeric),
             (1.5::numeric),
             (2.5::numeric);
--Testcase 116:
SELECT f1 as x, f1::int4 as int4_value FROM NUMERIC_TMP;

-- test gcd()
--Testcase 117:
DELETE FROM INT4_TMP;
--Testcase 118:
INSERT INTO INT4_TMP VALUES
             (0::int4, 0::int4),
             (0::int4, 6410818::int4),
             (61866666::int4, 6410818::int4),
             (-61866666::int4, 6410818::int4),
             ((-2147483648)::int4, 1::int4),
             ((-2147483648)::int4, 2147483647::int4),
             ((-2147483648)::int4, 1073741824::int4);
--Testcase 119:
SELECT f1, f2, gcd(f1, f2), gcd(f1, -f2), gcd(f2, f1), gcd(-f2, f1) FROM INT4_TMP;

--Testcase 120:
DELETE FROM INT4_TMP;
--Testcase 121:
INSERT INTO INT4_TMP VALUES ((-2147483648)::int4, 0::int4);
--Testcase 122:
SELECT gcd(f1, f2) FROM INT4_TMP; -- overflow

--Testcase 123:
DELETE FROM INT4_TMP;
--Testcase 124:
INSERT INTO INT4_TMP VALUES ((-2147483648)::int4, (-2147483648)::int4);
--Testcase 125:
SELECT gcd(f1, f2) FROM INT4_TMP; -- overflow

-- test lcm()
--Testcase 126:
DELETE FROM INT4_TMP;
--Testcase 127:
INSERT INTO INT4_TMP VALUES
             (0::int4, 0::int4),
             (0::int4, 42::int4),
             (42::int4, 42::int4),
             (330::int4, 462::int4),
             (-330::int4, 462::int4),
             ((-2147483648)::int4, 0::int4);
--Testcase 128:
SELECT f1, f2, lcm(f1, f2), lcm(f1, -f2), lcm(f2, f1), lcm(-f2, f1) FROM INT4_TMP;

--Testcase 129:
DELETE FROM INT4_TMP;
--Testcase 130:
INSERT INTO INT4_TMP VALUES ((-2147483648)::int4, 1::int4);
--Testcase 131:
SELECT lcm(f1, f2) FROM INT4_TMP; -- overflow

--Testcase 132:
DELETE FROM INT4_TMP;
--Testcase 133:
INSERT INTO INT4_TMP VALUES (2147483647::int4, 2147483646::int4);
--Testcase 134:
SELECT lcm(f1, f2) FROM INT4_TMP; -- overflow

-- non-decimal literals
--Testcase 143:
CREATE FOREIGN TABLE special_case_int4 (f1 text, id int OPTIONS (key 'true')) SERVER sqlite_svr;
--Testcase 144:
INSERT INTO special_case_int4 VALUES ('0b100101'::int4);
--Testcase 145:
SELECT f1 FROM special_case_int4;

--Testcase 146:
DELETE FROM special_case_int4;
--Testcase 147:
INSERT INTO special_case_int4 VALUES ('0o273'::int4);
--Testcase 148:
SELECT f1 FROM special_case_int4;

--Testcase 149:
DELETE FROM special_case_int4;
--Testcase 150:
INSERT INTO special_case_int4 VALUES ('0x42F'::int4);
--Testcase 151:
SELECT f1 FROM special_case_int4;

--Testcase 152:
DELETE FROM special_case_int4;
--Testcase 153:
INSERT INTO special_case_int4 VALUES ('0b'::int4);
--Testcase 154:
SELECT f1 FROM special_case_int4;

--Testcase 155:
DELETE FROM special_case_int4;
--Testcase 156:
INSERT INTO special_case_int4 VALUES ('0x'::int4);
--Testcase 157:
SELECT f1 FROM special_case_int4;

--Testcase 158:
DELETE FROM special_case_int4;
--Testcase 159:
INSERT INTO special_case_int4 VALUES ('0x'::int4);
--Testcase 160:
SELECT f1 FROM special_case_int4;

-- cases near overflow
--Testcase 161:
DELETE FROM special_case_int4;
--Testcase 162:
INSERT INTO special_case_int4 VALUES ('0b1111111111111111111111111111111'::int4);
--Testcase 163:
SELECT f1 FROM special_case_int4;

--Testcase 164:
DELETE FROM special_case_int4;
--Testcase 165:
INSERT INTO special_case_int4 VALUES ('0b10000000000000000000000000000000'::int4);
--Testcase 166:
SELECT f1 FROM special_case_int4;

--Testcase 167:
DELETE FROM special_case_int4;
--Testcase 168:
INSERT INTO special_case_int4 VALUES ('0o17777777777'::int4);
--Testcase 169:
SELECT f1 FROM special_case_int4;

--Testcase 170:
DELETE FROM special_case_int4;
--Testcase 171:
INSERT INTO special_case_int4 VALUES ('0o20000000000'::int4);
--Testcase 172:
SELECT f1 FROM special_case_int4;

--Testcase 173:
DELETE FROM special_case_int4;
--Testcase 174:
INSERT INTO special_case_int4 VALUES ('0x7FFFFFFF'::int4);
--Testcase 175:
SELECT f1 FROM special_case_int4;

--Testcase 176:
DELETE FROM special_case_int4;
--Testcase 177:
INSERT INTO special_case_int4 VALUES ('0x80000000'::int4);
--Testcase 178:
SELECT f1 FROM special_case_int4;

--Testcase 179:
DELETE FROM special_case_int4;
--Testcase 180:
INSERT INTO special_case_int4 VALUES ('-0b10000000000000000000000000000000'::int4);
--Testcase 181:
SELECT f1 FROM special_case_int4;

--Testcase 182:
DELETE FROM special_case_int4;
--Testcase 183:
INSERT INTO special_case_int4 VALUES ('-0b10000000000000000000000000000001'::int4);
--Testcase 184:
SELECT f1 FROM special_case_int4;

--Testcase 185:
DELETE FROM special_case_int4;
--Testcase 186:
INSERT INTO special_case_int4 VALUES ('-0o20000000000'::int4);
--Testcase 187:
SELECT f1 FROM special_case_int4;

--Testcase 188:
DELETE FROM special_case_int4;
--Testcase 189:
INSERT INTO special_case_int4 VALUES ('-0o20000000001'::int4);
--Testcase 190:
SELECT f1 FROM special_case_int4;

--Testcase 191:
DELETE FROM special_case_int4;
--Testcase 192:
INSERT INTO special_case_int4 VALUES ('-0x80000000'::int4);
--Testcase 193:
SELECT f1 FROM special_case_int4;

--Testcase 194:
DELETE FROM special_case_int4;
--Testcase 195:
INSERT INTO special_case_int4 VALUES ('-0x80000001'::int4);
--Testcase 196:
SELECT f1 FROM special_case_int4;


-- underscores
--Testcase 197:
DELETE FROM special_case_int4;
--Testcase 198:
INSERT INTO special_case_int4 VALUES ('1_000_000'::int4);
--Testcase 199:
SELECT f1 FROM special_case_int4;

--Testcase 200:
DELETE FROM special_case_int4;
--Testcase 201:
INSERT INTO special_case_int4 VALUES ('1_2_3'::int4);
--Testcase 202:
SELECT f1 FROM special_case_int4;

--Testcase 203:
DELETE FROM special_case_int4;
--Testcase 204:
INSERT INTO special_case_int4 VALUES ('0x1EEE_FFFF'::int4);
--Testcase 205:
SELECT f1 FROM special_case_int4;

--Testcase 206:
DELETE FROM special_case_int4;
--Testcase 207:
INSERT INTO special_case_int4 VALUES ('0o2_73'::int4);
--Testcase 208:
SELECT f1 FROM special_case_int4;

--Testcase 209:
DELETE FROM special_case_int4;
--Testcase 210:
INSERT INTO special_case_int4 VALUES ('0b_10_0101'::int4);
--Testcase 211:
SELECT f1 FROM special_case_int4;

-- error cases
--Testcase 212:
DELETE FROM special_case_int4;
--Testcase 213:
INSERT INTO special_case_int4 VALUES ('_100'::int4);
--Testcase 214:
SELECT f1 FROM special_case_int4;

--Testcase 215:
DELETE FROM special_case_int4;
--Testcase 216:
INSERT INTO special_case_int4 VALUES ('100_'::int4);
--Testcase 217:
SELECT f1 FROM special_case_int4;

--Testcase 218:
DELETE FROM special_case_int4;
--Testcase 219:
INSERT INTO special_case_int4 VALUES ('100__000'::int4);
--Testcase 220:
SELECT f1 FROM special_case_int4;

--Testcase 221:
DELETE FROM INT4_TBL;
-- Clean up
DO $d$
declare
  l_rec record;
begin
  for l_rec in (select foreign_table_schema, foreign_table_name 
                from information_schema.foreign_tables) loop
     execute format('drop foreign table %I.%I cascade;', l_rec.foreign_table_schema, l_rec.foreign_table_name);
  end loop;
end;
$d$;

--Testcase 135:
DROP SERVER sqlite_svr;
--Testcase 136:
DROP EXTENSION sqlite_fdw CASCADE;
