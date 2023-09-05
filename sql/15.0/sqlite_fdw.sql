--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 129:
CREATE EXTENSION sqlite_fdw;
--Testcase 130:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
--Testcase 131:
CREATE FOREIGN TABLE department(department_id int OPTIONS (key 'true'), department_name text) SERVER sqlite_svr; 
--Testcase 132:
CREATE FOREIGN TABLE employee(emp_id int OPTIONS (key 'true'), emp_name text, emp_dept_id int) SERVER sqlite_svr;
--Testcase 133:
CREATE FOREIGN TABLE empdata(emp_id int OPTIONS (key 'true'), emp_dat bytea) SERVER sqlite_svr;
--Testcase 134:
CREATE FOREIGN TABLE numbers(a int OPTIONS (key 'true'), b varchar(255)) SERVER sqlite_svr;
--Testcase 135:
CREATE FOREIGN TABLE multiprimary(a int, b int OPTIONS (key 'true'), c int OPTIONS(key 'true')) SERVER sqlite_svr;
--Testcase 136:
CREATE FOREIGN TABLE noprimary(a int, b text) SERVER sqlite_svr;

-- updatable option test (github pull 59)
CREATE FOREIGN TABLE RO_RW_test(i int OPTIONS (key 'true'), a text, b float, c int) SERVER sqlite_svr;

--Testcase 1:
SELECT * FROM department LIMIT 10;
--Testcase 2:
SELECT * FROM employee LIMIT 10;
--Testcase 3:
SELECT * FROM empdata LIMIT 10;

--Testcase 4:
INSERT INTO department VALUES(generate_series(1,100), 'dept - ' || generate_series(1,100));
--Testcase 5:
INSERT INTO employee VALUES(generate_series(1,100), 'emp - ' || generate_series(1,100), generate_series(1,100));
--Testcase 6:
INSERT INTO empdata  VALUES(1, decode ('01234567', 'hex'));

--Testcase 7:
INSERT INTO numbers VALUES(1, 'One');
--Testcase 8:
INSERT INTO numbers VALUES(2, 'Two');
--Testcase 9:
INSERT INTO numbers VALUES(3, 'Three');
--Testcase 10:
INSERT INTO numbers VALUES(4, 'Four');
--Testcase 11:
INSERT INTO numbers VALUES(5, 'Five');
--Testcase 12:
INSERT INTO numbers VALUES(6, 'Six');
--Testcase 13:
INSERT INTO numbers VALUES(7, 'Seven');
--Testcase 14:
INSERT INTO numbers VALUES(8, 'Eight');
--Testcase 15:
INSERT INTO numbers VALUES(9, 'Nine');

--Testcase 16:
SELECT count(*) FROM department;
--Testcase 17:
SELECT count(*) FROM employee;
--Testcase 18:
SELECT count(*) FROM empdata;

--Testcase 19:
EXPLAIN (COSTS FALSE) SELECT * FROM department d, employee e WHERE d.department_id = e.emp_dept_id LIMIT 10;

--Testcase 20:
EXPLAIN (COSTS FALSE) SELECT * FROM department d, employee e WHERE d.department_id IN (SELECT department_id FROM department) LIMIT 10;

--Testcase 21:
SELECT * FROM department d, employee e WHERE d.department_id = e.emp_dept_id LIMIT 10;
--Testcase 22:
SELECT * FROM department d, employee e WHERE d.department_id IN (SELECT department_id FROM department) ORDER BY d.department_id LIMIT 10;
--Testcase 23:
SELECT * FROM empdata;

--Testcase 24:
DELETE FROM employee WHERE emp_id = 10;

--Testcase 25:
SELECT COUNT(*) FROM department LIMIT 10;
--Testcase 26:
SELECT COUNT(*) FROM employee WHERE emp_id = 10;

--Testcase 27:
UPDATE employee SET emp_name = 'UPDATEd emp' WHERE emp_id = 20;
--Testcase 28:
SELECT emp_id, emp_name FROM employee WHERE emp_name like 'UPDATEd emp';

--Testcase 29:
UPDATE empdata SET emp_dat = decode ('0123', 'hex');
--Testcase 30:
SELECT * FROM empdata;

--Testcase 31:
SELECT * FROM employee LIMIT 10;
--Testcase 32:
SELECT * FROM employee WHERE emp_id IN (1);
--Testcase 33:
SELECT * FROM employee WHERE emp_id IN (1,3,4,5);
--Testcase 34:
SELECT * FROM employee WHERE emp_id IN (10000,1000);

