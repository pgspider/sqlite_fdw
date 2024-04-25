--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 129:
CREATE EXTENSION sqlite_fdw;
--Testcase 130:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
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

-- Aggregates in subquery are pushed down.
--Testcase 214:
explain (verbose, costs off)
select count(x.a), sum(x.a) from (select a a, sum(a) b from numbers group by a, abs(a) order by 1, 2) x;
--Testcase 215:
select count(x.a), sum(x.a) from (select a a, sum(a) b from numbers group by a, abs(a) order by 1, 2) x;

--Testcase 115:
INSERT INTO multiprimary (b,c) VALUES (99, 100);
--Testcase 116:
SELECT c FROM multiprimary WHERE COALESCE(a,b,c) = 99;

--Testcase 139:
CREATE FOREIGN TABLE multiprimary2(a int, b int, c int OPTIONS(column_name 'b')) SERVER sqlite_svr OPTIONS (table 'multiprimary');
--Testcase 117:
SELECT * FROM multiprimary2;
ALTER FOREIGN TABLE multiprimary2 ALTER COLUMN a OPTIONS(ADD column_name 'b');
--Testcase 118:
SELECT * FROM multiprimary2;
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

-- readonly/readwrite tests
-- Full combinations
-- force_RO default SERVER default TABLE default
-- force_RO default SERVER true    TABLE default
-- force_RO default SERVER false   TABLE default
-- force_RO default SERVER default TABLE true
-- force_RO default SERVER default TABLE false
-- force_RO default SERVER true    TABLE true
-- force_RO default SERVER false   TABLE true
-- force_RO default SERVER false   TABLE false
-- force_RO default SERVER true    TABLE false
-- force_RO false   SERVER default TABLE default
-- force_RO false   SERVER true    TABLE default
-- force_RO false   SERVER false   TABLE default
-- force_RO false   SERVER default TABLE true
-- force_RO false   SERVER default TABLE false
-- force_RO false   SERVER true    TABLE true
-- force_RO false   SERVER false   TABLE true
-- force_RO false   SERVER false   TABLE false
-- force_RO false   SERVER true    TABLE false
-- force_RO true    SERVER default TABLE default
-- force_RO true    SERVER true    TABLE default
-- force_RO true    SERVER false   TABLE default
-- force_RO true    SERVER default TABLE true
-- force_RO true    SERVER default TABLE false
-- force_RO true    SERVER true    TABLE true
-- force_RO true    SERVER false   TABLE true
-- force_RO true    SERVER false   TABLE false
-- force_RO true    SERVER true    TABLE false

-- force_RO default SERVER default TABLE default
--Testcase 235:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (2, 'B', 3.01, 1); -- OK
--Testcase 236:
UPDATE RO_RW_test SET a='C' WHERE i=2; -- OK
--Testcase 237:
DELETE FROM RO_RW_test WHERE i=2; -- OK

-- force_RO default SERVER true TABLE default
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

-- force_RO default SERVER false TABLE default
--Testcase 243:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'false');
--Testcase 244:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (5, 'H', 0.03, 7); -- ERR
--Testcase 245:
UPDATE RO_RW_test SET a='E' WHERE i=4; -- ERR
--Testcase 246:
DELETE FROM RO_RW_test WHERE i=4; -- ERR

-- force_RO default SERVER default TABLE true
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

-- force_RO default SERVER default TABLE false
--Testcase 252:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'false');
--Testcase 253:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (7, 'K', 2.01, 4); -- ERR
--Testcase 254:
UPDATE RO_RW_test SET a='L' WHERE i=4; -- ERR
--Testcase 255:
DELETE FROM RO_RW_test WHERE i=4; -- ERR

-- force_RO default SERVER true TABLE true
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

-- force_RO default SERVER false TABLE true
--Testcase 262:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'false');
--Testcase 263:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (10, 'P', 4.15, 1); -- OK
--Testcase 264:
UPDATE RO_RW_test SET a='Q' WHERE i=9; -- OK
--Testcase 265:
DELETE FROM RO_RW_test WHERE i=9; -- OK

-- force_RO default SERVER false TABLE false
--Testcase 266:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'false');
--Testcase 267:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (11, 'Q', 2.27, 5); -- ERR
--Testcase 268:
UPDATE RO_RW_test SET a='S' WHERE i=9; -- ERR
--Testcase 269:
DELETE FROM RO_RW_test WHERE i=9; -- ERR

-- force_RO default SERVER true TABLE false
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

