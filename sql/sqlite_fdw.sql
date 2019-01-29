--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE department(department_id int OPTIONS (key 'true'), department_name text) SERVER sqlite_svr; 
CREATE FOREIGN TABLE employee(emp_id int OPTIONS (key 'true'), emp_name text, emp_dept_id int) SERVER sqlite_svr;
CREATE FOREIGN TABLE empdata(emp_id int OPTIONS (key 'true'), emp_dat bytea) SERVER sqlite_svr;
CREATE FOREIGN TABLE numbers(a int OPTIONS (key 'true'), b varchar(255)) SERVER sqlite_svr;
CREATE FOREIGN TABLE multiprimary(a int, b int OPTIONS (key 'true'), c int OPTIONS(key 'true')) SERVER sqlite_svr;
CREATE FOREIGN TABLE noprimary(a int, b int) SERVER sqlite_svr;

SELECT * FROM department LIMIT 10;
SELECT * FROM employee LIMIT 10;
SELECT * FROM empdata LIMIT 10;

INSERT INTO department VALUES(generate_series(1,100), 'dept - ' || generate_series(1,100));
INSERT INTO employee VALUES(generate_series(1,100), 'emp - ' || generate_series(1,100), generate_series(1,100));
INSERT INTO empdata  VALUES(1, decode ('01234567', 'hex'));

INSERT INTO numbers VALUES(1, 'One');
INSERT INTO numbers VALUES(2, 'Two');
INSERT INTO numbers VALUES(3, 'Three');
INSERT INTO numbers VALUES(4, 'Four');
INSERT INTO numbers VALUES(5, 'Five');
INSERT INTO numbers VALUES(6, 'Six');
INSERT INTO numbers VALUES(7, 'Seven');
INSERT INTO numbers VALUES(8, 'Eight');
INSERT INTO numbers VALUES(9, 'Nine');

SELECT count(*) FROM department;
SELECT count(*) FROM employee;
SELECT count(*) FROM empdata;

EXPLAIN (COSTS FALSE) SELECT * FROM department d, employee e WHERE d.department_id = e.emp_dept_id LIMIT 10;

EXPLAIN (COSTS FALSE) SELECT * FROM department d, employee e WHERE d.department_id IN (SELECT department_id FROM department) LIMIT 10;

SELECT * FROM department d, employee e WHERE d.department_id = e.emp_dept_id LIMIT 10;
SELECT * FROM department d, employee e WHERE d.department_id IN (SELECT department_id FROM department) LIMIT 10;
SELECT * FROM empdata;

DELETE FROM employee WHERE emp_id = 10;

SELECT COUNT(*) FROM department LIMIT 10;
SELECT COUNT(*) FROM employee WHERE emp_id = 10;

UPDATE employee SET emp_name = 'UPDATEd emp' WHERE emp_id = 20;
SELECT emp_id, emp_name FROM employee WHERE emp_name like 'UPDATEd emp';

UPDATE empdata SET emp_dat = decode ('0123', 'hex');
SELECT * FROM empdata;

SELECT * FROM employee LIMIT 10;
SELECT * FROM employee WHERE emp_id IN (1);
SELECT * FROM employee WHERE emp_id IN (1,3,4,5);
SELECT * FROM employee WHERE emp_id IN (10000,1000);

SELECT * FROM employee WHERE emp_id NOT IN (1) LIMIT 5;
SELECT * FROM employee WHERE emp_id NOT IN (1,3,4,5) LIMIT 5;
SELECT * FROM employee WHERE emp_id NOT IN (10000,1000) LIMIT 5;

SELECT * FROM employee WHERE emp_id NOT IN (SELECT emp_id FROM employee WHERE emp_id IN (1,10));
SELECT * FROM employee WHERE emp_name NOT IN ('emp - 1', 'emp - 2') LIMIT 5;
SELECT * FROM employee WHERE emp_name NOT IN ('emp - 10') LIMIT 5;

SELECT * FROM numbers WHERE (CASE WHEN a % 2 = 0 THEN 1 WHEN a % 5 = 0 THEN 1 ELSE 0 END) = 1;
SELECT * FROM numbers WHERE (CASE b WHEN 'Two' THEN 1 WHEN 'Six' THEN 1 ELSE 0 END) = 1;

create or replace function test_param_WHERE() returns void as $$
DECLARE
  n varchar;
BEGIN
  FOR x IN 1..9 LOOP
    SELECT b INTO n from numbers WHERE a=x;
    raise notice 'Found number %', n;
  end loop;
  return;
END
$$ LANGUAGE plpgsql;
SELECT test_param_WHERE();

SELECT b from numbers WHERE a=1;
EXPLAIN(COSTS OFF) SELECT b from numbers WHERE a=1;

SELECT a FROM numbers WHERE b = (SELECT NULL::text);


PREPARE stmt1 (int, int) AS
  SELECT * FROM numbers WHERE a=$1 or a=$2;
EXECUTE stmt1(1,2);
EXECUTE stmt1(2,2); 
EXECUTE stmt1(3,2); 
EXECUTE stmt1(4,2);
-- generic plan
EXECUTE stmt1(5,2); 
EXECUTE stmt1(6,2); 
EXECUTE stmt1(7,2); 

DELETE FROM employee;
DELETE FROM department;
DELETE FROM empdata;
DELETE FROM numbers;

BEGIN;
INSERT INTO numbers VALUES(1, 'One');
INSERT INTO numbers VALUES(2, 'Two');
COMMIT;

SELECT * from numbers;