--Testcase 35:
SELECT * FROM employee WHERE emp_id NOT IN (1) LIMIT 5;
--Testcase 36:
SELECT * FROM employee WHERE emp_id NOT IN (1,3,4,5) LIMIT 5;
--Testcase 37:
SELECT * FROM employee WHERE emp_id NOT IN (10000,1000) LIMIT 5;

--Testcase 38:
SELECT * FROM employee WHERE emp_id NOT IN (SELECT emp_id FROM employee WHERE emp_id IN (1,10));
--Testcase 39:
SELECT * FROM employee WHERE emp_name NOT IN ('emp - 1', 'emp - 2') LIMIT 5;
--Testcase 40:
SELECT * FROM employee WHERE emp_name NOT IN ('emp - 10') LIMIT 5;

--Testcase 41:
SELECT * FROM numbers WHERE (CASE WHEN a % 2 = 0 THEN 1 WHEN a % 5 = 0 THEN 1 ELSE 0 END) = 1;
--Testcase 42:
SELECT * FROM numbers WHERE (CASE b WHEN 'Two' THEN 1 WHEN 'Six' THEN 1 ELSE 0 END) = 1;

--Testcase 152:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE (round(abs(a)) = 1);
--Testcase 153:
SELECT * FROM numbers WHERE (round(abs(a)) = 1);

--Testcase 137:
create or replace function test_param_WHERE() returns void as $$
DECLARE
  n varchar;
BEGIN
  FOR x IN 1..9 LOOP
--Testcase 138:
    SELECT b INTO n from numbers WHERE a=x;
    raise notice 'Found number %', n;
  end loop;
  return;
END
$$ LANGUAGE plpgsql;
--Testcase 43:
SELECT test_param_WHERE();

--Testcase 44:
SELECT b from numbers WHERE a=1;
--Testcase 45:
EXPLAIN(COSTS OFF) SELECT b from numbers WHERE a=1;

--Testcase 46:
SELECT a FROM numbers WHERE b = (SELECT NULL::text);


--Testcase 47:
PREPARE stmt1 (int, int) AS
  SELECT * FROM numbers WHERE a=$1 or a=$2;
--Testcase 48:
EXECUTE stmt1(1,2);
--Testcase 49:
EXECUTE stmt1(2,2); 
--Testcase 50:
EXECUTE stmt1(3,2); 
--Testcase 51:
EXECUTE stmt1(4,2);
-- generic plan
--Testcase 52:
EXECUTE stmt1(5,2); 
--Testcase 53:
EXECUTE stmt1(6,2); 
--Testcase 54:
EXECUTE stmt1(7,2); 

--Testcase 55:
DELETE FROM employee;
--Testcase 56:
DELETE FROM department;
--Testcase 57:
DELETE FROM empdata;
--Testcase 58:
DELETE FROM numbers;

BEGIN;
--Testcase 59:
INSERT INTO numbers VALUES(1, 'One');
--Testcase 60:
INSERT INTO numbers VALUES(2, 'Two');
COMMIT;

--Testcase 61:
SELECT * from numbers;

BEGIN;
--Testcase 62:
INSERT INTO numbers VALUES(3, 'Three');
ROLLBACK;
--Testcase 63:
SELECT * from numbers;

BEGIN;
--Testcase 64:
INSERT INTO numbers VALUES(4, 'Four');
SAVEPOINT my_savepoint;
--Testcase 65:
INSERT INTO numbers VALUES(5, 'Five');
ROLLBACK TO SAVEPOINT my_savepoint;
--Testcase 66:
INSERT INTO numbers VALUES(6, 'Six');
COMMIT;

--Testcase 67:
SELECT * from numbers;

-- duplicate key
--Testcase 68:
INSERT INTO numbers VALUES(1, 'One');
--Testcase 69:
DELETE from numbers;

BEGIN;
--Testcase 70:
INSERT INTO numbers VALUES(1, 'One');
--Testcase 71:
INSERT INTO numbers VALUES(2, 'Two');
COMMIT;
-- violate unique constraint
--Testcase 72:
UPDATE numbers SET b='Two' WHERE a = 1; 
--Testcase 73:
SELECT * from numbers;