--Bind error message test for some unsupported data type
--Testcase 277:
ALTER FOREIGN TABLE numbers ALTER COLUMN b TYPE tsquery;
--Testcase 278:
INSERT INTO numbers VALUES(8,'fat & (rat | cat)');
--Testcase 279:
ALTER FOREIGN TABLE numbers ALTER COLUMN b TYPE varchar(255);

--Testcase 277:
DELETE FROM RO_RW_test;

--Testcase 278:
ALTER SERVER sqlite_svr OPTIONS (ADD force_readonly 'false');

-- force_RO false SERVER default TABLE default
--Testcase 279:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (2, 'B', 3.01, 1); -- OK
--Testcase 280:
UPDATE RO_RW_test SET a='C' WHERE i=2; -- OK
--Testcase 281:
DELETE FROM RO_RW_test WHERE i=2; -- OK

-- force_RO false SERVER true TABLE default
--Testcase 282:
ALTER SERVER sqlite_svr OPTIONS (ADD updatable 'true');
--Testcase 283:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (3, 'D', 5.02, 8); -- OK
--Testcase 284:
UPDATE RO_RW_test SET a='E' WHERE i=3; -- OK
--Testcase 285:
DELETE FROM RO_RW_test WHERE i=3; -- OK
--Testcase 286:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (4, 'F', 0.005, 5); -- OK
-- force_RO false SERVER false TABLE default
--Testcase 287:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'false');
--Testcase 288:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (5, 'H', 0.03, 7); -- ERR
--Testcase 289:
UPDATE RO_RW_test SET a='E' WHERE i=4; -- ERR
--Testcase 290:
DELETE FROM RO_RW_test WHERE i=4; -- ERR

-- force_RO false SERVER default TABLE true
--Testcase 291:
ALTER SERVER sqlite_svr OPTIONS (DROP updatable);
--Testcase 292:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (ADD updatable 'true');
--Testcase 293:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (6, 'I', 1.403, 2); -- OK
--Testcase 294:
UPDATE RO_RW_test SET a='J' WHERE i=6; -- OK
--Testcase 295:
DELETE FROM RO_RW_test WHERE i=6; -- OK

-- force_RO false SERVER default TABLE false
--Testcase 296:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'false');
--Testcase 297:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (7, 'K', 2.01, 4); -- ERR
--Testcase 298:
UPDATE RO_RW_test SET a='L' WHERE i=4; -- ERR
--Testcase 299:
DELETE FROM RO_RW_test WHERE i=4; -- ERR

-- force_RO false SERVER true TABLE true
--Testcase 300:
ALTER SERVER sqlite_svr OPTIONS (ADD updatable 'true');
--Testcase 301:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'true');
--Testcase 302:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (8, 'M', 5.02, 8); -- OK
--Testcase 303:
UPDATE RO_RW_test SET a='N' WHERE i=8; -- OK
--Testcase 304:
DELETE FROM RO_RW_test WHERE i=8; -- OK
--Testcase 305:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (9, 'O', 3.21, 9); -- OK

-- force_RO false SERVER false TABLE true
--Testcase 306:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'false');
--Testcase 307:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (10, 'P', 4.15, 1); -- OK
--Testcase 308:
UPDATE RO_RW_test SET a='Q' WHERE i=9; -- OK
--Testcase 309:
DELETE FROM RO_RW_test WHERE i=9; -- OK

-- force_RO false SERVER false TABLE false
--Testcase 310:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'false');
--Testcase 311:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (11, 'Q', 2.27, 5); -- ERR
--Testcase 312:
UPDATE RO_RW_test SET a='S' WHERE i=9; -- ERR
--Testcase 313:
DELETE FROM RO_RW_test WHERE i=9; -- ERR

-- force_RO false SERVER true TABLE false
--Testcase 314:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'true');
--Testcase 315:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (12, 'R', 6.18, 11); -- ERR
--Testcase 316:
UPDATE RO_RW_test SET a='T' WHERE i=9; -- ERR
--Testcase 317:
DELETE FROM RO_RW_test WHERE i=9; -- ERR

--Testcase 318:
ALTER SERVER sqlite_svr OPTIONS (DROP updatable);
--Testcase 319:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (DROP updatable);

--Testcase 320:
SELECT * FROM RO_RW_test ORDER BY i;
--Testcase 321:
DELETE FROM RO_RW_test;

--Testcase 322:
ALTER SERVER sqlite_svr OPTIONS (SET force_readonly 'true');

-- force_RO true SERVER default TABLE default
--Testcase 323:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (2, 'B', 3.01, 1); -- ERR
--Testcase 324:
UPDATE RO_RW_test SET a='C' WHERE i=2; -- ERR
--Testcase 325:
DELETE FROM RO_RW_test WHERE i=2; -- ERR