BEGIN;
INSERT INTO numbers VALUES(3, 'Three');
ROLLBACK;
SELECT * from numbers;

BEGIN;
INSERT INTO numbers VALUES(4, 'Four');
SAVEPOINT my_savepoint;
INSERT INTO numbers VALUES(5, 'Five');
ROLLBACK TO SAVEPOINT my_savepoint;
INSERT INTO numbers VALUES(6, 'Six');
COMMIT;

SELECT * from numbers;

-- duplicate key
INSERT INTO numbers VALUES(1, 'One');
DELETE from numbers;

BEGIN;
INSERT INTO numbers VALUES(1, 'One');
INSERT INTO numbers VALUES(2, 'Two');
COMMIT;
-- violate unique constraint
UPDATE numbers SET b='Two' WHERE a = 1; 
SELECT * from numbers;

-- push down
explain (costs off) SELECT * from numbers WHERE  a = any(ARRAY[2,3,4,5]::int[]);
-- (1,2,3) is pushed down
explain (costs off) SELECT * from numbers WHERE a in (1,2,3) AND (1,2) < (a,5);

-- not push down
explain (costs off) SELECT * from numbers WHERE a in (a+2*a,5);
-- not push down
explain (costs off) SELECT * from numbers WHERE  a = any(ARRAY[1,2,a]::int[]);

SELECT * from numbers WHERE  a = any(ARRAY[2,3,4,5]::int[]);
SELECT * from numbers WHERE  a = any(ARRAY[1,2,a]::int[]);

INSERT INTO multiprimary VALUES(1,2,3);
INSERT INTO multiprimary VALUES(1,2,4);
UPDATE multiprimary SET b = 10 WHERE c = 3;
SELECT * from multiprimary;
UPDATE multiprimary SET a = 10 WHERE a = 1;
SELECT * from multiprimary;
UPDATE multiprimary SET a = 100, b=200, c=300 WHERE a=10 AND b=10;
SELECT * from multiprimary;
UPDATE multiprimary SET a = 1234;
SELECT * from multiprimary;
UPDATE multiprimary SET a = a+1, b=b+1 WHERE b=200 AND c=300;

SELECT * from multiprimary;
DELETE from multiprimary WHERE a = 1235;
SELECT * from multiprimary;
DELETE from multiprimary WHERE b = 2;
SELECT * from multiprimary;

INSERT INTO multiprimary VALUES(1,2,3);
INSERT INTO multiprimary VALUES(1,2,4);
INSERT INTO multiprimary VALUES(1,10,20);
INSERT INTO multiprimary VALUES(2,20,40);



SELECT count(distinct a) from multiprimary;
SELECT sum(b),max(b), min(b) from multiprimary;
SELECT sum(b+5)+2 from multiprimary group by b/2 order by b/2;
SELECT sum(a) from multiprimary group by b having sum(a) > 0 order by sum(a);
SELECT sum(a) A from multiprimary group by b having avg(abs(a)) > 0 AND sum(a) > 0 order by A;
SELECT count(nullif(a, 1)) FROM multiprimary;
SELECT a,a FROM multiprimary group by 1,2;

SELECT * from multiprimary, numbers WHERE multiprimary.a=numbers.a;

INSERT INTO numbers VALUES(4, 'Four');

-- All where clauses are pushed down
SELECT * FROM numbers WHERE abs(a) = 4 AND upper(b) = 'FOUR' AND lower(b) = 'four';
EXPLAIN (verbose, costs off)  SELECT b, length(b) FROM numbers WHERE abs(a) = 4 AND upper(b) = 'FOUR' AND lower(b) = 'four';

-- Only "length(b) = 4" are pushed down
SELECT b, length(b) FROM numbers WHERE length(b) = 4 AND power(1, a) != 0 AND length(reverse(b)) = 4;
EXPLAIN (verbose, costs off) SELECT b, length(b) FROM numbers WHERE length(b) = 4 AND power(1, a) != 0 AND length(reverse(b)) = 4;

INSERT INTO multiprimary (b,c) VALUES (99, 100);
SELECT c FROM multiprimary WHERE COALESCE(a,b,c) = 99;


CREATE FOREIGN TABLE multiprimary2(a int, b int, c int OPTIONS(column_name 'b')) SERVER sqlite_svr OPTIONS (table 'multiprimary');
SELECT * FROM multiprimary2;
ALTER FOREIGN TABLE multiprimary2 ALTER COLUMN a OPTIONS(ADD column_name 'b');
SELECT * FROM multiprimary2;


CREATE FOREIGN TABLE columntest(a int OPTIONS(column_name 'a a', key 'true'), "b b" int  OPTIONS(key 'true'), c int OPTIONS(column_name 'c c')) SERVER sqlite_svr;
INSERT INTO columntest VALUES(1,2,3);
UPDATE columntest SET c=10 WHERE a = 1;
SELECT * FROM columntest;
UPDATE columntest SET a=100 WHERE c = 10;
SELECT * FROM columntest;
INSERT INTO noprimary VALUES(1,2);
INSERT INTO noprimary SELECT * FROM noprimary;
SELECT * FROM noprimary;

DROP FUNCTION test_param_WHERE();
DROP FOREIGN TABLE numbers;
DROP FOREIGN TABLE department;
DROP FOREIGN TABLE employee;
DROP FOREIGN TABLE empdata;
DROP FOREIGN TABLE multiprimary;
DROP FOREIGN TABLE multiprimary2;
DROP FOREIGN TABLE columntest;
DROP FOREIGN TABLE noprimary;

DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw CASCADE;