-- push down
--Testcase 74:
explain (verbose, costs off) SELECT * from numbers WHERE  a = any(ARRAY[2,3,4,5]::int[]);
-- (1,2,3) is pushed down
--Testcase 75:
explain (verbose, costs off) SELECT * from numbers WHERE a in (1,2,3) AND (1,2) < (a,5);

--Testcase 76:
explain (verbose, costs off) SELECT * from numbers WHERE a in (a+2*a,5);

--Testcase 77:
explain (verbose, costs off) SELECT * from numbers WHERE  a = any(ARRAY[1,2,a]::int[]);

--Testcase 78:
SELECT * from numbers WHERE  a = any(ARRAY[2,3,4,5]::int[]);
--Testcase 79:
SELECT * from numbers WHERE  a = any(ARRAY[1,2,a]::int[]);

-- ANY with ARRAY expression
--Testcase 154:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a = ANY(ARRAY[1, a + 1]);
--Testcase 155:
SELECT * FROM numbers WHERE a = ANY(ARRAY[1, a + 1]);

--Testcase 156:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <> ANY(ARRAY[1, a + 1]);
--Testcase 157:
SELECT * FROM numbers WHERE a <> ANY(ARRAY[1, a + 1]);

--Testcase 158:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a >= ANY(ARRAY[1, a + 1]);
--Testcase 159:
SELECT * FROM numbers WHERE a >= ANY(ARRAY[1, a + 1]);

--Testcase 160:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <= ANY(ARRAY[1, a + 1]);
--Testcase 161:
SELECT * FROM numbers WHERE a <= ANY(ARRAY[1, a + 1]);

--Testcase 162:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a > ANY(ARRAY[1, a + 1]);
--Testcase 163:
SELECT * FROM numbers WHERE a > ANY(ARRAY[1, a + 1]);

--Testcase 164:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a < ANY(ARRAY[1, a + 1]);
--Testcase 165:
SELECT * FROM numbers WHERE a < ANY(ARRAY[1, a + 1]);

-- ANY with ARRAY const
--Testcase 166:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a = ANY(ARRAY[1, 2]);
--Testcase 167:
SELECT * FROM numbers WHERE a = ANY(ARRAY[1, 2]);

--Testcase 168:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <> ANY(ARRAY[1, 2]);
--Testcase 169:
SELECT * FROM numbers WHERE a <> ANY(ARRAY[1, 2]);

--Testcase 170:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a >= ANY(ARRAY[1, 2]);
--Testcase 171:
SELECT * FROM numbers WHERE a >= ANY(ARRAY[1, 2]);

--Testcase 172:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <= ANY(ARRAY[1, 2]);
--Testcase 173:
SELECT * FROM numbers WHERE a <= ANY(ARRAY[1, 2]);

--Testcase 174:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a > ANY(ARRAY[1, 2]);
--Testcase 175:
SELECT * FROM numbers WHERE a > ANY(ARRAY[1, 2]);

--Testcase 176:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a < ANY(ARRAY[1, 2]);
--Testcase 177:
SELECT * FROM numbers WHERE a < ANY(ARRAY[1, 2]);

--Testcase 210:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a = ANY('{1, 2, 3}');
--Testcase 211:
SELECT * FROM numbers WHERE a = ANY('{1, 2, 3}');

--Testcase 212:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <> ANY('{1, 2, 3}');
--Testcase 213:
SELECT * FROM numbers WHERE a <> ANY('{1, 2, 3}');

-- ALL with ARRAY expression
--Testcase 178:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a = ALL(ARRAY[1, a * 1]);
--Testcase 179:
SELECT * FROM numbers WHERE a = ALL(ARRAY[1, a * 1]);

--Testcase 180:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <> ALL(ARRAY[1, a + 1]);
--Testcase 181:
SELECT * FROM numbers WHERE a <> ALL(ARRAY[1, a + 1]);

--Testcase 182:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a >= ALL(ARRAY[1, a / 1]);
--Testcase 183:
SELECT * FROM numbers WHERE a >= ALL(ARRAY[1, a / 1]);

--Testcase 184:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <= ALL(ARRAY[1, a + 1]);
--Testcase 185:
SELECT * FROM numbers WHERE a <= ALL(ARRAY[1, a + 1]);

--Testcase 186:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a > ALL(ARRAY[1, a - 1]);
--Testcase 187:
SELECT * FROM numbers WHERE a > ALL(ARRAY[1, a - 1]);