-- force_RO true SERVER true TABLE default
--Testcase 326:
ALTER SERVER sqlite_svr OPTIONS (ADD updatable 'true');
--Testcase 327:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (3, 'D', 5.02, 8); -- ERR
--Testcase 328:
UPDATE RO_RW_test SET a='E' WHERE i=3; -- ERR
--Testcase 329:
DELETE FROM RO_RW_test WHERE i=3; -- ERR
--Testcase 330:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (4, 'F', 0.005, 5); -- ERR
-- force_RO true SERVER false TABLE default
--Testcase 331:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'false');
--Testcase 332:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (5, 'H', 0.03, 7); -- ERR
--Testcase 333:
UPDATE RO_RW_test SET a='E' WHERE i=4; -- ERR
--Testcase 334:
DELETE FROM RO_RW_test WHERE i=4; -- ERR

-- force_RO true SERVER default TABLE true
--Testcase 335:
ALTER SERVER sqlite_svr OPTIONS (DROP updatable);
--Testcase 336:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (ADD updatable 'true');
--Testcase 337:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (6, 'I', 1.403, 2); -- ERR
--Testcase 338:
UPDATE RO_RW_test SET a='J' WHERE i=6; -- ERR
--Testcase 339:
DELETE FROM RO_RW_test WHERE i=6; -- ERR

-- force_RO true SERVER default TABLE false
--Testcase 340:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'false');
--Testcase 341:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (7, 'K', 2.01, 4); -- ERR
--Testcase 342:
UPDATE RO_RW_test SET a='L' WHERE i=4; -- ERR
--Testcase 343:
DELETE FROM RO_RW_test WHERE i=4; -- ERR

-- force_RO true SERVER true TABLE true
--Testcase 344:
ALTER SERVER sqlite_svr OPTIONS (ADD updatable 'true'); -- ERR
--Testcase 345:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'true'); -- ERR
--Testcase 346:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (8, 'M', 5.02, 8); -- ERR
--Testcase 347:
UPDATE RO_RW_test SET a='N' WHERE i=8; -- OK
--Testcase 348:
DELETE FROM RO_RW_test WHERE i=8; -- OK
--Testcase 349:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (9, 'O', 3.21, 9); -- ERR

-- force_RO true SERVER false TABLE true
--Testcase 350:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'false');
--Testcase 351:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (10, 'P', 4.15, 1); -- ERR
--Testcase 352:
UPDATE RO_RW_test SET a='Q' WHERE i=9; -- ERR
--Testcase 353:
DELETE FROM RO_RW_test WHERE i=9; -- ERR

-- force_RO true SERVER false TABLE false
--Testcase 354:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (SET updatable 'false');
--Testcase 355:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (11, 'Q', 2.27, 5); -- ERR
--Testcase 356:
UPDATE RO_RW_test SET a='S' WHERE i=9; -- ERR
--Testcase 357:
DELETE FROM RO_RW_test WHERE i=9; -- ERR

-- force_RO true SERVER true TABLE false
--Testcase 358:
ALTER SERVER sqlite_svr OPTIONS (SET updatable 'true');
--Testcase 359:
INSERT INTO RO_RW_test (i, a, b, c) VALUES (12, 'R', 6.18, 11); -- ERR
--Testcase 360:
UPDATE RO_RW_test SET a='T' WHERE i=9; -- ERR
--Testcase 361:
DELETE FROM RO_RW_test WHERE i=9; -- ERR

--Testcase 362:
ALTER SERVER sqlite_svr OPTIONS (DROP updatable);
--Testcase 363:
ALTER FOREIGN TABLE RO_RW_test OPTIONS (DROP updatable);

--Testcase 364:
ALTER SERVER sqlite_svr OPTIONS (DROP force_readonly);

--Testcase 365:
SELECT * FROM RO_RW_test ORDER BY i;
--Testcase 366:
DROP FOREIGN TABLE RO_RW_test;
-- End of RO/RW test

--Bind error message test for some unsupported data type
--Testcase 366:
ALTER FOREIGN TABLE numbers ALTER COLUMN b TYPE tsquery;
--Testcase 367:
INSERT INTO numbers VALUES(8,'fat & (rat | cat)');
--Testcase 368:
ALTER FOREIGN TABLE numbers ALTER COLUMN b TYPE varchar(255);

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
--Testcase 235:
DROP FOREIGN TABLE case_exp;

--Testcase 151:
DROP SERVER sqlite_svr;
--Testcase 152:
DROP EXTENSION sqlite_fdw CASCADE;