--Testcase 188:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a < ALL(ARRAY[2, a + 1]);
--Testcase 189:
SELECT * FROM numbers WHERE a < ALL(ARRAY[2, a + 1]);

-- ALL with ARRAY const
--Testcase 190:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a = ALL(ARRAY[1, 1]);
--Testcase 191:
SELECT * FROM numbers WHERE a = ALL(ARRAY[1, 1]);

--Testcase 192:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <> ALL(ARRAY[1, 3]);
--Testcase 193:
SELECT * FROM numbers WHERE a <> ALL(ARRAY[1, 3]);

--Testcase 194:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a >= ALL(ARRAY[1, 2]);
--Testcase 195:
SELECT * FROM numbers WHERE a >= ALL(ARRAY[1, 2]);

--Testcase 196:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a <= ALL(ARRAY[1, 2]);
--Testcase 197:
SELECT * FROM numbers WHERE a <= ALL(ARRAY[1, 2]);

--Testcase 198:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a > ALL(ARRAY[0, 1]);
--Testcase 199:
SELECT * FROM numbers WHERE a > ALL(ARRAY[0, 1]);

--Testcase 200:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE a < ALL(ARRAY[2, 3]);
--Testcase 201:
SELECT * FROM numbers WHERE a < ALL(ARRAY[2, 3]);

-- ANY/ALL with TEXT ARRAY const
--Testcase 202:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE b = ANY(ARRAY['One', 'Two']);
--Testcase 203:
SELECT * FROM numbers WHERE b = ANY(ARRAY['One', 'Two']);

--Testcase 204:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE b <> ALL(ARRAY['One', 'Four']);
--Testcase 205:
SELECT * FROM numbers WHERE b <> ALL(ARRAY['One', 'Four']);

--Testcase 206:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE b > ANY(ARRAY['One', 'Two']);
--Testcase 207:
SELECT * FROM numbers WHERE b > ANY(ARRAY['One', 'Two']);

--Testcase 208:
EXPLAIN VERBOSE SELECT * FROM numbers WHERE b > ALL(ARRAY['Four', 'Five']);
--Testcase 209:
SELECT * FROM numbers WHERE b > ALL(ARRAY['Four', 'Five']);

--Testcase 80:
INSERT INTO multiprimary VALUES(1,2,3);
--Testcase 81:
INSERT INTO multiprimary VALUES(1,2,4);
--Testcase 82:
UPDATE multiprimary SET b = 10 WHERE c = 3;
--Testcase 83:
SELECT * from multiprimary;
--Testcase 84:
UPDATE multiprimary SET a = 10 WHERE a = 1;
--Testcase 85:
SELECT * from multiprimary;
--Testcase 86:
UPDATE multiprimary SET a = 100, b=200, c=300 WHERE a=10 AND b=10;
--Testcase 87:
SELECT * from multiprimary;
--Testcase 88:
UPDATE multiprimary SET a = 1234;
--Testcase 89:
SELECT * from multiprimary;
--Testcase 90:
UPDATE multiprimary SET a = a+1, b=b+1 WHERE b=200 AND c=300;

--Testcase 91:
SELECT * from multiprimary;
--Testcase 92:
DELETE from multiprimary WHERE a = 1235;
--Testcase 93:
SELECT * from multiprimary;
--Testcase 94:
DELETE from multiprimary WHERE b = 2;
--Testcase 95:
SELECT * from multiprimary;

--Testcase 96:
INSERT INTO multiprimary VALUES(1,2,3);
--Testcase 97:
INSERT INTO multiprimary VALUES(1,2,4);
--Testcase 98:
INSERT INTO multiprimary VALUES(1,10,20);
--Testcase 99:
INSERT INTO multiprimary VALUES(2,20,40);



--Testcase 100:
SELECT count(distinct a) from multiprimary;
--Testcase 101:
SELECT sum(b),max(b), min(b) from multiprimary;
--Testcase 102:
SELECT sum(b+5)+2 from multiprimary group by b/2 order by b/2;
--Testcase 103:
SELECT sum(a) from multiprimary group by b having sum(a) > 0 order by sum(a);
--Testcase 104:
SELECT sum(a) A from multiprimary group by b having avg(abs(a)) > 0 AND sum(a) > 0 order by A;
--Testcase 105:
SELECT count(nullif(a, 1)) FROM multiprimary;
--Testcase 106:
SELECT a,a FROM multiprimary group by 1,2;
--Testcase 107:
SELECT * from multiprimary, numbers WHERE multiprimary.a=numbers.a;

--Testcase 108:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT sum(a) FROM multiprimary HAVING sum(a) > 0;
--Testcase 109:
SELECT sum(a) FROM multiprimary HAVING sum(a) > 0;

--Testcase 110:
INSERT INTO numbers VALUES(4, 'Four');

-- All where clauses are pushed down
--Testcase 111:
SELECT * FROM numbers WHERE abs(a) = 4 AND upper(b) = 'FOUR' AND lower(b) = 'four';
--Testcase 112:
EXPLAIN (verbose, costs off)  SELECT b, length(b) FROM numbers WHERE abs(a) = 4 AND upper(b) = 'FOUR' AND lower(b) = 'four';

-- Only "length(b) = 4" are pushed down
--Testcase 113:
SELECT b, length(b) FROM numbers WHERE length(b) = 4 AND power(1, a) != 0 AND length(reverse(b)) = 4;
--Testcase 114:
EXPLAIN (verbose, costs off) SELECT b, length(b) FROM numbers WHERE length(b) = 4 AND power(1, a) != 0 AND length(reverse(b)) = 4;

--Testcase 115:
INSERT INTO multiprimary (b,c) VALUES (99, 100);
--Testcase 116:
SELECT c FROM multiprimary WHERE COALESCE(a,b,c) = 99;


--Testcase 139:
CREATE FOREIGN TABLE multiprimary2(a int, b int, c int OPTIONS(column_name 'b')) SERVER sqlite_svr OPTIONS (table 'multiprimary');
--Testcase 117:
SELECT * FROM multiprimary2;
--Testcase 214:
ALTER FOREIGN TABLE multiprimary2 ALTER COLUMN a OPTIONS(ADD column_name 'b');
--Testcase 118:
SELECT * FROM multiprimary2;
--Testcase 215:
ALTER FOREIGN TABLE multiprimary2 ALTER COLUMN b OPTIONS (column_name 'nosuch column');
--Testcase 119:
SELECT * FROM multiprimary2;
--Testcase 140:
EXPLAIN (VERBOSE) SELECT * FROM multiprimary2;
--Testcase 120:
SELECT a FROM multiprimary2 WHERE b = 1;


--Testcase 141:
CREATE FOREIGN TABLE columntest(a int OPTIONS(column_name 'a a', key 'true'), "b b" int  OPTIONS(key 'true'), c int OPTIONS(column_name 'c c')) SERVER sqlite_svr;
--Testcase 121:
INSERT INTO columntest VALUES(1,2,3);
--Testcase 122:
UPDATE columntest SET c=10 WHERE a = 1;
--Testcase 123:
SELECT * FROM columntest;
--Testcase 124:
UPDATE columntest SET a=100 WHERE c = 10;
--Testcase 125:
SELECT * FROM columntest;
--Testcase 126:
INSERT INTO noprimary VALUES(1,'2');
--Testcase 127:
INSERT INTO noprimary SELECT * FROM noprimary;
--Testcase 128:
SELECT * FROM noprimary;

--get version
--Testcase 153:
\df sqlite*
--Testcase 154:
SELECT * FROM public.sqlite_fdw_version();
--Testcase 155:
SELECT sqlite_fdw_version();

-- issue #44 github
--Testcase 156:
CREATE FOREIGN TABLE fts_table (name text,  description text) SERVER sqlite_svr;

--Testcase 157:
INSERT INTO fts_table VALUES ('this is name', 'this is description');

--Testcase 158:
SELECT * FROM fts_table; -- should work

--Testcase 159:
ALTER TABLE fts_table ALTER COLUMN name TYPE int;

--Testcase 160:
SELECT * FROM fts_table; -- should fail

-- issue #62 github
--Testcase 236:
INSERT INTO noprimary VALUES (4, 'Test''s');
--Testcase 237:
INSERT INTO noprimary VALUES (5, 'Test');

--Testcase 238:
SELECT * FROM noprimary;
--Testcase 239:
EXPLAIN VERBOSE
SELECT * FROM noprimary where b = 'Test''s';
--Testcase 240:
SELECT * FROM noprimary where b = 'Test''s';

--Testcase 241:
EXPLAIN VERBOSE
SELECT * FROM noprimary where b in ('Test''s', 'Test');
--Testcase 242:
SELECT * FROM noprimary where b in ('Test''s', 'Test');

-- INSERT/UPDATE whole row with generated column
--Testcase 216:
CREATE FOREIGN TABLE grem1_1 (
  a int generated always as (0) stored)
  SERVER sqlite_svr OPTIONS(table 'grem1_1');

--Testcase 217:
INSERT INTO grem1_1 DEFAULT VALUES;
--Testcase 218:
SELECT * FROM grem1_1;

--Testcase 219:
CREATE FOREIGN TABLE grem1_2 (
  a int generated always as (0) stored,
  b int generated always as (1) stored,
  c int generated always as (2) stored,
  d int generated always as (3) stored)
  SERVER sqlite_svr OPTIONS(table 'grem1_2');
--Testcase 220:
INSERT INTO grem1_2 DEFAULT VALUES;
--Testcase 221:
SELECT * FROM grem1_2;

-- Executable test case for pushdown CASE expressions (results)
--Testcase 224:
CREATE FOREIGN TABLE case_exp(c1 int OPTIONS (key 'true'), c3 text, c6 varchar(10)) SERVER sqlite_svr;

--Testcase 225:
INSERT INTO case_exp
  SELECT id,
         to_char(id, 'FM00000'),
         id % 10
  FROM generate_series(1, 10) id;

--Testcase 226:
SELECT * FROM case_exp;

-- CASE arg WHEN
--Testcase 227:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM case_exp WHERE c1 > (CASE mod(c1, 4) WHEN 0 THEN 1 WHEN 2 THEN 50 ELSE 100 END);
--Testcase 228:
SELECT * FROM case_exp WHERE c1 > (CASE mod(c1, 4) WHEN 0 THEN 1 WHEN 2 THEN 50 ELSE 100 END);

-- these are shippable
--Testcase 229:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM case_exp WHERE CASE c6 WHEN 'foo' THEN true ELSE c3 < 'bar' END;
--Testcase 230:
SELECT * FROM case_exp WHERE CASE c6 WHEN 'foo' THEN true ELSE c3 < 'bar' END;
--Testcase 231:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM case_exp WHERE CASE c3 WHEN c6 THEN true ELSE c3 < 'bar' END;
--Testcase 232:
SELECT * FROM case_exp WHERE CASE c3 WHEN c6 THEN true ELSE c3 < 'bar' END;

-- but this is not because of collation
--Testcase 233:
SELECT * FROM case_exp WHERE CASE c3 COLLATE "C" WHEN c6 THEN true ELSE c3 < 'bar' END;

--Testcase 234:
DELETE FROM case_exp;

-- updatable option test (github pull 59)
-- Full combinations
-- D-default, T-true, F-false
-- sD+tD - sT+tD - sF+tD - sD+tT - sD+tF - sT+tT - sF+tT - sF+tF - sT+tF
-- SERVER default TABLE default
-- SERVER true    TABLE default
-- SERVER false   TABLE default
-- SERVER default TABLE true
-- SERVER default TABLE false
-- SERVER true    TABLE true
-- SERVER false   TABLE true
-- SERVER false   TABLE false
-- SERVER true    TABLE false
-- SERVER default TABLE default
--Testcase 235:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (2, 'B', 3.01, 1); -- OK
--Testcase 236:
UPDATE RO_RW_test SET a='C' WHERE i=2; -- OK
--Testcase 237:
DELETE FROM RO_RW_test WHERE i=2; -- OK

-- SERVER true TABLE default
--Testcase 238:
ALTER SERVER sqlite_svr OPTIONS (ADD updatable 'true');
--Testcase 239:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (3, 'D', 5.02, 8); -- OK
--Testcase 240:
UPDATE RO_RW_test SET a='E' WHERE i=3; -- OK
--Testcase 241:
DELETE FROM RO_RW_test WHERE i=3; -- OK
--Testcase 242:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (4, 'F', 0.005, 5); -- OK
-- SERVER false TABLE default
--Testcase 243:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'false');
--Testcase 244:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (5, 'H', 0.03, 7); -- ERR
--Testcase 245:
UPDATE RO_RW_test SET a='E' WHERE i=4; -- ERR
--Testcase 246:
DELETE FROM RO_RW_test WHERE i=4; -- ERR

-- SERVER default TABLE true
--Testcase 247:
ALTER SERVER sqlite_svr OPTIONS (DROP updatable);
--Testcase 248:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (ADD updatable 'true');
--Testcase 249:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (6, 'I', 1.403, 2); -- OK
--Testcase 250:
UPDATE RO_RW_test SET a='J' WHERE i=6; -- OK
--Testcase 251:
DELETE FROM RO_RW_test WHERE i=6; -- OK

-- SERVER default TABLE false
--Testcase 252:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'false');
--Testcase 253:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (7, 'K', 2.01, 4); -- ERR
--Testcase 254:
UPDATE RO_RW_test SET a='L' WHERE i=4; -- ERR
--Testcase 255:
DELETE FROM RO_RW_test WHERE i=4; -- ERR

-- SERVER true TABLE true
--Testcase 256:
ALTER SERVER sqlite_svr OPTIONS (ADD updatable 'true');
--Testcase 257:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'true');
--Testcase 258:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (8, 'M', 5.02, 8); -- OK
--Testcase 258:
UPDATE RO_RW_test SET a='N' WHERE i=8; -- OK
--Testcase 260:
DELETE FROM RO_RW_test WHERE i=8; -- OK
--Testcase 261:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (9, 'O', 3.21, 9); -- OK

-- SERVER false TABLE true
--Testcase 262:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'false');
--Testcase 263:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (10, 'P', 4.15, 1); -- OK
--Testcase 264:
UPDATE RO_RW_test SET a='Q' WHERE i=9; -- OK
--Testcase 265:
DELETE FROM RO_RW_test WHERE i=9; -- OK

-- SERVER false TABLE false
--Testcase 266:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'false');
--Testcase 267:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (11, 'Q', 2.27, 5); -- ERR
--Testcase 268:
UPDATE RO_RW_test SET a='S' WHERE i=9; -- ERR
--Testcase 269:
DELETE FROM RO_RW_test WHERE i=9; -- ERR

-- SERVER true TABLE false
--Testcase 270:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'true');
--Testcase 271:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (12, 'R', 6.18, 11); -- ERR
--Testcase 272:
UPDATE RO_RW_test SET a='T' WHERE i=9; -- ERR
--Testcase 273:
DELETE FROM RO_RW_test WHERE i=9; -- ERR

--Testcase 274:
ALTER SERVER sqlite_svr OPTIONS (DROP updatable);
--Testcase 275:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (DROP updatable);

--Testcase 276:
SELECT * FROM RO_RW_test ORDER BY i;

-- test for PR #76 github
CREATE FOREIGN TABLE "Unicode data" (i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
SELECT * FROM "Unicode data";

-- updatable option test (github pull 59)
DROP FOREIGN TABLE RO_RW_test;

--Testcase 142:
DROP FUNCTION test_param_WHERE();
--Testcase 143:
DROP FOREIGN TABLE numbers;
--Testcase 144:
DROP FOREIGN TABLE department;
--Testcase 145:
DROP FOREIGN TABLE employee;
--Testcase 146:
DROP FOREIGN TABLE empdata;
--Testcase 147:
DROP FOREIGN TABLE multiprimary;
--Testcase 148:
DROP FOREIGN TABLE multiprimary2;
--Testcase 149:
DROP FOREIGN TABLE columntest;
--Testcase 150:
DROP FOREIGN TABLE noprimary;
--Testcase 161:
DROP FOREIGN TABLE fts_table;
--Testcase 222:
DROP FOREIGN TABLE grem1_1;
--Testcase 223:
DROP FOREIGN TABLE grem1_2;
--Testcase 235:
DROP FOREIGN TABLE case_exp;
--test for PR #76 github
DROP FOREIGN TABLE "Unicode data";

--Testcase 151:
DROP SERVER sqlite_svr;
--Testcase 152:
DROP EXTENSION sqlite_fdw CASCADE;

-- tests for PR #76 github
-- see https://www.postgresql.org/docs/current/multibyte.html
-- EUC_CN, not tested
-- EUC_JP
-- EUC_JIS_2004, not tested
-- EUC_KR
-- EUC_TW, not tested
-- ISO_8859_5
-- ISO_8859_6
-- ISO_8859_7
-- ISO_8859_8
-- KOI8R, not tested
-- KOI8U, not tested
-- LATIN1
-- LATIN2
-- LATIN3
-- LATIN4
-- LATIN5
-- LATIN6
-- LATIN7
-- LATIN8
-- LATIN9
-- LATIN10
-- MULE_INTERNAL, not tested
-- SQL_ASCII
-- WIN866, not tested
-- WIN874, not tested
-- WIN1250
-- WIN1251
-- WIN1252
-- WIN1253
-- WIN1254
-- WIN1255
-- WIN1256
-- WIN1257
-- WIN1258, not tested

-- euc_jp
CREATE DATABASE "contrib_regression_EUC_JP" ENCODING EUC_JP LC_CTYPE='ja_JP.eucjp' LC_COLLATE='ja_JP.eucjp' template template0;
\connect "contrib_regression_EUC_JP"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_EUC_JP";

-- ko_KR.euckr
CREATE DATABASE "contrib_regression_EUC_KR" ENCODING EUC_KR LC_CTYPE='ko_KR.euckr' LC_COLLATE='ko_KR.euckr' template template0;
\connect "contrib_regression_EUC_KR"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_EUC_KR";

-- ISO_8859_5
CREATE DATABASE "contrib_regression_ISO_8859_5" ENCODING ISO_8859_5 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_5"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_5";

-- ISO_8859_6
CREATE DATABASE "contrib_regression_ISO_8859_6" ENCODING ISO_8859_6 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_6"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_6";

-- ISO_8859_7
CREATE DATABASE "contrib_regression_ISO_8859_7" ENCODING ISO_8859_7 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_7"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_7";

-- ISO_8859_8
CREATE DATABASE "contrib_regression_ISO_8859_8" ENCODING ISO_8859_8 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_8"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_8";

-- ISO_8859_9
CREATE DATABASE "contrib_regression_ISO_8859_9" ENCODING ISO_8859_9 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_9"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_9";

-- LATIN1
CREATE DATABASE "contrib_regression_LATIN1" ENCODING LATIN1 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN1"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN1";

-- LATIN2
CREATE DATABASE "contrib_regression_LATIN2" ENCODING LATIN2 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN2"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN2";

-- LATIN3
CREATE DATABASE "contrib_regression_LATIN3" ENCODING LATIN3 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN3"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN3";

-- LATIN4
CREATE DATABASE "contrib_regression_LATIN4" ENCODING LATIN4 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN4"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN4";

-- LATIN5
CREATE DATABASE "contrib_regression_LATIN5" ENCODING LATIN5 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN5"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN5";

-- LATIN6
CREATE DATABASE "contrib_regression_LATIN6" ENCODING LATIN6 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN6"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN6";

-- LATIN7
CREATE DATABASE "contrib_regression_LATIN7" ENCODING LATIN7 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN7"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN7";

-- LATIN8
CREATE DATABASE "contrib_regression_LATIN8" ENCODING LATIN8 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN8"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN8";

-- LATIN9
CREATE DATABASE "contrib_regression_LATIN9" ENCODING LATIN9 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN9"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN9";

-- LATIN10
CREATE DATABASE "contrib_regression_LATIN10" ENCODING LATIN10 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN10"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN10";

-- cp1250
CREATE DATABASE "contrib_regression_WIN1250" ENCODING WIN1250 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1250"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1250";

-- cp1251
CREATE DATABASE "contrib_regression_WIN1251" ENCODING WIN1251 LC_CTYPE='bg_BG' LC_COLLATE='bg_BG' template template0;
\connect "contrib_regression_WIN1251"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1251";

-- cp1252
CREATE DATABASE "contrib_regression_WIN1252" ENCODING WIN1252 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1252"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1252";

-- cp1253
CREATE DATABASE "contrib_regression_WIN1253" ENCODING WIN1253 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1253"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1253";

-- cp1254
CREATE DATABASE "contrib_regression_WIN1254" ENCODING WIN1254 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1254"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1254";

-- cp1255
CREATE DATABASE "contrib_regression_WIN1255" ENCODING WIN1255 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1255"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1255";

-- cp1256
CREATE DATABASE "contrib_regression_WIN1256" ENCODING WIN1256 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1256"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1256";

-- cp1257
CREATE DATABASE "contrib_regression_WIN1257" ENCODING WIN1257 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1257"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1257";

-- SQL_ASCII
CREATE DATABASE "contrib_regression_SQL_ASCII" ENCODING SQL_ASCII LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_SQL_ASCII"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_SQL_ASCII";
