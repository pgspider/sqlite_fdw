-- ===================================================================
-- create FDW objects
-- ===================================================================

--Testcase 483:
CREATE EXTENSION sqlite_fdw;

DO $d$
    BEGIN
        EXECUTE $$CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
            OPTIONS (database '/tmp/sqlitefdw_test_post.db')$$;
        EXECUTE $$CREATE SERVER sqlite_svr2 FOREIGN DATA WRAPPER sqlite_fdw
            OPTIONS (database '/tmp/sqlitefdw_test_post.db')$$;
        EXECUTE $$CREATE SERVER sqlite_svr3 FOREIGN DATA WRAPPER sqlite_fdw
            OPTIONS (database '/tmp/sqlitefdw_test_post.db')$$;
    END;
$d$;

--Testcase 484:
CREATE USER MAPPING FOR CURRENT_USER SERVER sqlite_svr;
--Testcase 485:
CREATE USER MAPPING FOR CURRENT_USER SERVER sqlite_svr2;
--Testcase 756:
CREATE USER MAPPING FOR public SERVER sqlite_svr3;
-- ===================================================================
-- create objects used through FDW sqlite server
-- ===================================================================
--Testcase 486:
CREATE SCHEMA "S 1";
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_svr INTO "S 1";

--Testcase 1:
INSERT INTO "S 1"."T 1"
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       '1970-01-01'::timestamptz + ((id % 100) || ' days')::interval,
	       '1970-01-01'::timestamp + ((id % 100) || ' days')::interval,
	       id % 10,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;
--Testcase 2:
INSERT INTO "S 1"."T 2"
	SELECT id,
	       'AAA' || to_char(id, 'FM000')
	FROM generate_series(1, 100) id;
--Testcase 3:
INSERT INTO "S 1"."T 3"
	SELECT id,
	       id + 1,
	       'AAA' || to_char(id, 'FM000')
	FROM generate_series(1, 100) id;
--Testcase 487:
DELETE FROM "S 1"."T 3" WHERE c1 % 2 != 0;	-- delete for outer join tests
--Testcase 4:
INSERT INTO "S 1"."T 4"
	SELECT id,
	       id + 1,
	       'AAA' || to_char(id, 'FM000')
	FROM generate_series(1, 100) id;
--Testcase 488:
DELETE FROM "S 1"."T 4" WHERE c1 % 3 != 0;	-- delete for outer join tests

/*ANALYZE "S 1"."T 1";
ANALYZE "S 1"."T 2";
ANALYZE "S 1"."T 3";
ANALYZE "S 1"."T 4";*/

-- ===================================================================
-- create foreign tables
-- ===================================================================
--Testcase 489:
CREATE FOREIGN TABLE ft1 (
	c0 int,
	c1 int OPTIONS (key 'true'),
	c2 int NOT NULL,
	c3 text,
	c4 timestamptz,
	c5 timestamp,
	c6 varchar(10),
	c7 char(10) default 'ft1',
	c8 text
) SERVER sqlite_svr;
--Testcase 757:
ALTER FOREIGN TABLE ft1 DROP COLUMN c0;

--Testcase 490:
CREATE FOREIGN TABLE ft2 (
	c1 int OPTIONS (key 'true'),
	c2 int NOT NULL,
	cx int,
	c3 text,
	c4 timestamptz,
	c5 timestamp,
	c6 varchar(10),
	c7 char(10) default 'ft2',
	c8 text
) SERVER sqlite_svr;
--Testcase 758:
ALTER FOREIGN TABLE ft2 DROP COLUMN cx;

--Testcase 491:
CREATE FOREIGN TABLE ft4 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text
) SERVER sqlite_svr OPTIONS (table 'T 3');

--Testcase 492:
CREATE FOREIGN TABLE ft5 (
	c1 int OPTIONS (key 'true'),
	c2 int NOT NULL,
	c3 text
) SERVER sqlite_svr OPTIONS (table 'T 4');

--Testcase 493:
CREATE FOREIGN TABLE ft6 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text
) SERVER sqlite_svr2 OPTIONS (table 'T 4');

--Testcase 759:
CREATE FOREIGN TABLE ft7 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text
) SERVER sqlite_svr3 OPTIONS (table 'T 4');

--Testcase 760:
ALTER FOREIGN TABLE ft1 OPTIONS (table 'T 1');
--Testcase 761:
ALTER FOREIGN TABLE ft2 OPTIONS (table 'T 1');
--Testcase 762:
ALTER FOREIGN TABLE ft1 ALTER COLUMN c1 OPTIONS (column_name 'C 1');
--Testcase 763:
ALTER FOREIGN TABLE ft2 ALTER COLUMN c1 OPTIONS (column_name 'C 1');
--Testcase 5:
\det+

-- Test that alteration of server options causes reconnection
-- Remote's errors might be non-English, so hide them to ensure stable results
\set VERBOSITY terse
--Testcase 6:
SELECT c3, c4 FROM ft1 ORDER BY c3, c1 LIMIT 1;  -- should work
--Testcase 764:
ALTER SERVER sqlite_svr OPTIONS (SET database 'no such database');
--Testcase 7:
SELECT c3, c4 FROM ft1 ORDER BY c3, c1 LIMIT 1;  -- should fail
DO $d$
    BEGIN
        EXECUTE $$ALTER SERVER sqlite_svr
            OPTIONS (SET database '/tmp/sqlitefdw_test_post.db')$$;
    END;
$d$;
--Testcase 8:
SELECT c3, c4 FROM ft1 ORDER BY c3, c1 LIMIT 1;  -- should work again
\set VERBOSITY default

-- Now we should be able to run ANALYZE.
-- To exercise multiple code paths, we use local stats on ft1
-- and remote-estimate mode on ft2.
--ANALYZE ft1;
--ALTER FOREIGN TABLE ft2 OPTIONS (use_remote_estimate 'true');

-- ===================================================================
-- simple queries
-- ===================================================================
-- single table without alias
--Testcase 9:
EXPLAIN (COSTS OFF) SELECT * FROM ft1 ORDER BY c3, c1 OFFSET 100 LIMIT 10;
--Testcase 10:
SELECT * FROM ft1 ORDER BY c3, c1 OFFSET 100 LIMIT 10;
-- single table with alias - also test that tableoid sort is not pushed to remote side
--Testcase 11:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 ORDER BY t1.c3, t1.c1, t1.tableoid OFFSET 100 LIMIT 10;
--Testcase 12:
SELECT * FROM ft1 t1 ORDER BY t1.c3, t1.c1, t1.tableoid OFFSET 100 LIMIT 10;
-- whole-row reference
--Testcase 13:
EXPLAIN (VERBOSE, COSTS OFF) SELECT t1 FROM ft1 t1 ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
--Testcase 14:
SELECT t1 FROM ft1 t1 ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
-- empty result
--Testcase 15:
SELECT * FROM ft1 WHERE false;
-- with WHERE clause
--Testcase 16:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE t1.c1 = 101 AND t1.c6 = '1' AND t1.c7 >= '1';
--Testcase 17:
SELECT * FROM ft1 t1 WHERE t1.c1 = 101 AND t1.c6 = '1' AND t1.c7 >= '1';
-- with FOR UPDATE/SHARE
--Testcase 18:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c1 = 101 FOR UPDATE;
--Testcase 19:
SELECT * FROM ft1 t1 WHERE c1 = 101 FOR UPDATE;
--Testcase 20:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c1 = 102 FOR SHARE;
--Testcase 21:
SELECT * FROM ft1 t1 WHERE c1 = 102 FOR SHARE;
-- aggregate
--Testcase 22:
SELECT COUNT(*) FROM ft1 t1;
-- subquery
--Testcase 23:
SELECT * FROM ft1 t1 WHERE t1.c3 IN (SELECT c3 FROM ft2 t2 WHERE c1 <= 10) ORDER BY c1;
-- subquery+MAX
--Testcase 24:
SELECT * FROM ft1 t1 WHERE t1.c3 = (SELECT MAX(c3) FROM ft2 t2) ORDER BY c1;
-- used in CTE
--Testcase 25:
WITH t1 AS (SELECT * FROM ft1 WHERE c1 <= 10) SELECT t2.c1, t2.c2, t2.c3, t2.c4 FROM t1, ft2 t2 WHERE t1.c1 = t2.c1 ORDER BY t1.c1;
-- fixed values
--Testcase 26:
SELECT 'fixed', NULL FROM ft1 t1 WHERE c1 = 1;
-- Test forcing the remote server to produce sorted data for a merge join.
--Testcase 765:
SET enable_hashjoin TO false;
--Testcase 766:
SET enable_nestloop TO false;
-- inner join; expressions in the clauses appear in the equivalence class list
--Testcase 27:
EXPLAIN (VERBOSE, COSTS OFF)
	SELECT t1.c1, t2."C 1" FROM ft2 t1 JOIN "S 1"."T 1" t2 ON (t1.c1 = t2."C 1") OFFSET 100 LIMIT 10;
--Testcase 28:
SELECT t1.c1, t2."C 1" FROM ft2 t1 JOIN "S 1"."T 1" t2 ON (t1.c1 = t2."C 1") OFFSET 100 LIMIT 10;
-- outer join; expressions in the clauses do not appear in equivalence class
-- list but no output change as compared to the previous query
--Testcase 29:
EXPLAIN (VERBOSE, COSTS OFF)
	SELECT t1.c1, t2."C 1" FROM ft2 t1 LEFT JOIN "S 1"."T 1" t2 ON (t1.c1 = t2."C 1") OFFSET 100 LIMIT 10;
--Testcase 30:
SELECT t1.c1, t2."C 1" FROM ft2 t1 LEFT JOIN "S 1"."T 1" t2 ON (t1.c1 = t2."C 1") OFFSET 100 LIMIT 10;
-- A join between local table and foreign join. ORDER BY clause is added to the
-- foreign join so that the local table can be joined using merge join strategy.
--Testcase 31:
EXPLAIN (VERBOSE, COSTS OFF)
	SELECT t1."C 1" FROM "S 1"."T 1" t1 left join ft1 t2 join ft2 t3 on (t2.c1 = t3.c1) on (t3.c1 = t1."C 1") OFFSET 100 LIMIT 10;
--Testcase 32:
SELECT t1."C 1" FROM "S 1"."T 1" t1 left join ft1 t2 join ft2 t3 on (t2.c1 = t3.c1) on (t3.c1 = t1."C 1") OFFSET 100 LIMIT 10;
-- Test similar to above, except that the full join prevents any equivalence
-- classes from being merged. This produces single relation equivalence classes
-- included in join restrictions.
--Testcase 33:
EXPLAIN (VERBOSE, COSTS OFF)
	SELECT t1."C 1", t2.c1, t3.c1 FROM "S 1"."T 1" t1 left join ft1 t2 full join ft2 t3 on (t2.c1 = t3.c1) on (t3.c1 = t1."C 1") OFFSET 100 LIMIT 10;
--Testcase 34:
SELECT t1."C 1", t2.c1, t3.c1 FROM "S 1"."T 1" t1 left join ft1 t2 full join ft2 t3 on (t2.c1 = t3.c1) on (t3.c1 = t1."C 1") OFFSET 100 LIMIT 10;
-- Test similar to above with all full outer joins
--Testcase 35:
EXPLAIN (VERBOSE, COSTS OFF)
	SELECT t1."C 1", t2.c1, t3.c1 FROM "S 1"."T 1" t1 full join ft1 t2 full join ft2 t3 on (t2.c1 = t3.c1) on (t3.c1 = t1."C 1") OFFSET 100 LIMIT 10;
--Testcase 36:
SELECT t1."C 1", t2.c1, t3.c1 FROM "S 1"."T 1" t1 full join ft1 t2 full join ft2 t3 on (t2.c1 = t3.c1) on (t3.c1 = t1."C 1") OFFSET 100 LIMIT 10;
--Testcase 767:
RESET enable_hashjoin;
--Testcase 768:
RESET enable_nestloop;

-- Test executing assertion in estimate_path_cost_size() that makes sure that
-- retrieved_rows for foreign rel re-used to cost pre-sorted foreign paths is
-- a sensible value even when the rel has tuples=0
-- CREATE TABLE loct_empty (c1 int NOT NULL, c2 text);
--Testcase 769:
CREATE FOREIGN TABLE ft_empty (c1 int NOT NULL, c2 text)
  SERVER sqlite_svr OPTIONS (table 'loct_empty');
--Testcase 770:
INSERT INTO "S 1".loct_empty
  SELECT id, 'AAA' || to_char(id, 'FM000') FROM generate_series(1, 100) id;
--Testcase 771:
DELETE FROM "S 1".loct_empty;
-- ANALYZE ft_empty;
--Testcase 772:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft_empty ORDER BY c1;

-- ===================================================================
-- WHERE with remotely-executable conditions
-- ===================================================================
--Testcase 37:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE t1.c1 = 1;         -- Var, OpExpr(b), Const
--Testcase 38:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE t1.c1 = 100 AND t1.c2 = 0; -- BoolExpr
--Testcase 39:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c1 IS NULL;        -- NullTest
--Testcase 40:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c1 IS NOT NULL;    -- NullTest
--Testcase 41:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE round(abs(c1), 0) = 1; -- FuncExpr
--Testcase 42:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c1 = -c1;          -- OpExpr(l)
--Testcase 44:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE (c1 IS NOT NULL) IS DISTINCT FROM (c1 IS NOT NULL); -- DistinctExpr
--Testcase 45:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c1 = ANY(ARRAY[c2, 1, c1 + 0]); -- ScalarArrayOpExpr
--Testcase 46:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c1 = (ARRAY[c1,c2,3])[1]; -- SubscriptingRef
--Testcase 47:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c6 = E'foo''s\\bar';  -- check special chars
--Testcase 48:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 t1 WHERE c8 = 'foo';  -- can't be sent to remote
-- parameterized remote path for foreign table
--Testcase 49:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT * FROM "S 1"."T 1" a, ft2 b WHERE a."C 1" = 47 AND b.c1 = a.c2;
--Testcase 50:
SELECT * FROM ft2 a, ft2 b WHERE a.c1 = 47 AND b.c1 = a.c2;

-- check both safe and unsafe join conditions
--Testcase 51:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT * FROM ft2 a, ft2 b
  WHERE a.c2 = 6 AND b.c1 = a.c1 AND a.c8 = 'foo' AND b.c7 = upper(a.c7);
--Testcase 52:
SELECT * FROM ft2 a, ft2 b
WHERE a.c2 = 6 AND b.c1 = a.c1 AND a.c8 = 'foo' AND b.c7 = upper(a.c7);
-- bug before 9.3.5 due to sloppy handling of remote-estimate parameters
--Testcase 53:
SELECT * FROM ft1 WHERE c1 = ANY (ARRAY(SELECT c1 FROM ft2 WHERE c1 < 5));
--Testcase 54:
SELECT * FROM ft2 WHERE c1 = ANY (ARRAY(SELECT c1 FROM ft1 WHERE c1 < 5));
-- we should not push order by clause with volatile expressions or unsafe
-- collations
--Testcase 55:
EXPLAIN (VERBOSE, COSTS OFF)
	SELECT * FROM ft2 ORDER BY ft2.c1, random();
--Testcase 56:
EXPLAIN (VERBOSE, COSTS OFF)
	SELECT * FROM ft2 ORDER BY ft2.c1, ft2.c3 collate "C";

-- user-defined operator/function
--Testcase 494:
CREATE FUNCTION sqlite_fdw_abs(int) RETURNS int AS $$
BEGIN
RETURN abs($1);
END
$$ LANGUAGE plpgsql IMMUTABLE;
--Testcase 495:
CREATE OPERATOR === (
    LEFTARG = int,
    RIGHTARG = int,
    PROCEDURE = int4eq,
    COMMUTATOR = ===
);

-- built-in operators and functions can be shipped for remote execution
--Testcase 57:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT count(c3) FROM ft1 t1 WHERE t1.c1 = abs(t1.c2);
--Testcase 58:
SELECT count(c3) FROM ft1 t1 WHERE t1.c1 = abs(t1.c2);
--Testcase 59:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT count(c3) FROM ft1 t1 WHERE t1.c1 = t1.c2;
--Testcase 60:
SELECT count(c3) FROM ft1 t1 WHERE t1.c1 = t1.c2;

-- by default, user-defined ones cannot
--Testcase 61:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT count(c3) FROM ft1 t1 WHERE t1.c1 = sqlite_fdw_abs(t1.c2);
--Testcase 62:
SELECT count(c3) FROM ft1 t1 WHERE t1.c1 = sqlite_fdw_abs(t1.c2);
--Testcase 63:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT count(c3) FROM ft1 t1 WHERE t1.c1 === t1.c2;
--Testcase 64:
SELECT count(c3) FROM ft1 t1 WHERE t1.c1 === t1.c2;

-- ORDER BY can be shipped, though
--Testcase 496:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT * FROM ft1 t1 WHERE t1.c1 === t1.c2 order by t1.c2 limit 1;
--Testcase 497:
SELECT * FROM ft1 t1 WHERE t1.c1 === t1.c2 order by t1.c2 limit 1;

-- but let's put them in an extension ...
--Testcase 773:
ALTER EXTENSION sqlite_fdw ADD FUNCTION sqlite_fdw_abs(int);
--Testcase 774:
ALTER EXTENSION sqlite_fdw ADD OPERATOR === (int, int);
--ALTER SERVER sqlite_svr2 OPTIONS (ADD extensions 'sqlite_fdw');

-- ... now they can be shipped
--Testcase 498:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT count(c3) FROM ft1 t1 WHERE t1.c1 = sqlite_fdw_abs(t1.c2);
--Testcase 499:
SELECT count(c3) FROM ft1 t1 WHERE t1.c1 = sqlite_fdw_abs(t1.c2);
--Testcase 500:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT count(c3) FROM ft1 t1 WHERE t1.c1 === t1.c2;
--Testcase 501:
SELECT count(c3) FROM ft1 t1 WHERE t1.c1 === t1.c2;

-- and both ORDER BY and LIMIT can be shipped
--Testcase 502:
EXPLAIN (VERBOSE, COSTS OFF)
  SELECT * FROM ft1 t1 WHERE t1.c1 === t1.c2 order by t1.c2 limit 1;
--Testcase 503:
SELECT * FROM ft1 t1 WHERE t1.c1 === t1.c2 order by t1.c2 limit 1;

-- ===================================================================
-- JOIN queries
-- ===================================================================
-- Analyze ft4 and ft5 so that we have better statistics. These tables do not
-- have use_remote_estimate set.
--ANALYZE ft4;
--ANALYZE ft5;

-- join two tables
--Testcase 65:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
--Testcase 66:
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
-- join three tables
--Testcase 67:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) JOIN ft4 t3 ON (t3.c1 = t1.c1) ORDER BY t1.c3, t1.c1 OFFSET 10 LIMIT 10;
--Testcase 68:
SELECT t1.c1, t2.c2, t3.c3 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) JOIN ft4 t3 ON (t3.c1 = t1.c1) ORDER BY t1.c3, t1.c1 OFFSET 10 LIMIT 10;
-- left outer join
--Testcase 69:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft4 t1 LEFT JOIN ft5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;
--Testcase 70:
SELECT t1.c1, t2.c1 FROM ft4 t1 LEFT JOIN ft5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;
-- left outer join three tables
--Testcase 71:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) LEFT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 72:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) LEFT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
-- left outer join + placement of clauses.
-- clauses within the nullable side are not pulled up, but top level clause on
-- non-nullable side is pushed into non-nullable side
--Testcase 73:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t1.c2, t2.c1, t2.c2 FROM ft4 t1 LEFT JOIN (SELECT * FROM ft5 WHERE c1 < 10) t2 ON (t1.c1 = t2.c1) WHERE t1.c1 < 10;
--Testcase 74:
SELECT t1.c1, t1.c2, t2.c1, t2.c2 FROM ft4 t1 LEFT JOIN (SELECT * FROM ft5 WHERE c1 < 10) t2 ON (t1.c1 = t2.c1) WHERE t1.c1 < 10;
-- clauses within the nullable side are not pulled up, but the top level clause
-- on nullable side is not pushed down into nullable side
--Testcase 75:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t1.c2, t2.c1, t2.c2 FROM ft4 t1 LEFT JOIN (SELECT * FROM ft5 WHERE c1 < 10) t2 ON (t1.c1 = t2.c1)
			WHERE (t2.c1 < 10 OR t2.c1 IS NULL) AND t1.c1 < 10;
--Testcase 76:
SELECT t1.c1, t1.c2, t2.c1, t2.c2 FROM ft4 t1 LEFT JOIN (SELECT * FROM ft5 WHERE c1 < 10) t2 ON (t1.c1 = t2.c1)
			WHERE (t2.c1 < 10 OR t2.c1 IS NULL) AND t1.c1 < 10;
-- right outer join
--Testcase 77:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft5 t1 RIGHT JOIN ft4 t2 ON (t1.c1 = t2.c1) ORDER BY t2.c1, t1.c1 OFFSET 10 LIMIT 10;
--Testcase 78:
SELECT t1.c1, t2.c1 FROM ft5 t1 RIGHT JOIN ft4 t2 ON (t1.c1 = t2.c1) ORDER BY t2.c1, t1.c1 OFFSET 10 LIMIT 10;
-- right outer join three tables
--Testcase 79:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 RIGHT JOIN ft2 t2 ON (t1.c1 = t2.c1) RIGHT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 80:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 RIGHT JOIN ft2 t2 ON (t1.c1 = t2.c1) RIGHT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
-- full outer join
--Testcase 81:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft4 t1 FULL JOIN ft5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 45 LIMIT 10;
--Testcase 82:
SELECT t1.c1, t2.c1 FROM ft4 t1 FULL JOIN ft5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 45 LIMIT 10;
-- full outer join with restrictions on the joining relations
-- a. the joining relations are both base relations
--Testcase 83:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t1 FULL JOIN (SELECT c1 FROM ft5 WHERE c1 between 50 and 60) t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1;
--Testcase 84:
SELECT t1.c1, t2.c1 FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t1 FULL JOIN (SELECT c1 FROM ft5 WHERE c1 between 50 and 60) t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1;
--Testcase 85:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT 1 FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t1 FULL JOIN (SELECT c1 FROM ft5 WHERE c1 between 50 and 60) t2 ON (TRUE) OFFSET 10 LIMIT 10;
--Testcase 86:
SELECT 1 FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t1 FULL JOIN (SELECT c1 FROM ft5 WHERE c1 between 50 and 60) t2 ON (TRUE) OFFSET 10 LIMIT 10;
-- b. one of the joining relations is a base relation and the other is a join
-- relation
--Testcase 87:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, ss.a, ss.b FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t1 FULL JOIN (SELECT t2.c1, t3.c1 FROM ft4 t2 LEFT JOIN ft5 t3 ON (t2.c1 = t3.c1) WHERE (t2.c1 between 50 and 60)) ss(a, b) ON (t1.c1 = ss.a) ORDER BY t1.c1, ss.a, ss.b;
--Testcase 88:
SELECT t1.c1, ss.a, ss.b FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t1 FULL JOIN (SELECT t2.c1, t3.c1 FROM ft4 t2 LEFT JOIN ft5 t3 ON (t2.c1 = t3.c1) WHERE (t2.c1 between 50 and 60)) ss(a, b) ON (t1.c1 = ss.a) ORDER BY t1.c1, ss.a, ss.b;
-- c. test deparsing the remote query as nested subqueries
--Testcase 89:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, ss.a, ss.b FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t1 FULL JOIN (SELECT t2.c1, t3.c1 FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t2 FULL JOIN (SELECT c1 FROM ft5 WHERE c1 between 50 and 60) t3 ON (t2.c1 = t3.c1) WHERE t2.c1 IS NULL OR t2.c1 IS NOT NULL) ss(a, b) ON (t1.c1 = ss.a) ORDER BY t1.c1, ss.a, ss.b;
--Testcase 90:
SELECT t1.c1, ss.a, ss.b FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t1 FULL JOIN (SELECT t2.c1, t3.c1 FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t2 FULL JOIN (SELECT c1 FROM ft5 WHERE c1 between 50 and 60) t3 ON (t2.c1 = t3.c1) WHERE t2.c1 IS NULL OR t2.c1 IS NOT NULL) ss(a, b) ON (t1.c1 = ss.a) ORDER BY t1.c1, ss.a, ss.b;
-- d. test deparsing rowmarked relations as subqueries
--Testcase 91:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, ss.a, ss.b FROM (SELECT c1 FROM "S 1"."T 3" WHERE c1 = 50) t1 INNER JOIN (SELECT t2.c1, t3.c1 FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t2 FULL JOIN (SELECT c1 FROM ft5 WHERE c1 between 50 and 60) t3 ON (t2.c1 = t3.c1) WHERE t2.c1 IS NULL OR t2.c1 IS NOT NULL) ss(a, b) ON (TRUE) ORDER BY t1.c1, ss.a, ss.b FOR UPDATE OF t1;
--Testcase 92:
SELECT t1.c1, ss.a, ss.b FROM (SELECT c1 FROM "S 1"."T 3" WHERE c1 = 50) t1 INNER JOIN (SELECT t2.c1, t3.c1 FROM (SELECT c1 FROM ft4 WHERE c1 between 50 and 60) t2 FULL JOIN (SELECT c1 FROM ft5 WHERE c1 between 50 and 60) t3 ON (t2.c1 = t3.c1) WHERE t2.c1 IS NULL OR t2.c1 IS NOT NULL) ss(a, b) ON (TRUE) ORDER BY t1.c1, ss.a, ss.b FOR UPDATE OF t1;
-- full outer join + inner join
--Testcase 93:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1, t3.c1 FROM ft4 t1 INNER JOIN ft5 t2 ON (t1.c1 = t2.c1 + 1 and t1.c1 between 50 and 60) FULL JOIN ft4 t3 ON (t2.c1 = t3.c1) ORDER BY t1.c1, t2.c1, t3.c1 LIMIT 10;
--Testcase 94:
SELECT t1.c1, t2.c1, t3.c1 FROM ft4 t1 INNER JOIN ft5 t2 ON (t1.c1 = t2.c1 + 1 and t1.c1 between 50 and 60) FULL JOIN ft4 t3 ON (t2.c1 = t3.c1) ORDER BY t1.c1, t2.c1, t3.c1 LIMIT 10;
-- full outer join three tables
--Testcase 95:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 FULL JOIN ft2 t2 ON (t1.c1 = t2.c1) FULL JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 96:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 FULL JOIN ft2 t2 ON (t1.c1 = t2.c1) FULL JOIN ft4 t3 ON (t2.c1 = t3.c1) ORDER BY t1.c1 OFFSET 10 LIMIT 10;
-- full outer join + right outer join
--Testcase 97:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 FULL JOIN ft2 t2 ON (t1.c1 = t2.c1) RIGHT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 98:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 FULL JOIN ft2 t2 ON (t1.c1 = t2.c1) RIGHT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
-- right outer join + full outer join
--Testcase 99:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 RIGHT JOIN ft2 t2 ON (t1.c1 = t2.c1) FULL JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 100:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 RIGHT JOIN ft2 t2 ON (t1.c1 = t2.c1) FULL JOIN ft4 t3 ON (t2.c1 = t3.c1) ORDER BY t1.c1 OFFSET 10 LIMIT 10;
-- full outer join + left outer join
--Testcase 101:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 FULL JOIN ft2 t2 ON (t1.c1 = t2.c1) LEFT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 102:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 FULL JOIN ft2 t2 ON (t1.c1 = t2.c1) LEFT JOIN ft4 t3 ON (t2.c1 = t3.c1) ORDER BY t1.c1 OFFSET 10 LIMIT 10;
-- left outer join + full outer join
--Testcase 103:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) FULL JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 104:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) FULL JOIN ft4 t3 ON (t2.c1 = t3.c1) ORDER BY t1.c1 OFFSET 10 LIMIT 10;
--Testcase 775:
SET enable_memoize TO off;
-- right outer join + left outer join
--Testcase 105:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 RIGHT JOIN ft2 t2 ON (t1.c1 = t2.c1) LEFT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 106:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 RIGHT JOIN ft2 t2 ON (t1.c1 = t2.c1) LEFT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 776:
RESET enable_memoize;
-- left outer join + right outer join
--Testcase 107:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) RIGHT JOIN ft4 t3 ON (t2.c1 = t3.c1) OFFSET 10 LIMIT 10;
--Testcase 108:
SELECT t1.c1, t2.c2, t3.c3 FROM ft2 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) RIGHT JOIN ft4 t3 ON (t2.c1 = t3.c1) ORDER BY t1.c1 OFFSET 10 LIMIT 10;
-- full outer join + WHERE clause, only matched rows
--Testcase 109:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft4 t1 FULL JOIN ft5 t2 ON (t1.c1 = t2.c1) WHERE (t1.c1 = t2.c1 OR t1.c1 IS NULL) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;
--Testcase 110:
SELECT t1.c1, t2.c1 FROM ft4 t1 FULL JOIN ft5 t2 ON (t1.c1 = t2.c1) WHERE (t1.c1 = t2.c1 OR t1.c1 IS NULL) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;
-- full outer join + WHERE clause with shippable extensions set
--Testcase 504:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t1.c3 FROM ft1 t1 FULL JOIN ft2 t2 ON (t1.c1 = t2.c1) WHERE sqlite_fdw_abs(t1.c1) > 0 OFFSET 10 LIMIT 10;
--ALTER SERVER sqlite_svr2 OPTIONS (DROP extensions);
-- full outer join + WHERE clause with shippable extensions not set
--Testcase 505:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2, t1.c3 FROM ft1 t1 FULL JOIN ft2 t2 ON (t1.c1 = t2.c1) WHERE sqlite_fdw_abs(t1.c1) > 0 OFFSET 10 LIMIT 10;
--Testcase 777:
ALTER SERVER loopback OPTIONS (ADD extensions 'postgres_fdw');
-- join two tables with FOR UPDATE clause
-- tests whole-row reference for row marks
--Testcase 111:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10 FOR UPDATE OF t1;
--Testcase 112:
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10 FOR UPDATE OF t1;
--Testcase 113:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10 FOR UPDATE;
--Testcase 114:
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10 FOR UPDATE;
-- join two tables with FOR SHARE clause
--Testcase 115:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10 FOR SHARE OF t1;
--Testcase 116:
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10 FOR SHARE OF t1;
--Testcase 117:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10 FOR SHARE;
--Testcase 118:
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10 FOR SHARE;
-- join in CTE
--Testcase 119:
EXPLAIN (VERBOSE, COSTS OFF)
WITH t (c1_1, c1_3, c2_1) AS MATERIALIZED (SELECT t1.c1, t1.c3, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1)) SELECT c1_1, c2_1 FROM t ORDER BY c1_3, c1_1 OFFSET 100 LIMIT 10;
--Testcase 120:
WITH t (c1_1, c1_3, c2_1) AS MATERIALIZED (SELECT t1.c1, t1.c3, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1)) SELECT c1_1, c2_1 FROM t ORDER BY c1_3, c1_1 OFFSET 100 LIMIT 10;
-- ctid with whole-row reference
--Testcase 121:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.ctid, t1, t2, t1.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
-- SEMI JOIN, not pushed down
--Testcase 122:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1 FROM ft1 t1 WHERE EXISTS (SELECT 1 FROM ft2 t2 WHERE t1.c1 = t2.c1) ORDER BY t1.c1 OFFSET 100 LIMIT 10;
--Testcase 123:
SELECT t1.c1 FROM ft1 t1 WHERE EXISTS (SELECT 1 FROM ft2 t2 WHERE t1.c1 = t2.c1) ORDER BY t1.c1 OFFSET 100 LIMIT 10;
-- ANTI JOIN, not pushed down
--Testcase 124:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1 FROM ft1 t1 WHERE NOT EXISTS (SELECT 1 FROM ft2 t2 WHERE t1.c1 = t2.c2) ORDER BY t1.c1 OFFSET 100 LIMIT 10;
--Testcase 125:
SELECT t1.c1 FROM ft1 t1 WHERE NOT EXISTS (SELECT 1 FROM ft2 t2 WHERE t1.c1 = t2.c2) ORDER BY t1.c1 OFFSET 100 LIMIT 10;
-- CROSS JOIN can be pushed down
--Testcase 126:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 CROSS JOIN ft2 t2 ORDER BY t1.c1, t2.c1 OFFSET 100 LIMIT 10;
--Testcase 127:
SELECT t1.c1, t2.c1 FROM ft1 t1 CROSS JOIN ft2 t2 ORDER BY t1.c1, t2.c1 OFFSET 100 LIMIT 10;
-- different server, not pushed down. No result expected.
--Testcase 128:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft5 t1 JOIN ft6 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 100 LIMIT 10;
--Testcase 129:
SELECT t1.c1, t2.c1 FROM ft5 t1 JOIN ft6 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 100 LIMIT 10;
-- unsafe join conditions (c8 has a UDT), not pushed down. Practically a CROSS
-- JOIN since c8 in both tables has same value.
--Testcase 130:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 LEFT JOIN ft2 t2 ON (t1.c8 = t2.c8) ORDER BY t1.c1, t2.c1 OFFSET 100 LIMIT 10;
--Testcase 131:
SELECT t1.c1, t2.c1 FROM ft1 t1 LEFT JOIN ft2 t2 ON (t1.c8 = t2.c8) ORDER BY t1.c1, t2.c1 OFFSET 100 LIMIT 10;
-- unsafe conditions on one side (c8 has a UDT), not pushed down.
--Testcase 132:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) WHERE t1.c8 = 'foo' ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
--Testcase 133:
SELECT t1.c1, t2.c1 FROM ft1 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) WHERE t1.c8 = 'foo' ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
-- join where unsafe to pushdown condition in WHERE clause has a column not
-- in the SELECT clause. In this test unsafe clause needs to have column
-- references from both joining sides so that the clause is not pushed down
-- into one of the joining sides.
--Testcase 134:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) WHERE t1.c8 = t2.c8 ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
--Testcase 135:
SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) WHERE t1.c8 = t2.c8 ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
-- Aggregate after UNION, for testing setrefs
--Testcase 136:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1c1, avg(t1c1 + t2c1) FROM (SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) UNION SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1)) AS t (t1c1, t2c1) GROUP BY t1c1 ORDER BY t1c1 OFFSET 100 LIMIT 10;
--Testcase 137:
SELECT t1c1, avg(t1c1 + t2c1) FROM (SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) UNION SELECT t1.c1, t2.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1)) AS t (t1c1, t2c1) GROUP BY t1c1 ORDER BY t1c1 OFFSET 100 LIMIT 10;
-- join with lateral reference
--Testcase 138:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1."C 1" FROM "S 1"."T 1" t1, LATERAL (SELECT DISTINCT t2.c1, t3.c1 FROM ft1 t2, ft2 t3 WHERE t2.c1 = t3.c1 AND t2.c2 = t1.c2) q ORDER BY t1."C 1" OFFSET 10 LIMIT 10;
--Testcase 139:
SELECT t1."C 1" FROM "S 1"."T 1" t1, LATERAL (SELECT DISTINCT t2.c1, t3.c1 FROM ft1 t2, ft2 t3 WHERE t2.c1 = t3.c1 AND t2.c2 = t1.c2) q ORDER BY t1."C 1" OFFSET 10 LIMIT 10;

-- non-Var items in targetlist of the nullable rel of a join preventing
-- push-down in some cases
-- unable to push {ft1, ft2}
--Testcase 140:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT q.a, ft2.c1 FROM (SELECT 13 FROM ft1 WHERE c1 = 13) q(a) RIGHT JOIN ft2 ON (q.a = ft2.c1) WHERE ft2.c1 BETWEEN 10 AND 15;
--Testcase 141:
SELECT q.a, ft2.c1 FROM (SELECT 13 FROM ft1 WHERE c1 = 13) q(a) RIGHT JOIN ft2 ON (q.a = ft2.c1) WHERE ft2.c1 BETWEEN 10 AND 15;

-- ok to push {ft1, ft2} but not {ft1, ft2, ft4}
--Testcase 142:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT ft4.c1, q.* FROM ft4 LEFT JOIN (SELECT 13, ft1.c1, ft2.c1 FROM ft1 RIGHT JOIN ft2 ON (ft1.c1 = ft2.c1) WHERE ft1.c1 = 12) q(a, b, c) ON (ft4.c1 = q.b) WHERE ft4.c1 BETWEEN 10 AND 15;
--Testcase 143:
SELECT ft4.c1, q.* FROM ft4 LEFT JOIN (SELECT 13, ft1.c1, ft2.c1 FROM ft1 RIGHT JOIN ft2 ON (ft1.c1 = ft2.c1) WHERE ft1.c1 = 12) q(a, b, c) ON (ft4.c1 = q.b) WHERE ft4.c1 BETWEEN 10 AND 15;

-- join with nullable side with some columns with null values
--Testcase 144:
UPDATE ft5 SET c3 = null where c1 % 9 = 0;
--Testcase 145:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT ft5, ft5.c1, ft5.c2, ft5.c3, ft4.c1, ft4.c2 FROM ft5 left join ft4 on ft5.c1 = ft4.c1 WHERE ft4.c1 BETWEEN 10 and 30 ORDER BY ft5.c1, ft4.c1;
--Testcase 146:
SELECT ft5, ft5.c1, ft5.c2, ft5.c3, ft4.c1, ft4.c2 FROM ft5 left join ft4 on ft5.c1 = ft4.c1 WHERE ft4.c1 BETWEEN 10 and 30 ORDER BY ft5.c1, ft4.c1;

-- multi-way join involving multiple merge joins
-- (this case used to have EPQ-related planning problems)
--Testcase 506:
CREATE TABLE local_tbl (c1 int NOT NULL, c2 int NOT NULL, c3 text, CONSTRAINT local_tbl_pkey PRIMARY KEY (c1));
--Testcase 507:
INSERT INTO local_tbl SELECT id, id % 10, to_char(id, 'FM0000') FROM generate_series(1, 1000) id;
ANALYZE local_tbl;
--Testcase 778:
SET enable_nestloop TO false;
--Testcase 779:
SET enable_hashjoin TO false;
--Testcase 147:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM ft1, ft2, ft4, ft5, local_tbl WHERE ft1.c1 = ft2.c1 AND ft1.c2 = ft4.c1
    AND ft1.c2 = ft5.c1 AND ft1.c2 = local_tbl.c1 AND ft1.c1 < 100 AND ft2.c1 < 100 FOR UPDATE;
--Testcase 148:
SELECT * FROM ft1, ft2, ft4, ft5, local_tbl WHERE ft1.c1 = ft2.c1 AND ft1.c2 = ft4.c1
    AND ft1.c2 = ft5.c1 AND ft1.c2 = local_tbl.c1 AND ft1.c1 < 100 AND ft2.c1 < 100 ORDER BY ft1.c1 FOR UPDATE;
--Testcase 780:
RESET enable_nestloop;
--Testcase 781:
RESET enable_hashjoin;
--DROP TABLE local_tbl;

-- check join pushdown in situations where multiple userids are involved
--Testcase 508:
CREATE ROLE regress_view_owner SUPERUSER;
--Testcase 509:
CREATE USER MAPPING FOR regress_view_owner SERVER sqlite_svr;
GRANT SELECT ON ft4 TO regress_view_owner;
GRANT SELECT ON ft5 TO regress_view_owner;

--Testcase 510:
CREATE VIEW v4 AS SELECT * FROM ft4;
--Testcase 511:
CREATE VIEW v5 AS SELECT * FROM ft5;
--Testcase 782:
ALTER VIEW v5 OWNER TO regress_view_owner;
--Testcase 149:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2 FROM v4 t1 LEFT JOIN v5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;  -- can't be pushed down, different view owners
--Testcase 150:
SELECT t1.c1, t2.c2 FROM v4 t1 LEFT JOIN v5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;
--Testcase 783:
ALTER VIEW v4 OWNER TO regress_view_owner;
--Testcase 151:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2 FROM v4 t1 LEFT JOIN v5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;  -- can be pushed down
--Testcase 152:
SELECT t1.c1, t2.c2 FROM v4 t1 LEFT JOIN v5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;

--Testcase 153:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2 FROM v4 t1 LEFT JOIN ft5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;  -- can't be pushed down, view owner not current user
--Testcase 154:
SELECT t1.c1, t2.c2 FROM v4 t1 LEFT JOIN ft5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;
--Testcase 784:
ALTER VIEW v4 OWNER TO CURRENT_USER;
--Testcase 155:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.c1, t2.c2 FROM v4 t1 LEFT JOIN ft5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;  -- can be pushed down
--Testcase 156:
SELECT t1.c1, t2.c2 FROM v4 t1 LEFT JOIN ft5 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1, t2.c1 OFFSET 10 LIMIT 10;
--Testcase 785:
ALTER VIEW v4 OWNER TO regress_view_owner;

-- cleanup
--Testcase 512:
DROP OWNED BY regress_view_owner;
--Testcase 513:
DROP ROLE regress_view_owner;


-- ===================================================================
-- Aggregate and grouping queries
-- ===================================================================

-- Simple aggregates
--Testcase 157:
explain (verbose, costs off)
select count(c6), sum(c1), avg(c1), min(c2), max(c1), stddev(c2), sum(c1) * (random() <= 1)::int as sum2 from ft1 where c2 < 5 group by c2 order by 1, 2;
--Testcase 158:
select count(c6), sum(c1), avg(c1), min(c2), max(c1), stddev(c2), sum(c1) * (random() <= 1)::int as sum2 from ft1 where c2 < 5 group by c2 order by 1, 2;

--Testcase 514:
explain (verbose, costs off)
select count(c6), sum(c1), avg(c1), min(c2), max(c1), stddev(c2), sum(c1) * (random() <= 1)::int as sum2 from ft1 where c2 < 5 group by c2 order by 1, 2 limit 1;
--Testcase 515:
select count(c6), sum(c1), avg(c1), min(c2), max(c1), stddev(c2), sum(c1) * (random() <= 1)::int as sum2 from ft1 where c2 < 5 group by c2 order by 1, 2 limit 1;

-- Aggregate is not pushed down as aggregation contains random()
--Testcase 159:
explain (verbose, costs off)
select sum(c1 * (random() <= 1)::int) as sum, avg(c1) from ft1;

-- Aggregate over join query
--Testcase 160:
explain (verbose, costs off)
select count(*), sum(t1.c1), avg(t2.c1) from ft1 t1 inner join ft1 t2 on (t1.c2 = t2.c2) where t1.c2 = 6;
--Testcase 161:
select count(*), sum(t1.c1), avg(t2.c1) from ft1 t1 inner join ft1 t2 on (t1.c2 = t2.c2) where t1.c2 = 6;

-- Not pushed down due to local conditions present in underneath input rel
--Testcase 162:
explain (verbose, costs off)
select sum(t1.c1), count(t2.c1) from ft1 t1 inner join ft2 t2 on (t1.c1 = t2.c1) where ((t1.c1 * t2.c1)/(t1.c1 * t2.c1)) * random() <= 1;

-- GROUP BY clause having expressions
--Testcase 163:
explain (verbose, costs off)
select c2/2, sum(c2) * (c2/2) from ft1 group by c2/2 order by c2/2;
--Testcase 164:
select c2/2, sum(c2) * (c2/2) from ft1 group by c2/2 order by c2/2;

-- Aggregates in subquery are pushed down.
--Testcase 165:
explain (verbose, costs off)
select count(x.a), sum(x.a) from (select c2 a, sum(c1) b from ft1 group by c2, sqrt(c1) order by 1, 2) x;
--Testcase 166:
select count(x.a), sum(x.a) from (select c2 a, sum(c1) b from ft1 group by c2, sqrt(c1) order by 1, 2) x;

-- Aggregate is still pushed down by taking unshippable expression out
--Testcase 167:
explain (verbose, costs off)
select c2 * (random() <= 1)::int as sum1, sum(c1) * c2 as sum2 from ft1 group by c2 order by 1, 2;
--Testcase 168:
select c2 * (random() <= 1)::int as sum1, sum(c1) * c2 as sum2 from ft1 group by c2 order by 1, 2;

-- Aggregate with unshippable GROUP BY clause are not pushed
--Testcase 169:
explain (verbose, costs off)
select c2 * (random() <= 1)::int as c2 from ft2 group by c2 * (random() <= 1)::int order by 1;

-- GROUP BY clause in various forms, cardinal, alias and constant expression
--Testcase 516:
explain (verbose, costs off)
select count(c2) w, c2 x, 5 y, 7.0 z from ft1 group by 2, y, 9.0::int order by 2;
--Testcase 517:
select count(c2) w, c2 x, 5 y, 7.0 z from ft1 group by 2, y, 9.0::int order by 2;

-- GROUP BY clause referring to same column multiple times
-- Also, ORDER BY contains an aggregate function
--Testcase 170:
explain (verbose, costs off)
select c2, c2 from ft1 where c2 > 6 group by 1, 2 order by sum(c1);
--Testcase 171:
select c2, c2 from ft1 where c2 > 6 group by 1, 2 order by sum(c1);

-- Testing HAVING clause shippability
--Testcase 172:
explain (verbose, costs off)
select c2, sum(c1) from ft2 group by c2 having avg(c1) < 500 and sum(c1) < 49800 order by c2;
--Testcase 173:
select c2, sum(c1) from ft2 group by c2 having avg(c1) < 500 and sum(c1) < 49800 order by c2;

-- Unshippable HAVING clause will be evaluated locally, and other qual in HAVING clause is pushed down
--Testcase 174:
explain (verbose, costs off)
select count(*) from (select c5, count(c1) from ft1 group by c5, sqrt(c2) having (avg(c1) / avg(c1)) * random() <= 1 and avg(c1) < 500) x;
--Testcase 175:
select count(*) from (select c5, count(c1) from ft1 group by c5, sqrt(c2) having (avg(c1) / avg(c1)) * random() <= 1 and avg(c1) < 500) x;

-- Aggregate in HAVING clause is not pushable, and thus aggregation is not pushed down
--Testcase 176:
explain (verbose, costs off)
select sum(c1) from ft1 group by c2 having avg(c1 * (random() <= 1)::int) > 100 order by 1;

-- Remote aggregate in combination with a local Param (for the output
-- of an initplan) can be trouble, per bug #15781
--Testcase 518:
explain (verbose, costs off)
select exists(select 1 from pg_enum), sum(c1) from ft1;
--Testcase 519:
select exists(select 1 from pg_enum), sum(c1) from ft1;

--Testcase 520:
explain (verbose, costs off)
select exists(select 1 from pg_enum), sum(c1) from ft1 group by 1;
--Testcase 521:
select exists(select 1 from pg_enum), sum(c1) from ft1 group by 1;


-- Testing ORDER BY, DISTINCT, FILTER, Ordered-sets and VARIADIC within aggregates

-- ORDER BY within aggregate, same column used to order
--Testcase 177:
explain (verbose, costs off)
select array_agg(c1 order by c1) from ft1 where c1 < 100 group by c2 order by 1;
--Testcase 178:
select array_agg(c1 order by c1) from ft1 where c1 < 100 group by c2 order by 1;

-- ORDER BY within aggregate, different column used to order also using DESC
--Testcase 179:
explain (verbose, costs off)
select array_agg(c5 order by c1 desc) from ft2 where c2 = 6 and c1 < 50;
--Testcase 180:
select array_agg(c5 order by c1 desc) from ft2 where c2 = 6 and c1 < 50;

-- DISTINCT within aggregate
--Testcase 181:
explain (verbose, costs off)
select array_agg(distinct (t1.c1)%5) from ft4 t1 full join ft5 t2 on (t1.c1 = t2.c1) where t1.c1 < 20 or (t1.c1 is null and t2.c1 < 5) group by (t2.c1)%3 order by 1;
--Testcase 182:
select array_agg(distinct (t1.c1)%5) from ft4 t1 full join ft5 t2 on (t1.c1 = t2.c1) where t1.c1 < 20 or (t1.c1 is null and t2.c1 < 5) group by (t2.c1)%3 order by 1;

-- DISTINCT combined with ORDER BY within aggregate
--Testcase 183:
explain (verbose, costs off)
select array_agg(distinct (t1.c1)%5 order by (t1.c1)%5) from ft4 t1 full join ft5 t2 on (t1.c1 = t2.c1) where t1.c1 < 20 or (t1.c1 is null and t2.c1 < 5) group by (t2.c1)%3 order by 1;
--Testcase 184:
select array_agg(distinct (t1.c1)%5 order by (t1.c1)%5) from ft4 t1 full join ft5 t2 on (t1.c1 = t2.c1) where t1.c1 < 20 or (t1.c1 is null and t2.c1 < 5) group by (t2.c1)%3 order by 1;

--Testcase 185:
explain (verbose, costs off)
select array_agg(distinct (t1.c1)%5 order by (t1.c1)%5 desc nulls last) from ft4 t1 full join ft5 t2 on (t1.c1 = t2.c1) where t1.c1 < 20 or (t1.c1 is null and t2.c1 < 5) group by (t2.c1)%3 order by 1;
--Testcase 186:
select array_agg(distinct (t1.c1)%5 order by (t1.c1)%5 desc nulls last) from ft4 t1 full join ft5 t2 on (t1.c1 = t2.c1) where t1.c1 < 20 or (t1.c1 is null and t2.c1 < 5) group by (t2.c1)%3 order by 1;

-- FILTER within aggregate
--Testcase 187:
explain (verbose, costs off)
select sum(c1) filter (where c1 < 100 and c2 > 5) from ft1 group by c2 order by 1 nulls last;
--Testcase 188:
select sum(c1) filter (where c1 < 100 and c2 > 5) from ft1 group by c2 order by 1 nulls last;

-- DISTINCT, ORDER BY and FILTER within aggregate
--Testcase 189:
explain (verbose, costs off)
select sum(c1%3), sum(distinct c1%3 order by c1%3) filter (where c1%3 < 2), c2 from ft1 where c2 = 6 group by c2;
--Testcase 190:
select sum(c1%3), sum(distinct c1%3 order by c1%3) filter (where c1%3 < 2), c2 from ft1 where c2 = 6 group by c2;

-- Outer query is aggregation query
--Testcase 191:
explain (verbose, costs off)
select distinct (select count(*) filter (where t2.c2 = 6 and t2.c1 < 10) from ft1 t1 where t1.c1 = 6) from ft2 t2 where t2.c2 % 6 = 0 order by 1;
--Testcase 192:
select distinct (select count(*) filter (where t2.c2 = 6 and t2.c1 < 10) from ft1 t1 where t1.c1 = 6) from ft2 t2 where t2.c2 % 6 = 0 order by 1;
-- Inner query is aggregation query
--Testcase 193:
explain (verbose, costs off)
select distinct (select count(t1.c1) filter (where t2.c2 = 6 and t2.c1 < 10) from ft1 t1 where t1.c1 = 6) from ft2 t2 where t2.c2 % 6 = 0 order by 1;
--Testcase 194:
select distinct (select count(t1.c1) filter (where t2.c2 = 6 and t2.c1 < 10) from ft1 t1 where t1.c1 = 6) from ft2 t2 where t2.c2 % 6 = 0 order by 1;

-- Aggregate not pushed down as FILTER condition is not pushable
--Testcase 195:
explain (verbose, costs off)
select sum(c1) filter (where (c1 / c1) * random() <= 1) from ft1 group by c2 order by 1;
--Testcase 196:
explain (verbose, costs off)
select sum(c2) filter (where c2 in (select c2 from ft1 where c2 < 5)) from ft1;

-- Ordered-sets within aggregate
--Testcase 197:
explain (verbose, costs off)
select c2, rank('10'::varchar) within group (order by c6), percentile_cont(c2/10::numeric) within group (order by c1) from ft1 where c2 < 10 group by c2 having percentile_cont(c2/10::numeric) within group (order by c1) < 500 order by c2;
--Testcase 198:
select c2, rank('10'::varchar) within group (order by c6), percentile_cont(c2/10::numeric) within group (order by c1) from ft1 where c2 < 10 group by c2 having percentile_cont(c2/10::numeric) within group (order by c1) < 500 order by c2;

-- Using multiple arguments within aggregates
--Testcase 199:
explain (verbose, costs off)
select c1, rank(c1, c2) within group (order by c1, c2) from ft1 group by c1, c2 having c1 = 6 order by 1;
--Testcase 200:
select c1, rank(c1, c2) within group (order by c1, c2) from ft1 group by c1, c2 having c1 = 6 order by 1;

-- User defined function for user defined aggregate, VARIADIC
--Testcase 522:
create function least_accum(anyelement, variadic anyarray)
returns anyelement language sql as
  'select least($1, min($2[i])) from generate_subscripts($2,1) g(i)';
--Testcase 523:
create aggregate least_agg(variadic items anyarray) (
  stype = anyelement, sfunc = least_accum
);

-- Disable hash aggregation for plan stability.
--Testcase 786:
set enable_hashagg to false;

-- Not pushed down due to user defined aggregate
--Testcase 524:
explain (verbose, costs off)
select c2, least_agg(c1) from ft1 group by c2 order by c2;

-- Add function and aggregate into extension
--alter extension postgres_fdw add function least_accum(anyelement, variadic anyarray);
--alter extension postgres_fdw add aggregate least_agg(variadic items anyarray);
--alter server loopback options (set extensions 'postgres_fdw');

-- Now aggregate will be pushed.  Aggregate will display VARIADIC argument.
--Testcase 525:
explain (verbose, costs off)
select c2, least_agg(c1) from ft1 where c2 < 100 group by c2 order by c2;
--Testcase 526:
select c2, least_agg(c1) from ft1 where c2 < 100 group by c2 order by c2;

-- Remove function and aggregate from extension
--alter extension postgres_fdw drop function least_accum(anyelement, variadic anyarray);
--alter extension postgres_fdw drop aggregate least_agg(variadic items anyarray);
--alter server loopback options (set extensions 'postgres_fdw');

-- Not pushed down as we have dropped objects from extension.
--Testcase 527:
explain (verbose, costs off)
select c2, least_agg(c1) from ft1 group by c2 order by c2;

-- Cleanup
--Testcase 787:
reset enable_hashagg;
--Testcase 528:
drop aggregate least_agg(variadic items anyarray);
--Testcase 529:
drop function least_accum(anyelement, variadic anyarray);


-- Testing USING OPERATOR() in ORDER BY within aggregate.
-- For this, we need user defined operators along with operator family and
-- operator class.  Create those and then add them in extension.  Note that
-- user defined objects are considered unshippable unless they are part of
-- the extension.
--Testcase 530:
create operator public.<^ (
 leftarg = int4,
 rightarg = int4,
 procedure = int4eq
);

--Testcase 531:
create operator public.=^ (
 leftarg = int4,
 rightarg = int4,
 procedure = int4lt
);

--Testcase 532:
create operator public.>^ (
 leftarg = int4,
 rightarg = int4,
 procedure = int4gt
);

--Testcase 533:
create operator family my_op_family using btree;

--Testcase 534:
create function my_op_cmp(a int, b int) returns int as
  $$begin return btint4cmp(a, b); end $$ language plpgsql;

--Testcase 535:
create operator class my_op_class for type int using btree family my_op_family as
 operator 1 public.<^,
 operator 3 public.=^,
 operator 5 public.>^,
 function 1 my_op_cmp(int, int);

-- This will not be pushed as user defined sort operator is not part of the
-- extension yet.
--Testcase 536:
explain (verbose, costs off)
select array_agg(c1 order by c1 using operator(public.<^)) from ft2 where c2 = 6 and c1 < 100 group by c2;

-- Update local stats on ft2
--ANALYZE ft2;

-- Add into extension
--Testcase 788:
alter extension sqlite_fdw add operator class my_op_class using btree;
--Testcase 789:
alter extension sqlite_fdw add function my_op_cmp(a int, b int);
--Testcase 790:
alter extension sqlite_fdw add operator family my_op_family using btree;
--Testcase 791:
alter extension sqlite_fdw add operator public.<^(int, int);
--Testcase 792:
alter extension sqlite_fdw add operator public.=^(int, int);
--Testcase 793:
alter extension sqlite_fdw add operator public.>^(int, int);
--alter server loopback options (set extensions 'postgres_fdw');

-- Now this will be pushed as sort operator is part of the extension.
--Testcase 537:
explain (verbose, costs off)
select array_agg(c1 order by c1 using operator(public.<^)) from ft2 where c2 = 6 and c1 < 100 group by c2;
--Testcase 538:
select array_agg(c1 order by c1 using operator(public.<^)) from ft2 where c2 = 6 and c1 < 100 group by c2;

-- Remove from extension
--Testcase 794:
alter extension sqlite_fdw drop operator class my_op_class using btree;
--Testcase 795:
alter extension sqlite_fdw drop function my_op_cmp(a int, b int);
--Testcase 796:
alter extension sqlite_fdw drop operator family my_op_family using btree;
--Testcase 797:
alter extension sqlite_fdw drop operator public.<^(int, int);
--Testcase 798:
alter extension sqlite_fdw drop operator public.=^(int, int);
--Testcase 799:
alter extension sqlite_fdw drop operator public.>^(int, int);
--alter server loopback options (set extensions 'postgres_fdw');

-- This will not be pushed as sort operator is now removed from the extension.
--Testcase 539:
explain (verbose, costs off)
select array_agg(c1 order by c1 using operator(public.<^)) from ft2 where c2 = 6 and c1 < 100 group by c2;

-- Cleanup
--Testcase 540:
drop operator class my_op_class using btree;
--Testcase 541:
drop function my_op_cmp(a int, b int);
--Testcase 542:
drop operator family my_op_family using btree;
--Testcase 543:
drop operator public.>^(int, int);
--Testcase 544:
drop operator public.=^(int, int);
--Testcase 545:
drop operator public.<^(int, int);

-- Input relation to aggregate push down hook is not safe to pushdown and thus
-- the aggregate cannot be pushed down to foreign server.
--Testcase 201:
explain (verbose, costs off)
select count(t1.c3) from ft2 t1 left join ft2 t2 on (t1.c1 = random() * t2.c2);

-- Subquery in FROM clause having aggregate
--Testcase 202:
explain (verbose, costs off)
select count(*), x.b from ft1, (select c2 a, sum(c1) b from ft1 group by c2) x where ft1.c2 = x.a group by x.b order by 1, 2;
--Testcase 203:
select count(*), x.b from ft1, (select c2 a, sum(c1) b from ft1 group by c2) x where ft1.c2 = x.a group by x.b order by 1, 2;

-- FULL join with IS NULL check in HAVING
--Testcase 204:
explain (verbose, costs off)
select avg(t1.c1), sum(t2.c1) from ft4 t1 full join ft5 t2 on (t1.c1 = t2.c1) group by t2.c1 having (avg(t1.c1) is null and sum(t2.c1) < 10) or sum(t2.c1) is null order by 1 nulls last, 2;
--Testcase 205:
select avg(t1.c1), sum(t2.c1) from ft4 t1 full join ft5 t2 on (t1.c1 = t2.c1) group by t2.c1 having (avg(t1.c1) is null and sum(t2.c1) < 10) or sum(t2.c1) is null order by 1 nulls last, 2;

-- Aggregate over FULL join needing to deparse the joining relations as
-- subqueries.
--Testcase 206:
explain (verbose, costs off)
select count(*), sum(t1.c1), avg(t2.c1) from (select c1 from ft4 where c1 between 50 and 60) t1 full join (select c1 from ft5 where c1 between 50 and 60) t2 on (t1.c1 = t2.c1);
--Testcase 207:
select count(*), sum(t1.c1), avg(t2.c1) from (select c1 from ft4 where c1 between 50 and 60) t1 full join (select c1 from ft5 where c1 between 50 and 60) t2 on (t1.c1 = t2.c1);

-- ORDER BY expression is part of the target list but not pushed down to
-- foreign server.
--Testcase 208:
explain (verbose, costs off)
select sum(c2) * (random() <= 1)::int as sum from ft1 order by 1;
--Testcase 209:
select sum(c2) * (random() <= 1)::int as sum from ft1 order by 1;

-- LATERAL join, with parameterization
--Testcase 800:
set enable_hashagg to false;
--Testcase 210:
explain (verbose, costs off)
select c2, sum from "S 1"."T 1" t1, lateral (select sum(t2.c1 + t1."C 1") sum from ft2 t2 group by t2.c1) qry where t1.c2 * 2 = qry.sum and t1.c2 < 3 and t1."C 1" < 100 order by 1;
--Testcase 211:
select c2, sum from "S 1"."T 1" t1, lateral (select sum(t2.c1 + t1."C 1") sum from ft2 t2 group by t2.c1) qry where t1.c2 * 2 = qry.sum and t1.c2 < 3 and t1."C 1" < 100 order by 1;
--Testcase 801:
reset enable_hashagg;

-- bug #15613: bad plan for foreign table scan with lateral reference
--Testcase 546:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT ref_0.c2, subq_1.*
FROM
    "S 1"."T 1" AS ref_0,
    LATERAL (
        SELECT ref_0."C 1" c1, subq_0.*
        FROM (SELECT ref_0.c2, ref_1.c3
              FROM ft1 AS ref_1) AS subq_0
             RIGHT JOIN ft2 AS ref_3 ON (subq_0.c3 = ref_3.c3)
    ) AS subq_1
WHERE ref_0."C 1" < 10 AND subq_1.c3 = '00001'
ORDER BY ref_0."C 1";

--Testcase 547:
SELECT ref_0.c2, subq_1.*
FROM
    "S 1"."T 1" AS ref_0,
    LATERAL (
        SELECT ref_0."C 1" c1, subq_0.*
        FROM (SELECT ref_0.c2, ref_1.c3
              FROM ft1 AS ref_1) AS subq_0
             RIGHT JOIN ft2 AS ref_3 ON (subq_0.c3 = ref_3.c3)
    ) AS subq_1
WHERE ref_0."C 1" < 10 AND subq_1.c3 = '00001'
ORDER BY ref_0."C 1";

-- Check with placeHolderVars
--Testcase 212:
explain (verbose, costs off)
select sum(q.a), count(q.b) from ft4 left join (select 13, avg(ft1.c1), sum(ft2.c1) from ft1 right join ft2 on (ft1.c1 = ft2.c1)) q(a, b, c) on (ft4.c1 <= q.b);
--Testcase 213:
select sum(q.a), count(q.b) from ft4 left join (select 13, avg(ft1.c1), sum(ft2.c1) from ft1 right join ft2 on (ft1.c1 = ft2.c1)) q(a, b, c) on (ft4.c1 <= q.b);


-- Not supported cases
-- Grouping sets
--Testcase 214:
explain (verbose, costs off)
select c2, sum(c1) from ft1 where c2 < 3 group by rollup(c2) order by 1 nulls last;
--Testcase 215:
select c2, sum(c1) from ft1 where c2 < 3 group by rollup(c2) order by 1 nulls last;
--Testcase 216:
explain (verbose, costs off)
select c2, sum(c1) from ft1 where c2 < 3 group by cube(c2) order by 1 nulls last;
--Testcase 217:
select c2, sum(c1) from ft1 where c2 < 3 group by cube(c2) order by 1 nulls last;
--Testcase 218:
explain (verbose, costs off)
select c2, c6, sum(c1) from ft1 where c2 < 3 group by grouping sets(c2, c6) order by 1 nulls last, 2 nulls last;
--Testcase 219:
select c2, c6, sum(c1) from ft1 where c2 < 3 group by grouping sets(c2, c6) order by 1 nulls last, 2 nulls last;
--Testcase 220:
explain (verbose, costs off)
select c2, sum(c1), grouping(c2) from ft1 where c2 < 3 group by c2 order by 1 nulls last;
--Testcase 221:
select c2, sum(c1), grouping(c2) from ft1 where c2 < 3 group by c2 order by 1 nulls last;

-- DISTINCT itself is not pushed down, whereas underneath aggregate is pushed
--Testcase 222:
explain (verbose, costs off)
select distinct sum(c1)/1000 s from ft2 where c2 < 6 group by c2 order by 1;
--Testcase 223:
select distinct sum(c1)/1000 s from ft2 where c2 < 6 group by c2 order by 1;

-- WindowAgg
--Testcase 224:
explain (verbose, costs off)
select c2, sum(c2), count(c2) over (partition by c2%2) from ft2 where c2 < 10 group by c2 order by 1;
--Testcase 225:
select c2, sum(c2), count(c2) over (partition by c2%2) from ft2 where c2 < 10 group by c2 order by 1;
--Testcase 226:
explain (verbose, costs off)
select c2, array_agg(c2) over (partition by c2%2 order by c2 desc) from ft1 where c2 < 10 group by c2 order by 1;
--Testcase 227:
select c2, array_agg(c2) over (partition by c2%2 order by c2 desc) from ft1 where c2 < 10 group by c2 order by 1;
--Testcase 228:
explain (verbose, costs off)
select c2, array_agg(c2) over (partition by c2%2 order by c2 range between current row and unbounded following) from ft1 where c2 < 10 group by c2 order by 1;
--Testcase 229:
select c2, array_agg(c2) over (partition by c2%2 order by c2 range between current row and unbounded following) from ft1 where c2 < 10 group by c2 order by 1;


-- ===================================================================
-- parameterized queries
-- ===================================================================
-- simple join
--Testcase 230:
PREPARE st1(int, int) AS SELECT t1.c3, t2.c3 FROM ft1 t1, ft2 t2 WHERE t1.c1 = $1 AND t2.c1 = $2;
--Testcase 231:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st1(1, 2);
--Testcase 232:
EXECUTE st1(1, 1);
--Testcase 233:
EXECUTE st1(101, 101);
-- subquery using stable function (can't be sent to remote)
--Testcase 234:
PREPARE st2(int) AS SELECT * FROM ft1 t1 WHERE t1.c1 < $2 AND t1.c3 IN (SELECT c3 FROM ft2 t2 WHERE c1 > $1 AND date(c4) = '1970-01-17'::date) ORDER BY c1;
--Testcase 235:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st2(10, 20);
--Testcase 236:
EXECUTE st2(10, 20);
--Testcase 237:
EXECUTE st2(101, 121);
-- subquery using immutable function (can be sent to remote)
--Testcase 238:
PREPARE st3(int) AS SELECT * FROM ft1 t1 WHERE t1.c1 < $2 AND t1.c3 IN (SELECT c3 FROM ft2 t2 WHERE c1 > $1 AND date(c5) = '1970-01-17'::date) ORDER BY c1;
--Testcase 239:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st3(10, 20);
--Testcase 240:
EXECUTE st3(10, 20);
--Testcase 241:
EXECUTE st3(20, 30);
-- custom plan should be chosen initially
--Testcase 242:
PREPARE st4(int) AS SELECT * FROM ft1 t1 WHERE t1.c1 = $1;
--Testcase 243:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st4(1);
--Testcase 244:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st4(1);
--Testcase 245:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st4(1);
--Testcase 246:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st4(1);
--Testcase 247:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st4(1);
-- once we try it enough times, should switch to generic plan
--Testcase 248:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st4(1);
-- value of $1 should not be sent to remote
--Testcase 249:
PREPARE st5(text,int) AS SELECT * FROM ft1 t1 WHERE c8 = $1 and c1 = $2;
--Testcase 250:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st5('foo', 1);
--Testcase 251:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st5('foo', 1);
--Testcase 252:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st5('foo', 1);
--Testcase 253:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st5('foo', 1);
--Testcase 254:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st5('foo', 1);
--Testcase 255:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st5('foo', 1);
--Testcase 256:
EXECUTE st5('foo', 1);

-- altering FDW options requires replanning
--Testcase 257:
PREPARE st6 AS SELECT * FROM ft1 t1 WHERE t1.c1 = t1.c2;
--Testcase 258:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st6;
--Testcase 259:
PREPARE st7 AS INSERT INTO ft1 (c1,c2,c3) VALUES (1001,101,'foo');
--Testcase 260:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st7;
--Testcase 548:
INSERT INTO "S 1"."T 0" SELECT * FROM "S 1"."T 1";
--Testcase 802:
ALTER FOREIGN TABLE ft1 OPTIONS (SET table 'T 0');
--Testcase 261:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st6;
--Testcase 262:
EXECUTE st6;
--Testcase 263:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st7;
--Testcase 803:
ALTER FOREIGN TABLE ft1 OPTIONS (SET table 'T 1');

--Testcase 549:
PREPARE st8 AS SELECT count(c3) FROM ft1 t1 WHERE t1.c1 === t1.c2;
--Testcase 550:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st8;
--ALTER SERVER loopback OPTIONS (DROP extensions);
--Testcase 551:
EXPLAIN (VERBOSE, COSTS OFF) EXECUTE st8;
--Testcase 552:
EXECUTE st8;
--ALTER SERVER loopback OPTIONS (ADD extensions 'postgres_fdw');
-- cleanup
DEALLOCATE st1;
DEALLOCATE st2;
DEALLOCATE st3;
DEALLOCATE st4;
DEALLOCATE st5;
DEALLOCATE st6;
DEALLOCATE st7;
DEALLOCATE st8;

-- System columns, except ctid and oid, should not be sent to remote
--Testcase 264:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM ft1 t1 WHERE t1.tableoid = 'pg_class'::regclass LIMIT 1;
--Testcase 265:
SELECT * FROM ft1 t1 WHERE t1.tableoid = 'ft1'::regclass LIMIT 1;
--Testcase 266:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT tableoid::regclass, * FROM ft1 t1 LIMIT 1;
--Testcase 267:
SELECT tableoid::regclass, * FROM ft1 t1 LIMIT 1;
--Testcase 268:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM ft1 t1 WHERE t1.ctid = '(0,2)';
--Testcase 553:
SELECT * FROM ft1 t1 WHERE t1.ctid = '(0,2)';
--Testcase 554:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT ctid, * FROM ft1 t1 LIMIT 1;
--Testcase 271:
SELECT ctid, * FROM ft1 t1 LIMIT 1;

-- ===================================================================
-- used in PL/pgSQL function
-- ===================================================================
--Testcase 555:
CREATE OR REPLACE FUNCTION f_test(p_c1 int) RETURNS int AS $$
DECLARE
	v_c1 int;
BEGIN
--Testcase 556:
    SELECT c1 INTO v_c1 FROM ft1 WHERE c1 = p_c1 LIMIT 1;
    PERFORM c1 FROM ft1 WHERE c1 = p_c1 AND p_c1 = v_c1 LIMIT 1;
    RETURN v_c1;
END;
$$ LANGUAGE plpgsql;
--Testcase 272:
SELECT f_test(100);
--Testcase 557:
DROP FUNCTION f_test(int);

-- ===================================================================
-- REINDEX
-- ===================================================================
-- remote table is not created here
--Testcase 804:
CREATE FOREIGN TABLE reindex_foreign (c1 int, c2 int)
  SERVER sqlite_svr2 OPTIONS (table 'reindex_local');
REINDEX TABLE reindex_foreign; -- error
REINDEX TABLE CONCURRENTLY reindex_foreign; -- error
--Testcase 805:
DROP FOREIGN TABLE reindex_foreign;
-- partitions and foreign tables
--Testcase 806:
CREATE TABLE reind_fdw_parent (c1 int) PARTITION BY RANGE (c1);
--Testcase 807:
CREATE TABLE reind_fdw_0_10 PARTITION OF reind_fdw_parent
  FOR VALUES FROM (0) TO (10);
--Testcase 808:
CREATE FOREIGN TABLE reind_fdw_10_20 PARTITION OF reind_fdw_parent
  FOR VALUES FROM (10) TO (20)
  SERVER sqlite_svr OPTIONS (table 'reind_local_10_20');
REINDEX TABLE reind_fdw_parent; -- ok
REINDEX TABLE CONCURRENTLY reind_fdw_parent; -- ok
--Testcase 809:
DROP TABLE reind_fdw_parent;

-- ===================================================================
-- conversion error
-- ===================================================================
--Testcase 810:
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 TYPE int;
--Testcase 273:
SELECT * FROM ft1 ftx(x1,x2,x3,x4,x5,x6,x7,x8) WHERE x1 = 1;
--Testcase 274:
SELECT  ftx.x1,  ft2.c2, ftx.x8 FROM ft1 ftx(x1,x2,x3,x4,x5,x6,x7,x8), ft2 WHERE ftx.x1 = ft2.c1 AND ftx.x1 = 1;
--Testcase 275:
SELECT  ftx.x1,  ft2.c2, ftx FROM ft1 ftx(x1,x2,x3,x4,x5,x6,x7,x8), ft2 WHERE ftx.x1 = ft2.c1 AND ftx.x1 = 1;
--Testcase 276:
SELECT sum(c2), array_agg(c8) FROM ft1 GROUP BY c8;
--Testcase 811:
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 TYPE text;

-- ===================================================================
-- subtransaction
--  + local/remote error doesn't break cursor
-- ===================================================================
BEGIN;
DECLARE c CURSOR FOR SELECT * FROM ft1 ORDER BY c1;
--Testcase 277:
FETCH c;
SAVEPOINT s;
ERROR OUT;          -- ERROR
ROLLBACK TO s;
--Testcase 278:
FETCH c;
SAVEPOINT s;
--Testcase 279:
SELECT * FROM ft1 WHERE 1 / (c1 - 1) > 0;  -- ERROR
ROLLBACK TO s;
--Testcase 280:
FETCH c;
--Testcase 281:
SELECT * FROM ft1 ORDER BY c1 LIMIT 1;
COMMIT;

-- ===================================================================
-- test handling of collations
-- ===================================================================
--Testcase 558:
create foreign table ft3 (f1 text collate "C", f2 text, f3 varchar(10)) server sqlite_svr;

-- can be sent to remote
--Testcase 559:
explain (verbose, costs off) select * from ft3 where f1 = 'foo';
--Testcase 560:
explain (verbose, costs off) select * from ft3 where f1 COLLATE "C" = 'foo';
--Testcase 561:
explain (verbose, costs off) select * from ft3 where f2 = 'foo';
--Testcase 562:
explain (verbose, costs off) select * from ft3 where f3 = 'foo';
--Testcase 563:
explain (verbose, costs off) select * from ft3 f, loct3 l
  where f.f3 = l.f3 and l.f1 = 'foo';
-- can't be sent to remote
--Testcase 564:
explain (verbose, costs off) select * from ft3 where f1 COLLATE "POSIX" = 'foo';
--Testcase 565:
explain (verbose, costs off) select * from ft3 where f1 = 'foo' COLLATE "C";
--Testcase 566:
explain (verbose, costs off) select * from ft3 where f2 COLLATE "C" = 'foo';
--Testcase 567:
explain (verbose, costs off) select * from ft3 where f2 = 'foo' COLLATE "C";
--Testcase 568:
explain (verbose, costs off) select * from ft3 f, loct3 l
  where f.f3 = l.f3 COLLATE "POSIX" and l.f1 = 'foo';

-- ===================================================================
-- test writable foreign table stuff
-- ===================================================================
--Testcase 282:
EXPLAIN (verbose, costs off)
INSERT INTO ft2 (c1,c2,c3) SELECT c1+1000,c2+100, c3 || c3 FROM ft2 LIMIT 20;
--Testcase 283:
INSERT INTO ft2 (c1,c2,c3) SELECT c1+1000,c2+100, c3 || c3 FROM ft2 LIMIT 20;
--Testcase 284:
INSERT INTO ft2 (c1,c2,c3) VALUES (1101,201,'aaa'), (1102,202,'bbb'), (1103,203,'ccc');
--Testcase 285:
SELECT * FROM ft2 WHERE c1 >= 1101;
--Testcase 286:
INSERT INTO ft2 (c1,c2,c3) VALUES (1104,204,'ddd'), (1105,205,'eee');
--Testcase 287:
EXPLAIN (verbose, costs off)
UPDATE ft2 SET c2 = c2 + 300, c3 = c3 || '_update3' WHERE c1 % 10 = 3;              -- can be pushed down
--Testcase 288:
UPDATE ft2 SET c2 = c2 + 300, c3 = c3 || '_update3' WHERE c1 % 10 = 3;
--Testcase 289:
EXPLAIN (verbose, costs off)
UPDATE ft2 SET c2 = c2 + 400, c3 = c3 || '_update7' WHERE c1 % 10 = 7;  -- can be pushed down
--Testcase 290:
UPDATE ft2 SET c2 = c2 + 400, c3 = c3 || '_update7' WHERE c1 % 10 = 7;
--Testcase 291:
SELECT * FROM ft2 WHERE c1 % 10 = 7;
--Testcase 292:
EXPLAIN (verbose, costs off)
UPDATE ft2 SET c2 = ft2.c2 + 500, c3 = ft2.c3 || '_update9', c7 = DEFAULT
  FROM ft1 WHERE ft1.c1 = ft2.c2 AND ft1.c1 % 10 = 9;                               -- can be pushed down
--Testcase 293:
UPDATE ft2 SET c2 = ft2.c2 + 500, c3 = ft2.c3 || '_update9', c7 = DEFAULT
  FROM ft1 WHERE ft1.c1 = ft2.c2 AND ft1.c1 % 10 = 9;
--Testcase 294:
EXPLAIN (verbose, costs off)
  DELETE FROM ft2 WHERE c1 % 10 = 5;                               -- can be pushed down
--Testcase 295:
SELECT c1, c4 FROM ft2 WHERE c1 % 10 = 5;
--Testcase 569:
DELETE FROM ft2 WHERE c1 % 10 = 5;
--Testcase 297:
EXPLAIN (verbose, costs off)
DELETE FROM ft2 USING ft1 WHERE ft1.c1 = ft2.c2 AND ft1.c1 % 10 = 2;                -- can be pushed down
--Testcase 298:
DELETE FROM ft2 USING ft1 WHERE ft1.c1 = ft2.c2 AND ft1.c1 % 10 = 2;
--Testcase 299:
SELECT c1,c2,c3,c4 FROM ft2 ORDER BY c1;
--Testcase 300:
EXPLAIN (verbose, costs off)
INSERT INTO ft2 (c1,c2,c3) VALUES (1200,999,'foo');
--Testcase 301:
INSERT INTO ft2 (c1,c2,c3) VALUES (1200,999,'foo');
--Testcase 302:
EXPLAIN (verbose, costs off)
UPDATE ft2 SET c3 = 'bar' WHERE c1 = 1200;             -- can be pushed down
--Testcase 303:
UPDATE ft2 SET c3 = 'bar' WHERE c1 = 1200;
--Testcase 304:
EXPLAIN (verbose, costs off)
DELETE FROM ft2 WHERE c1 = 1200;                       -- can be pushed down
--Testcase 305:
DELETE FROM ft2 WHERE c1 = 1200;

-- Test UPDATE/DELETE on a three-table join
--Testcase 306:
INSERT INTO ft2 (c1,c2,c3)
  SELECT id, id - 1200, to_char(id, 'FM00000') FROM generate_series(1201, 1300) id;
--Testcase 307:
EXPLAIN (verbose, costs off)
UPDATE ft2 SET c3 = 'foo'
  FROM ft4 INNER JOIN ft5 ON (ft4.c1 = ft5.c1)
  WHERE ft2.c1 > 1200 AND ft2.c2 = ft4.c1;       -- can be pushed down
--Testcase 308:
UPDATE ft2 SET c3 = 'foo'
  FROM ft4 INNER JOIN ft5 ON (ft4.c1 = ft5.c1)
  WHERE ft2.c1 > 1200 AND ft2.c2 = ft4.c1;
--Testcase 309:
SELECT ft2, ft2.*, ft4, ft4.*
  FROM ft2 INNER JOIN ft4 ON (ft2.c1 > 1200 AND ft2.c2 = ft4.c1)
  INNER JOIN ft5 ON (ft4.c1 = ft5.c1);
--Testcase 310:
EXPLAIN (verbose, costs off)
DELETE FROM ft2
  USING ft4 LEFT JOIN ft5 ON (ft4.c1 = ft5.c1)
  WHERE ft2.c1 > 1200 AND ft2.c1 % 10 = 0 AND ft2.c2 = ft4.c1;                          -- can be pushed down
--Testcase 311:
SELECT 100 FROM ft2, ft4 LEFT JOIN ft5 ON (ft4.c1 = ft5.c1)
  WHERE ft2.c1 > 1200 AND ft2.c1 % 10 = 0 AND ft2.c2 = ft4.c1;

--Testcase 570:
DELETE FROM ft2
  USING ft4 LEFT JOIN ft5 ON (ft4.c1 = ft5.c1)
  WHERE ft2.c1 > 1200 AND ft2.c1 % 10 = 0 AND ft2.c2 = ft4.c1;
--Testcase 312:
DELETE FROM ft2 WHERE ft2.c1 > 1200;

-- Test UPDATE with a MULTIEXPR sub-select
-- (maybe someday this'll be remotely executable, but not today)
--Testcase 571:
EXPLAIN (verbose, costs off)
UPDATE ft2 AS target SET (c2, c7) = (
    SELECT c2 * 10, c7
        FROM ft2 AS src
        WHERE target.c1 = src.c1
) WHERE c1 > 1100;
--Testcase 572:
UPDATE ft2 AS target SET (c2, c7) = (
    SELECT c2 * 10, c7
        FROM ft2 AS src
        WHERE target.c1 = src.c1
) WHERE c1 > 1100;

--Testcase 573:
UPDATE ft2 AS target SET (c2) = (
    SELECT c2 / 10
        FROM ft2 AS src
        WHERE target.c1 = src.c1
) WHERE c1 > 1100;

-- Test UPDATE involving a join that can be pushed down,
-- but a SET clause that can't be
--Testcase 812:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE ft2 d SET c2 = CASE WHEN random() >= 0 THEN d.c2 ELSE 0 END
  FROM ft2 AS t WHERE d.c1 = t.c1 AND d.c1 > 1000;
--Testcase 813:
UPDATE ft2 d SET c2 = CASE WHEN random() >= 0 THEN d.c2 ELSE 0 END
  FROM ft2 AS t WHERE d.c1 = t.c1 AND d.c1 > 1000;

-- Test UPDATE/DELETE with WHERE or JOIN/ON conditions containing
-- user-defined operators/functions
--ALTER SERVER loopback OPTIONS (DROP extensions);
--Testcase 574:
INSERT INTO ft2 (c1,c2,c3)
  SELECT id, id % 10, to_char(id, 'FM00000') FROM generate_series(2001, 2010) id;
--Testcase 575:
EXPLAIN (verbose, costs off)
UPDATE ft2 SET c3 = 'bar' WHERE sqlite_fdw_abs(c1) > 2000;            -- can't be pushed down
--Testcase 576:
UPDATE ft2 SET c3 = 'bar' WHERE sqlite_fdw_abs(c1) > 2000;
--Testcase 577:
SELECT * FROM ft2 WHERE sqlite_fdw_abs(c1) > 2000;
--Testcase 578:
EXPLAIN (verbose, costs off)
UPDATE ft2 SET c3 = 'baz'
  FROM ft4 INNER JOIN ft5 ON (ft4.c1 = ft5.c1)
  WHERE ft2.c1 > 2000 AND ft2.c2 === ft4.c1;                                                    -- can't be pushed down
--Testcase 579:
UPDATE ft2 SET c3 = 'baz'
  FROM ft4 INNER JOIN ft5 ON (ft4.c1 = ft5.c1)
  WHERE ft2.c1 > 2000 AND ft2.c2 === ft4.c1;
--Testcase 580:
SELECT ft2.*, ft4.*, ft5.* 
  FROM ft2, ft4 INNER JOIN ft5 ON (ft4.c1 = ft5.c1)
  WHERE ft2.c1 > 2000 AND ft2.c2 === ft4.c1;

--Testcase 581:
EXPLAIN (verbose, costs off)
DELETE FROM ft2
  USING ft4 INNER JOIN ft5 ON (ft4.c1 === ft5.c1)
  WHERE ft2.c1 > 2000 AND ft2.c2 = ft4.c1;       -- can't be pushed down

--Testcase 582:
SELECT ft2.c1, ft2.c2, ft2.c3 FROM ft2, ft4 INNER JOIN ft5 ON (ft4.c1 === ft5.c1)
  WHERE ft2.c1 > 2000 AND ft2.c2 = ft4.c1;       -- can't be pushed down

--Testcase 583:
DELETE FROM ft2
  USING ft4 INNER JOIN ft5 ON (ft4.c1 === ft5.c1)
  WHERE ft2.c1 > 2000 AND ft2.c2 = ft4.c1;

--Testcase 584:
DELETE FROM ft2 WHERE ft2.c1 > 2000;
--ALTER SERVER loopback OPTIONS (ADD extensions 'postgres_fdw');

-- Test that trigger on remote table works as expected
--Testcase 585:
CREATE OR REPLACE FUNCTION "S 1".F_BRTRIG() RETURNS trigger AS $$
BEGIN
    NEW.c3 = NEW.c3 || '_trig_update';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--Testcase 586:
CREATE TRIGGER t1_br_insert BEFORE INSERT OR UPDATE
    ON ft2 FOR EACH ROW EXECUTE PROCEDURE "S 1".F_BRTRIG();

--Testcase 313:
INSERT INTO ft2 (c1,c2,c3) VALUES (1208, 818, 'fff');
--Testcase 314:
SELECT * FROM ft2 WHERE c1 = 1208;
--Testcase 315:
INSERT INTO ft2 (c1,c2,c3,c6) VALUES (1218, 818, 'ggg', '(--;');
--Testcase 316:
SELECT * FROM ft2 WHERE c1 = 1218;
--Testcase 317:
UPDATE ft2 SET c2 = c2 + 600, c3 = c3 WHERE c1 % 10 = 8 AND c1 < 1200;
--Testcase 318:
SELECT * FROM ft2 WHERE c1 % 10 = 8 AND c1 < 1200;

-- Test errors thrown on remote side during update
-- create table in the remote server with check contraint
--Testcase 738:
CREATE FOREIGN TABLE ft1_constraint (
	c1 int OPTIONS (key 'true'),
	c2 int NOT NULL,
	c3 text,
	c4 timestamptz,
	c5 timestamp,
	c6 varchar(10),
	c7 char(10) default 'ft1',
	c8 text
) SERVER sqlite_svr OPTIONS (table 't1_constraint');
--Testcase 747:
INSERT INTO ft1_constraint SELECT * FROM ft1 ON CONFLICT DO NOTHING;
-- c2 must be greater than or equal to 0, so this case is ignored.
--Testcase 754:
INSERT INTO ft1_constraint(c1, c2) VALUES (2222, -2) ON CONFLICT DO NOTHING; -- ignore, do nothing
--Testcase 755:
SELECT c1, c2 FROM ft1_constraint WHERE c1 = 2222 or c2 = -2; -- empty result
--Testcase 748:
ALTER FOREIGN TABLE ft1 RENAME TO ft1_org;
--Testcase 749:
ALTER FOREIGN TABLE ft1_constraint RENAME TO ft1;
--Testcase 319:
INSERT INTO ft1(c1, c2) VALUES(11, 12);  -- duplicate key
--Testcase 320:
INSERT INTO ft1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO NOTHING; -- unsupported
--Testcase 321:
INSERT INTO ft1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO UPDATE SET c3 = 'ffg'; -- unsupported
--Testcase 743:
INSERT INTO ft1(c1, c2) VALUES(1111, -2);  -- c2positive
--Testcase 744:
UPDATE ft1 SET c2 = -c2 WHERE c1 = 1;  -- c2positive
--Testcase 750:
ALTER FOREIGN TABLE ft1 RENAME TO ft1_constraint;
--Testcase 751:
ALTER FOREIGN TABLE ft1_org RENAME TO ft1;

-- Test savepoint/rollback behavior
--Testcase 322:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
--Testcase 323:
select c2, count(*) from "S 1"."T 1" where c2 < 500 group by 1 order by 1;
begin;
--Testcase 324:
update ft2 set c2 = 42 where c2 = 0;
--Testcase 325:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
savepoint s1;
--Testcase 326:
update ft2 set c2 = 44 where c2 = 4;
--Testcase 327:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
release savepoint s1;
--Testcase 328:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
savepoint s2;
--Testcase 329:
update ft2 set c2 = 46 where c2 = 6;
--Testcase 330:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
rollback to savepoint s2;
--Testcase 331:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
release savepoint s2;
--Testcase 332:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
savepoint s3;
--Testcase 333:
--skip, does not support CHECK
--update ft2 set c2 = -2 where c2 = 42 and c1 = 10; -- fail on remote side
rollback to savepoint s3;
--Testcase 334:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
release savepoint s3;
--Testcase 335:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
-- none of the above is committed yet remotely
--Testcase 336:
select c2, count(*) from "S 1"."T 1" where c2 < 500 group by 1 order by 1;
commit;
--Testcase 337:
select c2, count(*) from ft2 where c2 < 500 group by 1 order by 1;
--Testcase 338:
select c2, count(*) from "S 1"."T 1" where c2 < 500 group by 1 order by 1;

--VACUUM ANALYZE "S 1"."T 1";

-- Above DMLs add data with c6 as NULL in ft1, so test ORDER BY NULLS LAST and NULLs
-- FIRST behavior here.
-- ORDER BY DESC NULLS LAST options
--Testcase 339:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 ORDER BY c6 DESC NULLS LAST, c1 OFFSET 795 LIMIT 10;
--Testcase 340:
SELECT * FROM ft1 ORDER BY c6 DESC NULLS LAST, c1 OFFSET 795  LIMIT 10;
-- ORDER BY DESC NULLS FIRST options
--Testcase 341:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 ORDER BY c6 DESC NULLS FIRST, c1 OFFSET 15 LIMIT 10;
--Testcase 342:
SELECT * FROM ft1 ORDER BY c6 DESC NULLS FIRST, c1 OFFSET 15 LIMIT 10;
-- ORDER BY ASC NULLS FIRST options
--Testcase 343:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM ft1 ORDER BY c6 ASC NULLS FIRST, c1 OFFSET 15 LIMIT 10;
--Testcase 344:
SELECT * FROM ft1 ORDER BY c6 ASC NULLS FIRST, c1 OFFSET 15 LIMIT 10;

-- ===================================================================
-- test check constraints
-- ===================================================================
--Testcase 752:
ALTER FOREIGN TABLE ft1 RENAME TO ft1_org;
--Testcase 753:
ALTER FOREIGN TABLE ft1_constraint RENAME TO ft1;
-- Consistent check constraints provide consistent results
--Testcase 814:
ALTER FOREIGN TABLE ft1 ADD CONSTRAINT ft1_c2positive CHECK (c2 >= 0);
--Testcase 587:
EXPLAIN (VERBOSE, COSTS OFF) SELECT count(*) FROM ft1 WHERE c2 < 0;
--Testcase 588:
SELECT count(*) FROM ft1 WHERE c2 < 0;
--Testcase 815:
SET constraint_exclusion = 'on';
--Testcase 589:
EXPLAIN (VERBOSE, COSTS OFF) SELECT count(*) FROM ft1 WHERE c2 < 0;
--Testcase 590:
SELECT count(*) FROM ft1 WHERE c2 < 0;
--Testcase 816:
RESET constraint_exclusion;
-- check constraint is enforced on the remote side, not locally
--Testcase 745:
INSERT INTO ft1(c1, c2) VALUES(1111, -2);  -- c2positive
--Testcase 746:
UPDATE ft1 SET c2 = -c2 WHERE c1 = 1;  -- c2positive
--Testcase 817:
ALTER FOREIGN TABLE ft1 DROP CONSTRAINT ft1_c2positive;

-- But inconsistent check constraints provide inconsistent results
--Testcase 818:
ALTER FOREIGN TABLE ft1 ADD CONSTRAINT ft1_c2negative CHECK (c2 < 0);
--Testcase 591:
EXPLAIN (VERBOSE, COSTS OFF) SELECT count(*) FROM ft1 WHERE c2 >= 0;
--Testcase 592:
SELECT count(*) FROM ft1 WHERE c2 >= 0;
--Testcase 819:
SET constraint_exclusion = 'on';
--Testcase 593:
EXPLAIN (VERBOSE, COSTS OFF) SELECT count(*) FROM ft1 WHERE c2 >= 0;
--Testcase 594:
SELECT count(*) FROM ft1 WHERE c2 >= 0;
--Testcase 820:
RESET constraint_exclusion;
-- local check constraint is not actually enforced
--Testcase 595:
INSERT INTO ft1(c1, c2) VALUES(1111, 2);
--Testcase 596:
UPDATE ft1 SET c2 = c2 + 1 WHERE c1 = 1;
--Testcase 821:
ALTER FOREIGN TABLE ft1 DROP CONSTRAINT ft1_c2negative;

-- ===================================================================
-- test WITH CHECK OPTION constraints
-- ===================================================================
--Testcase 597:
CREATE FUNCTION row_before_insupd_trigfunc() RETURNS trigger AS $$BEGIN NEW.a := NEW.a + 10; RETURN NEW; END$$ LANGUAGE plpgsql;

--Testcase 598:
CREATE FOREIGN TABLE foreign_tbl (a int OPTIONS (key 'true'), b int)
  SERVER sqlite_svr;
--Testcase 599:
CREATE TRIGGER row_before_insupd_trigger BEFORE INSERT OR UPDATE ON foreign_tbl FOR EACH ROW EXECUTE PROCEDURE row_before_insupd_trigfunc();
--Testcase 600:
CREATE VIEW rw_view AS SELECT * FROM foreign_tbl
  WHERE a < b WITH CHECK OPTION;
--Testcase 601:
\d+ rw_view

--Testcase 345:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view VALUES (0, 5);
--Testcase 602:
INSERT INTO rw_view VALUES (0, 5); -- should fail
--Testcase 603:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view VALUES (0, 15);
--Testcase 604:
INSERT INTO rw_view VALUES (0, 15); -- error
--Testcase 605:
SELECT * FROM foreign_tbl;

--Testcase 606:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET b = b + 5;
--Testcase 607:
UPDATE rw_view SET b = b + 5; -- should fail
--Testcase 608:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET b = b + 15;
--Testcase 609:
UPDATE rw_view SET b = b + 15; -- ok
--Testcase 610:
SELECT * FROM foreign_tbl;

--Testcase 611:
DROP FOREIGN TABLE foreign_tbl CASCADE;
--Testcase 612:
DROP TRIGGER row_before_insupd_trigger ON foreign_tbl;

-- test WCO for partitions

--Testcase 613:
CREATE FOREIGN TABLE foreign_tbl (a int OPTIONS (key 'true'), b int)
  SERVER sqlite_svr;
--Testcase 614:
CREATE TRIGGER row_before_insupd_trigger BEFORE INSERT OR UPDATE ON foreign_tbl FOR EACH ROW EXECUTE PROCEDURE row_before_insupd_trigfunc();

--Testcase 615:
CREATE TABLE parent_tbl (a int, b int) PARTITION BY RANGE(a);
--Testcase 822:
ALTER TABLE parent_tbl ATTACH PARTITION foreign_tbl FOR VALUES FROM (0) TO (100);

--Testcase 616:
CREATE VIEW rw_view AS SELECT * FROM parent_tbl
  WHERE a < b WITH CHECK OPTION;
--Testcase 617:
\d+ rw_view

--Testcase 618:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view VALUES (0, 5);
--Testcase 619:
INSERT INTO rw_view VALUES (0, 5); -- should fail
--Testcase 620:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view VALUES (0, 15);
--Testcase 621:
INSERT INTO rw_view VALUES (0, 15); -- ok
--Testcase 622:
SELECT * FROM foreign_tbl;

--Testcase 623:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET b = b + 5;
--Testcase 624:
UPDATE rw_view SET b = b + 5; -- should fail
--Testcase 625:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET b = b + 15;
--Testcase 626:
UPDATE rw_view SET b = b + 15; -- ok
--Testcase 627:
SELECT * FROM foreign_tbl;

--Testcase 628:
DROP TRIGGER row_before_insupd_trigger ON foreign_tbl;
--Testcase 629:
DROP FOREIGN TABLE foreign_tbl CASCADE;
--Testcase 630:
DROP TABLE parent_tbl CASCADE;

--Testcase 631:
DROP FUNCTION row_before_insupd_trigfunc;

-- ===================================================================
-- test serial columns (ie, sequence-based defaults)
-- ===================================================================
--Testcase 632:
create foreign table loc1 (f1 serial, f2 text, id integer options (key 'true'))
  server sqlite_svr;
--Testcase 633:
create foreign table rem1 (f1 serial, f2 text, id integer options (key 'true'))
  server sqlite_svr options(table 'loc1');
--Testcase 352:
select pg_catalog.setval('rem1_f1_seq', 10, false);
--Testcase 353:
insert into loc1(f2) values('hi');
--Testcase 634:
insert into rem1(f2) values('hi remote');
--Testcase 354:
insert into loc1(f2) values('bye');
--Testcase 635:
insert into rem1(f2) values('bye remote');
--Testcase 355:
select f1, f2 from loc1;
--Testcase 636:
select f1, f2 from rem1;

-- ===================================================================
-- test generated columns
-- ===================================================================
--Testcase 637:
create foreign table grem1 (
  a int options (key 'true'),
  b int generated always as (a * 2) stored)
  server sqlite_svr options(table 'grem1_post14');
--Testcase 638:
explain (verbose, costs off)
insert into grem1 (a) values (1), (2);
--Testcase 823:
insert into grem1 (a) values (1), (2);
--Testcase 639:
explain (verbose, costs off)
update grem1 set a = 22 where a = 2;
--Testcase 824:
update grem1 set a = 22 where a = 2;
--Testcase 640:
select * from grem1;
--Testcase 825:
delete from grem1;

-- -- test copy from
-- copy grem1 from stdin;
-- 1
-- 2
-- \.
-- select * from grem1;
-- delete from grem1;

-- test batch insert
--Testcase 826:
alter server sqlite_svr options (add batch_size '10');
--Testcase 827:
explain (verbose, costs off)
insert into grem1 (a) values (1), (2);
--Testcase 828:
insert into grem1 (a) values (1), (2);
--Testcase 829:
select * from grem1;
--Testcase 830:
delete from grem1;
--Testcase 831:
alter server sqlite_svr options (drop batch_size);

-- ===================================================================
-- test local triggers
-- ===================================================================

-- Trigger functions "borrowed" from triggers regress test.
--Testcase 641:
CREATE FUNCTION trigger_func() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
	RAISE NOTICE 'trigger_func(%) called: action = %, when = %, level = %',
		TG_ARGV[0], TG_OP, TG_WHEN, TG_LEVEL;
	RETURN NULL;
END;$$;

--Testcase 642:
CREATE TRIGGER trig_stmt_before BEFORE DELETE OR INSERT OR UPDATE ON rem1
	FOR EACH STATEMENT EXECUTE PROCEDURE trigger_func();
--Testcase 643:
CREATE TRIGGER trig_stmt_after AFTER DELETE OR INSERT OR UPDATE ON rem1
	FOR EACH STATEMENT EXECUTE PROCEDURE trigger_func();

--Testcase 644:
CREATE OR REPLACE FUNCTION trigger_data()  RETURNS trigger
LANGUAGE plpgsql AS $$

declare
	oldnew text[];
	relid text;
    argstr text;
begin

	relid := TG_relid::regclass;
	argstr := '';
	for i in 0 .. TG_nargs - 1 loop
		if i > 0 then
			argstr := argstr || ', ';
		end if;
		argstr := argstr || TG_argv[i];
	end loop;

    RAISE NOTICE '%(%) % % % ON %',
		tg_name, argstr, TG_when, TG_level, TG_OP, relid;
    oldnew := '{}'::text[];
	if TG_OP != 'INSERT' then
		oldnew := array_append(oldnew, format('OLD: %s', OLD));
	end if;

	if TG_OP != 'DELETE' then
		oldnew := array_append(oldnew, format('NEW: %s', NEW));
	end if;

    RAISE NOTICE '%', array_to_string(oldnew, ',');

	if TG_OP = 'DELETE' then
		return OLD;
	else
		return NEW;
	end if;
end;
$$;

-- Test basic functionality
--Testcase 645:
CREATE TRIGGER trig_row_before
BEFORE INSERT OR UPDATE OR DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 646:
CREATE TRIGGER trig_row_after
AFTER INSERT OR UPDATE OR DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 356:
delete from rem1;
--Testcase 357:
insert into rem1 values(1,'insert');
--Testcase 358:
update rem1 set f2  = 'update' where f1 = 1;
--Testcase 359:
update rem1 set f2 = f2 || f2;


-- cleanup
--Testcase 647:
DROP TRIGGER trig_row_before ON rem1;
--Testcase 648:
DROP TRIGGER trig_row_after ON rem1;
--Testcase 649:
DROP TRIGGER trig_stmt_before ON rem1;
--Testcase 650:
DROP TRIGGER trig_stmt_after ON rem1;

--Testcase 360:
DELETE from rem1;

-- Test multiple AFTER ROW triggers on a foreign table
--Testcase 651:
CREATE TRIGGER trig_row_after1
AFTER INSERT OR UPDATE OR DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 652:
CREATE TRIGGER trig_row_after2
AFTER INSERT OR UPDATE OR DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 653:
insert into rem1 values(1,'insert');
--Testcase 654:
update rem1 set f2  = 'update' where f1 = 1;
--Testcase 655:
update rem1 set f2 = f2 || f2;
--Testcase 656:
delete from rem1;

-- cleanup
--Testcase 657:
DROP TRIGGER trig_row_after1 ON rem1;
--Testcase 658:
DROP TRIGGER trig_row_after2 ON rem1;

-- Test WHEN conditions

--Testcase 659:
CREATE TRIGGER trig_row_before_insupd
BEFORE INSERT OR UPDATE ON rem1
FOR EACH ROW
WHEN (NEW.f2 like '%update%')
EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 660:
CREATE TRIGGER trig_row_after_insupd
AFTER INSERT OR UPDATE ON rem1
FOR EACH ROW
WHEN (NEW.f2 like '%update%')
EXECUTE PROCEDURE trigger_data(23,'skidoo');

-- Insert or update not matching: nothing happens
--Testcase 363:
INSERT INTO rem1 values(1, 'insert');
--Testcase 364:
UPDATE rem1 set f2 = 'test';

-- Insert or update matching: triggers are fired
--Testcase 365:
INSERT INTO rem1 values(2, 'update');
--Testcase 366:
UPDATE rem1 set f2 = 'update update' where f1 = '2';

--Testcase 661:
CREATE TRIGGER trig_row_before_delete
BEFORE DELETE ON rem1
FOR EACH ROW
WHEN (OLD.f2 like '%update%')
EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 662:
CREATE TRIGGER trig_row_after_delete
AFTER DELETE ON rem1
FOR EACH ROW
WHEN (OLD.f2 like '%update%')
EXECUTE PROCEDURE trigger_data(23,'skidoo');

-- Trigger is fired for f1=2, not for f1=1
--Testcase 369:
DELETE FROM rem1;

-- cleanup
--Testcase 663:
DROP TRIGGER trig_row_before_insupd ON rem1;
--Testcase 664:
DROP TRIGGER trig_row_after_insupd ON rem1;
--Testcase 665:
DROP TRIGGER trig_row_before_delete ON rem1;
--Testcase 666:
DROP TRIGGER trig_row_after_delete ON rem1;


-- Test various RETURN statements in BEFORE triggers.

--Testcase 667:
CREATE FUNCTION trig_row_before_insupdate() RETURNS TRIGGER AS $$
  BEGIN
    NEW.f2 := NEW.f2 || ' triggered !';
    RETURN NEW;
  END
$$ language plpgsql;

--Testcase 668:
CREATE TRIGGER trig_row_before_insupd
BEFORE INSERT OR UPDATE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trig_row_before_insupdate();

-- The new values should have 'triggered' appended
--Testcase 370:
INSERT INTO rem1 values(1, 'insert');
--Testcase 371:
SELECT f1, f2 from rem1;
--Testcase 372:
INSERT INTO rem1 values(2, 'insert');
--Testcase 373:
SELECT f1, f2 from rem1;
--Testcase 374:
UPDATE rem1 set f2 = '';
--Testcase 375:
SELECT f1, f2 from rem1;
--Testcase 376:
UPDATE rem1 set f2 = 'skidoo';
--Testcase 377:
SELECT f1, f2 from rem1;

--Testcase 669:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f1 = 10;          -- all columns should be transmitted
--Testcase 670:
UPDATE rem1 set f1 = 10;
--Testcase 671:
SELECT f1, f2 from rem1;

--Testcase 378:
DELETE FROM rem1;

-- Add a second trigger, to check that the changes are propagated correctly
-- from trigger to trigger
--Testcase 672:
CREATE TRIGGER trig_row_before_insupd2
BEFORE INSERT OR UPDATE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trig_row_before_insupdate();

--Testcase 379:
INSERT INTO rem1 values(1, 'insert');
--Testcase 380:
SELECT f1, f2 from rem1;
--Testcase 381:
INSERT INTO rem1 values(2, 'insert');
--Testcase 382:
SELECT f1, f2 from rem1;
--Testcase 383:
UPDATE rem1 set f2 = '';
--Testcase 384:
SELECT f1, f2 from rem1;
--Testcase 385:
UPDATE rem1 set f2 = 'skidoo';
--Testcase 386:
SELECT f1, f2 from rem1;

--Testcase 673:
DROP TRIGGER trig_row_before_insupd ON rem1;
--Testcase 674:
DROP TRIGGER trig_row_before_insupd2 ON rem1;

--Testcase 387:
DELETE from rem1;

--Testcase 388:
INSERT INTO rem1 VALUES (1, 'test');

-- Test with a trigger returning NULL
--Testcase 675:
CREATE FUNCTION trig_null() RETURNS TRIGGER AS $$
  BEGIN
    RETURN NULL;
  END
$$ language plpgsql;

--Testcase 676:
CREATE TRIGGER trig_null
BEFORE INSERT OR UPDATE OR DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trig_null();

-- Nothing should have changed.
--Testcase 389:
INSERT INTO rem1 VALUES (2, 'test2');

--Testcase 390:
SELECT f1, f2 from rem1;

--Testcase 391:
UPDATE rem1 SET f2 = 'test2';

--Testcase 392:
SELECT f1, f2 from rem1;

--Testcase 393:
DELETE from rem1;

--Testcase 394:
SELECT f1, f2 from rem1;

--Testcase 677:
DROP TRIGGER trig_null ON rem1;
--Testcase 395:
DELETE from rem1;

-- Test a combination of local and remote triggers
--Testcase 678:
CREATE TRIGGER trig_row_before
BEFORE INSERT OR UPDATE OR DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 679:
CREATE TRIGGER trig_row_after
AFTER INSERT OR UPDATE OR DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 680:
CREATE TRIGGER trig_local_before BEFORE INSERT OR UPDATE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trig_row_before_insupdate();

--Testcase 681:
INSERT INTO rem1(f2) VALUES ('test');
--Testcase 682:
UPDATE rem1 SET f2 = 'testo';

-- Test returning a system attribute
--Testcase 683:
INSERT INTO rem1(f2) VALUES ('test');

-- cleanup
--Testcase 684:
DROP TRIGGER trig_row_before ON rem1;
--Testcase 685:
DROP TRIGGER trig_row_after ON rem1;
--Testcase 686:
DROP TRIGGER trig_local_before ON rem1;


-- Test direct foreign table modification functionality
--Testcase 832:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can be pushed down
--Testcase 833:
EXPLAIN (verbose, costs off)
DELETE FROM rem1 WHERE false;     -- currently can't be pushed down

-- Test with statement-level triggers
--Testcase 687:
CREATE TRIGGER trig_stmt_before
	BEFORE DELETE OR INSERT OR UPDATE ON rem1
	FOR EACH STATEMENT EXECUTE PROCEDURE trigger_func();
--Testcase 396:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f2 = '';          -- can be pushed down
--Testcase 397:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can be pushed down
--Testcase 688:
DROP TRIGGER trig_stmt_before ON rem1;

--Testcase 689:
CREATE TRIGGER trig_stmt_after
	AFTER DELETE OR INSERT OR UPDATE ON rem1
	FOR EACH STATEMENT EXECUTE PROCEDURE trigger_func();
--Testcase 398:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f2 = '';          -- can be pushed down
--Testcase 399:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can be pushed down
--Testcase 690:
DROP TRIGGER trig_stmt_after ON rem1;

-- Test with row-level ON INSERT triggers
--Testcase 691:
CREATE TRIGGER trig_row_before_insert
BEFORE INSERT ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');
--Testcase 400:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f2 = '';          -- can be pushed down
--Testcase 401:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can be pushed down
--Testcase 692:
DROP TRIGGER trig_row_before_insert ON rem1;

--Testcase 693:
CREATE TRIGGER trig_row_after_insert
AFTER INSERT ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');
--Testcase 402:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f2 = '';          -- can be pushed down
--Testcase 403:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can be pushed down
--Testcase 694:
DROP TRIGGER trig_row_after_insert ON rem1;

-- Test with row-level ON UPDATE triggers
--Testcase 695:
CREATE TRIGGER trig_row_before_update
BEFORE UPDATE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');
--Testcase 404:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f2 = '';          -- can't be pushed down
--Testcase 405:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can be pushed down
--Testcase 696:
DROP TRIGGER trig_row_before_update ON rem1;

--Testcase 697:
CREATE TRIGGER trig_row_after_update
AFTER UPDATE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');
--Testcase 406:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f2 = '';          -- can't be pushed down
--Testcase 407:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can be pushed down
--Testcase 698:
DROP TRIGGER trig_row_after_update ON rem1;

-- Test with row-level ON DELETE triggers
--Testcase 699:
CREATE TRIGGER trig_row_before_delete
BEFORE DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');
--Testcase 408:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f2 = '';          -- can be pushed down
--Testcase 409:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can't be pushed down
--Testcase 700:
DROP TRIGGER trig_row_before_delete ON rem1;

--Testcase 701:
CREATE TRIGGER trig_row_after_delete
AFTER DELETE ON rem1
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');
--Testcase 410:
EXPLAIN (verbose, costs off)
UPDATE rem1 set f2 = '';          -- can be pushed down
--Testcase 411:
EXPLAIN (verbose, costs off)
DELETE FROM rem1;                 -- can't be pushed down
--Testcase 702:
DROP TRIGGER trig_row_after_delete ON rem1;

-- ===================================================================
-- test inheritance features
-- ===================================================================

--Testcase 703:
CREATE TABLE a (aa TEXT);
--Testcase 834:
ALTER TABLE a SET (autovacuum_enabled = 'false');
--Testcase 704:
CREATE FOREIGN TABLE b (aa TEXT OPTIONS (key 'true'), bb TEXT) INHERITS (a)
  SERVER sqlite_svr OPTIONS (table 'loct');

--Testcase 412:
INSERT INTO a(aa) VALUES('aaa');
--Testcase 413:
INSERT INTO a(aa) VALUES('aaaa');
--Testcase 414:
INSERT INTO a(aa) VALUES('aaaaa');

--Testcase 415:
INSERT INTO b(aa) VALUES('bbb');
--Testcase 416:
INSERT INTO b(aa) VALUES('bbbb');
--Testcase 417:
INSERT INTO b(aa) VALUES('bbbbb');

--Testcase 418:
SELECT tableoid::regclass, * FROM a;
--Testcase 419:
SELECT tableoid::regclass, * FROM b;
--Testcase 420:
SELECT tableoid::regclass, * FROM ONLY a;

--Testcase 421:
UPDATE a SET aa = 'zzzzzz' WHERE aa LIKE 'aaaa%';

--Testcase 422:
SELECT tableoid::regclass, * FROM a;
--Testcase 423:
SELECT tableoid::regclass, * FROM b;
--Testcase 424:
SELECT tableoid::regclass, * FROM ONLY a;

--Testcase 425:
UPDATE b SET aa = 'new';

--Testcase 426:
SELECT tableoid::regclass, * FROM a;
--Testcase 427:
SELECT tableoid::regclass, * FROM b;
--Testcase 428:
SELECT tableoid::regclass, * FROM ONLY a;

--Testcase 429:
UPDATE a SET aa = 'newtoo';

--Testcase 430:
SELECT tableoid::regclass, * FROM a;
--Testcase 431:
SELECT tableoid::regclass, * FROM b;
--Testcase 432:
SELECT tableoid::regclass, * FROM ONLY a;

--Testcase 433:
DELETE FROM a;

--Testcase 434:
SELECT tableoid::regclass, * FROM a;
--Testcase 435:
SELECT tableoid::regclass, * FROM b;
--Testcase 436:
SELECT tableoid::regclass, * FROM ONLY a;

--Testcase 705:
DROP TABLE a CASCADE;

-- Check SELECT FOR UPDATE/SHARE with an inherited source table

--Testcase 706:
create table foo (f1 int, f2 int);
--Testcase 707:
create foreign table foo2 (f3 int OPTIONS (key 'true')) inherits (foo)
  server sqlite_svr options (table 'loct1');
--Testcase 708:
create table bar (f1 int, f2 int);
--Testcase 709:
create foreign table bar2 (f3 int OPTIONS (key 'true')) inherits (bar)
  server sqlite_svr options (table 'loct2');

--Testcase 835:
alter table foo set (autovacuum_enabled = 'false');
--Testcase 836:
alter table bar set (autovacuum_enabled = 'false');

--Testcase 437:
insert into foo values(1,1);
--Testcase 438:
insert into foo values(3,3);
--Testcase 439:
insert into foo2 values(2,2,2);
--Testcase 440:
insert into foo2 values(4,4,4);
--Testcase 441:
insert into bar values(1,11);
--Testcase 442:
insert into bar values(2,22);
--Testcase 443:
insert into bar values(6,66);
--Testcase 444:
insert into bar2 values(3,33,33);
--Testcase 445:
insert into bar2 values(4,44,44);
--Testcase 446:
insert into bar2 values(7,77,77);

--Testcase 447:
explain (verbose, costs off)
select * from bar where f1 in (select f1 from foo) for update;
--Testcase 448:
select * from bar where f1 in (select f1 from foo) for update;

--Testcase 449:
explain (verbose, costs off)
select * from bar where f1 in (select f1 from foo) for share;
--Testcase 450:
select * from bar where f1 in (select f1 from foo) for share;

-- Now check SELECT FOR UPDATE/SHARE with an inherited source table,
-- where the parent is itself a foreign table
--Testcase 837:
create foreign table foo2child (f3 int) inherits (foo2)
  server sqlite_svr options (table 'loct4_2');

--Testcase 838:
explain (verbose, costs off)
select * from bar where f1 in (select f1 from foo2) for share;
--Testcase 839:
select * from bar where f1 in (select f1 from foo2) for share;

--Testcase 840:
drop foreign table foo2child;

-- And with a local child relation of the foreign table parent
--Testcase 841:
create table foo2child (f3 int) inherits (foo2);

--Testcase 842:
explain (verbose, costs off)
select * from bar where f1 in (select f1 from foo2) for share;
--Testcase 843:
select * from bar where f1 in (select f1 from foo2) for share;

--Testcase 844:
drop table foo2child;

-- Check UPDATE with inherited target and an inherited source table
--Testcase 451:
explain (verbose, costs off)
update bar set f2 = f2 + 100 where f1 in (select f1 from foo);
--Testcase 452:
update bar set f2 = f2 + 100 where f1 in (select f1 from foo);

--Testcase 453:
select tableoid::regclass, * from bar order by 1,2;

-- Check UPDATE with inherited target and an appendrel subquery
--Testcase 454:
explain (verbose, costs off)
update bar set f2 = f2 + 100
from
  ( select f1 from foo union all select f1+3 from foo ) ss
where bar.f1 = ss.f1;
--Testcase 455:
update bar set f2 = f2 + 100
from
  ( select f1 from foo union all select f1+3 from foo ) ss
where bar.f1 = ss.f1;

--Testcase 456:
select tableoid::regclass, * from bar order by 1,2;

-- Test forcing the remote server to produce sorted data for a merge join,
-- but the foreign table is an inheritance child.
--truncate table loct1;
--Testcase 710:
delete from foo2;
truncate table only foo;
\set num_rows_foo 2000
--Testcase 711:
insert into foo2 select generate_series(0, :num_rows_foo, 2), generate_series(0, :num_rows_foo, 2), generate_series(0, :num_rows_foo, 2);
--Testcase 712:
insert into foo select generate_series(1, :num_rows_foo, 2), generate_series(1, :num_rows_foo, 2);
--Testcase 845:
SET enable_hashjoin to false;
--Testcase 846:
SET enable_nestloop to false;
--alter foreign table foo2 options (use_remote_estimate 'true');
--create index i_loct1_f1 on loct1(f1);
--Testcase 713:
create index i_foo_f1 on foo(f1);
analyze foo;
--analyze loct1;
-- inner join; expressions in the clauses appear in the equivalence class list
--Testcase 714:
explain (verbose, costs off)
	select foo.f1, foo2.f1 from foo join foo2 on (foo.f1 = foo2.f1) order by foo.f2 offset 10 limit 10;
--Testcase 715:
select foo.f1, foo2.f1 from foo join foo2 on (foo.f1 = foo2.f1) order by foo.f2 offset 10 limit 10;
-- outer join; expressions in the clauses do not appear in equivalence class
-- list but no output change as compared to the previous query
--Testcase 716:
explain (verbose, costs off)
	select foo.f1, foo2.f1 from foo left join foo2 on (foo.f1 = foo2.f1) order by foo.f2 offset 10 limit 10;
--Testcase 717:
select foo.f1, foo2.f1 from foo left join foo2 on (foo.f1 = foo2.f1) order by foo.f2 offset 10 limit 10;
--Testcase 847:
RESET enable_hashjoin;
--Testcase 848:
RESET enable_nestloop;

-- Test that WHERE CURRENT OF is not supported
begin;
declare c cursor for select * from bar where f1 = 7;
--Testcase 457:
fetch from c;
--Testcase 458:
update bar set f2 = null where current of c;
rollback;

--Testcase 459:
explain (verbose, costs off)
delete from foo where f1 < 5;
--Testcase 460:
delete from foo where f1 < 5;
--Testcase 461:
explain (verbose, costs off)
update bar set f2 = f2 + 100;
--Testcase 462:
update bar set f2 = f2 + 100;
--Testcase 463:
select * from bar;

-- Test that UPDATE/DELETE with inherited target works with row-level triggers
--Testcase 718:
CREATE TRIGGER trig_row_before
BEFORE UPDATE OR DELETE ON bar2
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 719:
CREATE TRIGGER trig_row_after
AFTER UPDATE OR DELETE ON bar2
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');

--Testcase 464:
explain (verbose, costs off)
update bar set f2 = f2 + 100;
--Testcase 465:
update bar set f2 = f2 + 100;

--Testcase 466:
explain (verbose, costs off)
delete from bar where f2 < 400;
--Testcase 467:
delete from bar where f2 < 400;

-- cleanup
--Testcase 720:
drop table foo cascade;
--Testcase 721:
drop table bar cascade;

-- Test pushing down UPDATE/DELETE joins to the remote server
--Testcase 722:
create table parent (a int, b text);
--Testcase 723:
create foreign table remt1 (a int OPTIONS (key 'true'), b text)
  server sqlite_svr options (table 'loct3');
--Testcase 724:
create foreign table remt2 (a int OPTIONS (key 'true'), b text)
  server sqlite_svr options (table 'loct4');
--Testcase 849:
alter foreign table remt1 inherit parent;

--Testcase 468:
insert into remt1 values (1, 'foo');
--Testcase 469:
insert into remt1 values (2, 'bar');
--Testcase 470:
insert into remt2 values (1, 'foo');
--Testcase 471:
insert into remt2 values (2, 'bar');

--Testcase 472:
explain (verbose, costs off)
update parent set b = parent.b || remt2.b from remt2 where parent.a = remt2.a;
--Testcase 473:
update parent set b = parent.b || remt2.b from remt2 where parent.a = remt2.a;
--Testcase 474:
select * from parent inner join remt2 on (parent.a = remt2.a);
--Testcase 475:
explain (verbose, costs off)
delete from parent using remt2 where parent.a = remt2.a;
--Testcase 476:
delete from parent using remt2 where parent.a = remt2.a;

-- cleanup
--Testcase 725:
drop foreign table remt1;
--Testcase 726:
drop foreign table remt2;
--Testcase 727:
drop table parent;

/* 
-- Skip these tests, sqlite fdw does not support partition table, check constraint, copy from
-- ===================================================================
-- test tuple routing for foreign-table partitions
-- ===================================================================

-- Test insert tuple routing
create table itrtest (a int, b text) partition by list (a);
create table loct1 (a int check (a in (1)), b text);
create foreign table remp1 (a int check (a in (1)), b text) server loopback options (table_name 'loct1');
create table loct2 (a int check (a in (2)), b text);
create foreign table remp2 (b text, a int check (a in (2))) server loopback options (table_name 'loct2');
alter table itrtest attach partition remp1 for values in (1);
alter table itrtest attach partition remp2 for values in (2);

insert into itrtest values (1, 'foo');
insert into itrtest values (1, 'bar') returning *;
insert into itrtest values (2, 'baz');
insert into itrtest values (2, 'qux') returning *;
insert into itrtest values (1, 'test1'), (2, 'test2') returning *;

select tableoid::regclass, * FROM itrtest;
select tableoid::regclass, * FROM remp1;
select tableoid::regclass, * FROM remp2;

delete from itrtest;

create unique index loct1_idx on loct1 (a);

-- DO NOTHING without an inference specification is supported
insert into itrtest values (1, 'foo') on conflict do nothing returning *;
insert into itrtest values (1, 'foo') on conflict do nothing returning *;

-- But other cases are not supported
insert into itrtest values (1, 'bar') on conflict (a) do nothing;
insert into itrtest values (1, 'bar') on conflict (a) do update set b = excluded.b;

select tableoid::regclass, * FROM itrtest;

delete from itrtest;

drop index loct1_idx;

-- Test that remote triggers work with insert tuple routing
create function br_insert_trigfunc() returns trigger as $$
begin
	new.b := new.b || ' triggered !';
	return new;
end
$$ language plpgsql;
create trigger loct1_br_insert_trigger before insert on loct1
	for each row execute procedure br_insert_trigfunc();
create trigger loct2_br_insert_trigger before insert on loct2
	for each row execute procedure br_insert_trigfunc();

-- The new values are concatenated with ' triggered !'
insert into itrtest values (1, 'foo') returning *;
insert into itrtest values (2, 'qux') returning *;
insert into itrtest values (1, 'test1'), (2, 'test2') returning *;
with result as (insert into itrtest values (1, 'test1'), (2, 'test2') returning *) select * from result;

drop trigger loct1_br_insert_trigger on loct1;
drop trigger loct2_br_insert_trigger on loct2;

drop table itrtest;
drop table loct1;
drop table loct2;

-- Test update tuple routing
create table utrtest (a int, b text) partition by list (a);
create table loct (a int check (a in (1)), b text);
create foreign table remp (a int check (a in (1)), b text) server loopback options (table_name 'loct');
create table locp (a int check (a in (2)), b text);
alter table utrtest attach partition remp for values in (1);
alter table utrtest attach partition locp for values in (2);

insert into utrtest values (1, 'foo');
insert into utrtest values (2, 'qux');

select tableoid::regclass, * FROM utrtest;
select tableoid::regclass, * FROM remp;
select tableoid::regclass, * FROM locp;

-- It's not allowed to move a row from a partition that is foreign to another
update utrtest set a = 2 where b = 'foo' returning *;

-- But the reverse is allowed
update utrtest set a = 1 where b = 'qux' returning *;

select tableoid::regclass, * FROM utrtest;
select tableoid::regclass, * FROM remp;
select tableoid::regclass, * FROM locp;

-- The executor should not let unexercised FDWs shut down
update utrtest set a = 1 where b = 'foo';

-- Test that remote triggers work with update tuple routing
create trigger loct_br_insert_trigger before insert on loct
	for each row execute procedure br_insert_trigfunc();

delete from utrtest;
insert into utrtest values (2, 'qux');

-- Check case where the foreign partition is a subplan target rel
explain (verbose, costs off)
update utrtest set a = 1 where a = 1 or a = 2 returning *;
-- The new values are concatenated with ' triggered !'
update utrtest set a = 1 where a = 1 or a = 2 returning *;

delete from utrtest;
insert into utrtest values (2, 'qux');

-- Check case where the foreign partition isn't a subplan target rel
explain (verbose, costs off)
update utrtest set a = 1 where a = 2 returning *;
-- The new values are concatenated with ' triggered !'
update utrtest set a = 1 where a = 2 returning *;

drop trigger loct_br_insert_trigger on loct;

-- We can move rows to a foreign partition that has been updated already,
-- but can't move rows to a foreign partition that hasn't been updated yet

delete from utrtest;
insert into utrtest values (1, 'foo');
insert into utrtest values (2, 'qux');

-- Test the former case:
-- with a direct modification plan
explain (verbose, costs off)
update utrtest set a = 1 returning *;
update utrtest set a = 1 returning *;

delete from utrtest;
insert into utrtest values (1, 'foo');
insert into utrtest values (2, 'qux');

-- with a non-direct modification plan
explain (verbose, costs off)
update utrtest set a = 1 from (values (1), (2)) s(x) where a = s.x returning *;
update utrtest set a = 1 from (values (1), (2)) s(x) where a = s.x returning *;

-- Change the definition of utrtest so that the foreign partition get updated
-- after the local partition
delete from utrtest;
alter table utrtest detach partition remp;
drop foreign table remp;
alter table loct drop constraint loct_a_check;
alter table loct add check (a in (3));
create foreign table remp (a int check (a in (3)), b text) server loopback options (table_name 'loct');
alter table utrtest attach partition remp for values in (3);
insert into utrtest values (2, 'qux');
insert into utrtest values (3, 'xyzzy');

-- Test the latter case:
-- with a direct modification plan
explain (verbose, costs off)
update utrtest set a = 3 returning *;
update utrtest set a = 3 returning *; -- ERROR

-- with a non-direct modification plan
explain (verbose, costs off)
update utrtest set a = 3 from (values (2), (3)) s(x) where a = s.x returning *;
update utrtest set a = 3 from (values (2), (3)) s(x) where a = s.x returning *; -- ERROR

drop table utrtest;
drop table loct;

-- Test copy tuple routing
create table ctrtest (a int, b text) partition by list (a);
create table loct1 (a int check (a in (1)), b text);
create foreign table remp1 (a int check (a in (1)), b text) server loopback options (table_name 'loct1');
create table loct2 (a int check (a in (2)), b text);
create foreign table remp2 (b text, a int check (a in (2))) server loopback options (table_name 'loct2');
alter table ctrtest attach partition remp1 for values in (1);
alter table ctrtest attach partition remp2 for values in (2);

copy ctrtest from stdin;
1	foo
2	qux
\.

select tableoid::regclass, * FROM ctrtest;
select tableoid::regclass, * FROM remp1;
select tableoid::regclass, * FROM remp2;

-- Copying into foreign partitions directly should work as well
copy remp1 from stdin;
1	bar
\.

select tableoid::regclass, * FROM remp1;

drop table ctrtest;
drop table loct1;
drop table loct2;

-- ===================================================================
-- test COPY FROM
-- ===================================================================

create table loc2 (f1 int, f2 text);
alter table loc2 set (autovacuum_enabled = 'false');
create foreign table rem2 (f1 int, f2 text) server loopback options(table_name 'loc2');

-- Test basic functionality
copy rem2 from stdin;
1	foo
2	bar
\.
select * from rem2;

delete from rem2;

-- Test check constraints
alter table loc2 add constraint loc2_f1positive check (f1 >= 0);
alter foreign table rem2 add constraint rem2_f1positive check (f1 >= 0);

-- check constraint is enforced on the remote side, not locally
copy rem2 from stdin;
1	foo
2	bar
\.
copy rem2 from stdin; -- ERROR
-1	xyzzy
\.
select * from rem2;

alter foreign table rem2 drop constraint rem2_f1positive;
alter table loc2 drop constraint loc2_f1positive;

delete from rem2;

-- Test local triggers
create trigger trig_stmt_before before insert on rem2
	for each statement execute procedure trigger_func();
create trigger trig_stmt_after after insert on rem2
	for each statement execute procedure trigger_func();
create trigger trig_row_before before insert on rem2
	for each row execute procedure trigger_data(23,'skidoo');
create trigger trig_row_after after insert on rem2
	for each row execute procedure trigger_data(23,'skidoo');

copy rem2 from stdin;
1	foo
2	bar
\.
select * from rem2;

drop trigger trig_row_before on rem2;
drop trigger trig_row_after on rem2;
drop trigger trig_stmt_before on rem2;
drop trigger trig_stmt_after on rem2;

delete from rem2;

create trigger trig_row_before_insert before insert on rem2
	for each row execute procedure trig_row_before_insupdate();

-- The new values are concatenated with ' triggered !'
copy rem2 from stdin;
1	foo
2	bar
\.
select * from rem2;

drop trigger trig_row_before_insert on rem2;

delete from rem2;

create trigger trig_null before insert on rem2
	for each row execute procedure trig_null();

-- Nothing happens
copy rem2 from stdin;
1	foo
2	bar
\.
select * from rem2;

drop trigger trig_null on rem2;

delete from rem2;

-- Test remote triggers
create trigger trig_row_before_insert before insert on loc2
	for each row execute procedure trig_row_before_insupdate();

-- The new values are concatenated with ' triggered !'
copy rem2 from stdin;
1	foo
2	bar
\.
select * from rem2;

drop trigger trig_row_before_insert on loc2;

delete from rem2;

create trigger trig_null before insert on loc2
	for each row execute procedure trig_null();

-- Nothing happens
copy rem2 from stdin;
1	foo
2	bar
\.
select * from rem2;

drop trigger trig_null on loc2;

delete from rem2;

-- Test a combination of local and remote triggers
create trigger rem2_trig_row_before before insert on rem2
	for each row execute procedure trigger_data(23,'skidoo');
create trigger rem2_trig_row_after after insert on rem2
	for each row execute procedure trigger_data(23,'skidoo');
create trigger loc2_trig_row_before_insert before insert on loc2
	for each row execute procedure trig_row_before_insupdate();

copy rem2 from stdin;
1	foo
2	bar
\.
select * from rem2;

drop trigger rem2_trig_row_before on rem2;
drop trigger rem2_trig_row_after on rem2;
drop trigger loc2_trig_row_before_insert on loc2;

delete from rem2;

-- test COPY FROM with foreign table created in the same transaction
create table loc3 (f1 int, f2 text);
begin;
create foreign table rem3 (f1 int, f2 text)
	server loopback options(table_name 'loc3');
copy rem3 from stdin;
1	foo
2	bar
\.
commit;
select * from rem3;
drop foreign table rem3;
drop table loc3;
*/

-- ===================================================================
-- test for TRUNCATE
-- ===================================================================
--Testcase 850:
CREATE FOREIGN TABLE tru_ftable (id int)
       SERVER sqlite_svr OPTIONS (table 'tru_rtable0');
--Testcase 851:
INSERT INTO "S 1".tru_rtable0 (SELECT x FROM generate_series(1,10) x);

-- CREATE TABLE tru_ptable (id int) PARTITION BY HASH(id);
-- CREATE TABLE tru_ptable__p0 PARTITION OF tru_ptable
--                             FOR VALUES WITH (MODULUS 2, REMAINDER 0);
-- CREATE TABLE tru_rtable1 (id int primary key);
-- CREATE FOREIGN TABLE tru_ftable__p1 (id int)
--        SERVER sqlite_svr OPTIONS (table 'tru_ptable');
-- INSERT INTO tru_ptable (SELECT x FROM generate_series(11,20) x);

--Testcase 852:
INSERT INTO "S 1".tru_pk_table (SELECT x FROM generate_series(1,10) x);
--Testcase 853:
INSERT INTO "S 1".tru_fk_table(fkey) (SELECT x % 10 + 1 FROM generate_series(5,25) x);
--Testcase 854:
CREATE FOREIGN TABLE tru_pk_ftable (id int)
       SERVER sqlite_svr OPTIONS (table 'tru_pk_table');

--Testcase 855:
CREATE FOREIGN TABLE tru_ftable_parent (id int)
       SERVER sqlite_svr OPTIONS (table 'tru_rtable_parent');
--Testcase 856:
CREATE FOREIGN TABLE tru_ftable_child () INHERITS (tru_ftable_parent)
       SERVER sqlite_svr OPTIONS (table 'tru_rtable_child');
--Testcase 857:
INSERT INTO "S 1".tru_rtable_parent (SELECT x FROM generate_series(1,8) x);
--Testcase 858:
INSERT INTO "S 1".tru_rtable_child  (SELECT x FROM generate_series(10, 18) x);

-- normal truncate
--Testcase 859:
SELECT sum(id) FROM tru_ftable;        -- 55
TRUNCATE tru_ftable;
--Testcase 860:
SELECT count(*) FROM "S 1".tru_rtable0;		-- 0
--Testcase 861:
SELECT count(*) FROM tru_ftable;		-- 0

-- 'truncatable' option
--Testcase 862:
ALTER SERVER sqlite_svr OPTIONS (ADD truncatable 'false');
TRUNCATE tru_ftable;			-- error
--Testcase 863:
ALTER FOREIGN TABLE tru_ftable OPTIONS (ADD truncatable 'true');
TRUNCATE tru_ftable;			-- accepted
--Testcase 864:
ALTER FOREIGN TABLE tru_ftable OPTIONS (SET truncatable 'false');
TRUNCATE tru_ftable;			-- error
--Testcase 865:
ALTER SERVER sqlite_svr OPTIONS (DROP truncatable);
--Testcase 866:
ALTER FOREIGN TABLE tru_ftable OPTIONS (SET truncatable 'false');
TRUNCATE tru_ftable;			-- error
--Testcase 867:
ALTER FOREIGN TABLE tru_ftable OPTIONS (SET truncatable 'true');
TRUNCATE tru_ftable;			-- accepted

-- -- partitioned table with both local and foreign tables as partitions
-- SELECT sum(id) FROM tru_ptable;        -- 155
-- TRUNCATE tru_ptable;
-- SELECT count(*) FROM tru_ptable;		-- 0
-- SELECT count(*) FROM tru_ptable__p0;	-- 0
-- SELECT count(*) FROM tru_ftable__p1;	-- 0
-- SELECT count(*) FROM tru_rtable1;		-- 0

-- 'CASCADE' option
--Testcase 868:
SELECT sum(id) FROM tru_pk_ftable;      -- 55
-- SQLite FDW support TRUNCATE command by executing DELETE statement without WHERE clause.
-- In order to delete records in parent and child table subsequently,
-- SQLite FDW executes "PRAGMA foreign_keys = ON" before executing DELETE statement.
TRUNCATE tru_pk_ftable; -- success
TRUNCATE tru_pk_ftable CASCADE; -- success
--Testcase 869:
SELECT count(*) FROM tru_pk_ftable;    -- 0
--Testcase 870:
SELECT count(*) FROM "S 1".tru_fk_table;		-- also truncated,0

-- truncate two tables at a command
--Testcase 871:
INSERT INTO tru_ftable (SELECT x FROM generate_series(1,8) x);
--Testcase 872:
INSERT INTO tru_pk_ftable (SELECT x FROM generate_series(3,10) x);
--Testcase 873:
SELECT count(*) from tru_ftable; -- 8
--Testcase 874:
SELECT count(*) from tru_pk_ftable; -- 8
TRUNCATE tru_ftable, tru_pk_ftable;
--Testcase 875:
SELECT count(*) from tru_ftable; -- 0
--Testcase 876:
SELECT count(*) from tru_pk_ftable; -- 0

-- truncate with ONLY clause
-- Since ONLY is specified, the table tru_ftable_child that inherits
-- tru_ftable_parent locally is not truncated.
TRUNCATE ONLY tru_ftable_parent;
--Testcase 877:
SELECT sum(id) FROM tru_ftable_parent;  -- 126
TRUNCATE tru_ftable_parent;
--Testcase 878:
SELECT count(*) FROM tru_ftable_parent; -- 0

-- -- in case when remote table has inherited children
-- CREATE TABLE tru_rtable0_child () INHERITS (tru_rtable0);
-- INSERT INTO tru_rtable0 (SELECT x FROM generate_series(5,9) x);
-- INSERT INTO "S 1".tru_rtable0_child (SELECT x FROM generate_series(10,14) x);
-- SELECT sum(id) FROM tru_ftable;   -- 95

-- -- Both parent and child tables in the foreign server are truncated
-- -- even though ONLY is specified because ONLY has no effect
-- -- when truncating a foreign table.
-- TRUNCATE ONLY tru_ftable;
-- SELECT count(*) FROM tru_ftable;   -- 0

-- INSERT INTO tru_rtable0 (SELECT x FROM generate_series(21,25) x);
-- INSERT INTO tru_rtable0_child (SELECT x FROM generate_series(26,30) x);
-- SELECT sum(id) FROM tru_ftable;		-- 255
-- TRUNCATE tru_ftable;			-- truncate both of parent and child
-- SELECT count(*) FROM tru_ftable;    -- 0

-- cleanup
--Testcase 879:
DROP FOREIGN TABLE tru_ftable_parent, tru_ftable_child, tru_pk_ftable,tru_ftable;
-- DROP TABLE tru_rtable0, tru_rtable1, tru_ptable, tru_ptable__p0, tru_pk_table, tru_fk_table,
-- tru_rtable_parent,tru_rtable_child, tru_rtable0_child;

-- ===================================================================
-- test IMPORT FOREIGN SCHEMA
-- ===================================================================

--Testcase 728:
CREATE SCHEMA import_dest1;
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_svr INTO import_dest1;
--Testcase 477:
\det+ import_dest1.*
--Testcase 478:
\d import_dest1.*

-- Options
--Testcase 729:
CREATE SCHEMA import_dest2;
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_svr INTO import_dest2
  OPTIONS (import_default 'true');
--Testcase 479:
\det+ import_dest2.*
--Testcase 480:
\d import_dest2.*

-- Check LIMIT TO and EXCEPT
--Testcase 730:
CREATE SCHEMA import_dest3;
IMPORT FOREIGN SCHEMA public LIMIT TO ("T 1", loct6, nonesuch)
  FROM SERVER sqlite_svr INTO import_dest3;
--Testcase 481:
\det+ import_dest3.*
IMPORT FOREIGN SCHEMA public EXCEPT ("T 1", loct6, nonesuch)
  FROM SERVER sqlite_svr INTO import_dest3;
--Testcase 482:
\det+ import_dest3.*

-- Assorted error cases
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_svr INTO import_dest3;
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_svr INTO notthere;
IMPORT FOREIGN SCHEMA public FROM SERVER nowhere INTO notthere;

/*
-- Skip these test, sqlite fdw does not support fetch_size option, partition table
-- Check case of a type present only on the remote server.
-- We can fake this by dropping the type locally in our transaction.
CREATE TYPE "Colors" AS ENUM ('red', 'green', 'blue');
CREATE TABLE import_source.t5 (c1 int, c2 text collate "C", "Col" "Colors");

CREATE SCHEMA import_dest5;
BEGIN;
DROP TYPE "Colors" CASCADE;
IMPORT FOREIGN SCHEMA import_source LIMIT TO (t5)
  FROM SERVER loopback INTO import_dest5;  -- ERROR

ROLLBACK;

BEGIN;


CREATE SERVER fetch101 FOREIGN DATA WRAPPER postgres_fdw OPTIONS( fetch_size '101' );

SELECT count(*)
FROM pg_foreign_server
WHERE srvname = 'fetch101'
AND srvoptions @> array['fetch_size=101'];

ALTER SERVER fetch101 OPTIONS( SET fetch_size '202' );

SELECT count(*)
FROM pg_foreign_server
WHERE srvname = 'fetch101'
AND srvoptions @> array['fetch_size=101'];

SELECT count(*)
FROM pg_foreign_server
WHERE srvname = 'fetch101'
AND srvoptions @> array['fetch_size=202'];

CREATE FOREIGN TABLE table30000 ( x int ) SERVER fetch101 OPTIONS ( fetch_size '30000' );

SELECT COUNT(*)
FROM pg_foreign_table
WHERE ftrelid = 'table30000'::regclass
AND ftoptions @> array['fetch_size=30000'];

ALTER FOREIGN TABLE table30000 OPTIONS ( SET fetch_size '60000');

SELECT COUNT(*)
FROM pg_foreign_table
WHERE ftrelid = 'table30000'::regclass
AND ftoptions @> array['fetch_size=30000'];

SELECT COUNT(*)
FROM pg_foreign_table
WHERE ftrelid = 'table30000'::regclass
AND ftoptions @> array['fetch_size=60000'];

ROLLBACK;

-- ===================================================================
-- test partitionwise joins
-- ===================================================================
SET enable_partitionwise_join=on;

CREATE TABLE fprt1 (a int, b int, c varchar) PARTITION BY RANGE(a);
CREATE TABLE fprt1_p1 (LIKE fprt1);
CREATE TABLE fprt1_p2 (LIKE fprt1);
ALTER TABLE fprt1_p1 SET (autovacuum_enabled = 'false');
ALTER TABLE fprt1_p2 SET (autovacuum_enabled = 'false');
INSERT INTO fprt1_p1 SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(0, 249, 2) i;
INSERT INTO fprt1_p2 SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(250, 499, 2) i;
CREATE FOREIGN TABLE ftprt1_p1 PARTITION OF fprt1 FOR VALUES FROM (0) TO (250)
	SERVER loopback OPTIONS (table_name 'fprt1_p1', use_remote_estimate 'true');
CREATE FOREIGN TABLE ftprt1_p2 PARTITION OF fprt1 FOR VALUES FROM (250) TO (500)
	SERVER loopback OPTIONS (TABLE_NAME 'fprt1_p2');
ANALYZE fprt1;
ANALYZE fprt1_p1;
ANALYZE fprt1_p2;

CREATE TABLE fprt2 (a int, b int, c varchar) PARTITION BY RANGE(b);
CREATE TABLE fprt2_p1 (LIKE fprt2);
CREATE TABLE fprt2_p2 (LIKE fprt2);
ALTER TABLE fprt2_p1 SET (autovacuum_enabled = 'false');
ALTER TABLE fprt2_p2 SET (autovacuum_enabled = 'false');
INSERT INTO fprt2_p1 SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(0, 249, 3) i;
INSERT INTO fprt2_p2 SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(250, 499, 3) i;
CREATE FOREIGN TABLE ftprt2_p1 (b int, c varchar, a int)
	SERVER loopback OPTIONS (table_name 'fprt2_p1', use_remote_estimate 'true');
ALTER TABLE fprt2 ATTACH PARTITION ftprt2_p1 FOR VALUES FROM (0) TO (250);
CREATE FOREIGN TABLE ftprt2_p2 PARTITION OF fprt2 FOR VALUES FROM (250) TO (500)
	SERVER loopback OPTIONS (table_name 'fprt2_p2', use_remote_estimate 'true');
ANALYZE fprt2;
ANALYZE fprt2_p1;
ANALYZE fprt2_p2;

-- inner join three tables
EXPLAIN (COSTS OFF)
SELECT t1.a,t2.b,t3.c FROM fprt1 t1 INNER JOIN fprt2 t2 ON (t1.a = t2.b) INNER JOIN fprt1 t3 ON (t2.b = t3.a) WHERE t1.a % 25 =0 ORDER BY 1,2,3;
SELECT t1.a,t2.b,t3.c FROM fprt1 t1 INNER JOIN fprt2 t2 ON (t1.a = t2.b) INNER JOIN fprt1 t3 ON (t2.b = t3.a) WHERE t1.a % 25 =0 ORDER BY 1,2,3;

-- left outer join + nullable clause
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.a,t2.b,t2.c FROM fprt1 t1 LEFT JOIN (SELECT * FROM fprt2 WHERE a < 10) t2 ON (t1.a = t2.b and t1.b = t2.a) WHERE t1.a < 10 ORDER BY 1,2,3;
SELECT t1.a,t2.b,t2.c FROM fprt1 t1 LEFT JOIN (SELECT * FROM fprt2 WHERE a < 10) t2 ON (t1.a = t2.b and t1.b = t2.a) WHERE t1.a < 10 ORDER BY 1,2,3;

-- with whole-row reference; partitionwise join does not apply
EXPLAIN (COSTS OFF)
SELECT t1.wr, t2.wr FROM (SELECT t1 wr, a FROM fprt1 t1 WHERE t1.a % 25 = 0) t1 FULL JOIN (SELECT t2 wr, b FROM fprt2 t2 WHERE t2.b % 25 = 0) t2 ON (t1.a = t2.b) ORDER BY 1,2;
SELECT t1.wr, t2.wr FROM (SELECT t1 wr, a FROM fprt1 t1 WHERE t1.a % 25 = 0) t1 FULL JOIN (SELECT t2 wr, b FROM fprt2 t2 WHERE t2.b % 25 = 0) t2 ON (t1.a = t2.b) ORDER BY 1,2;

-- join with lateral reference
EXPLAIN (COSTS OFF)
SELECT t1.a,t1.b FROM fprt1 t1, LATERAL (SELECT t2.a, t2.b FROM fprt2 t2 WHERE t1.a = t2.b AND t1.b = t2.a) q WHERE t1.a%25 = 0 ORDER BY 1,2;
SELECT t1.a,t1.b FROM fprt1 t1, LATERAL (SELECT t2.a, t2.b FROM fprt2 t2 WHERE t1.a = t2.b AND t1.b = t2.a) q WHERE t1.a%25 = 0 ORDER BY 1,2;

-- with PHVs, partitionwise join selected but no join pushdown
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.phv, t2.b, t2.phv FROM (SELECT 't1_phv' phv, * FROM fprt1 WHERE a % 25 = 0) t1 FULL JOIN (SELECT 't2_phv' phv, * FROM fprt2 WHERE b % 25 = 0) t2 ON (t1.a = t2.b) ORDER BY t1.a, t2.b;
SELECT t1.a, t1.phv, t2.b, t2.phv FROM (SELECT 't1_phv' phv, * FROM fprt1 WHERE a % 25 = 0) t1 FULL JOIN (SELECT 't2_phv' phv, * FROM fprt2 WHERE b % 25 = 0) t2 ON (t1.a = t2.b) ORDER BY t1.a, t2.b;

-- test FOR UPDATE; partitionwise join does not apply
EXPLAIN (COSTS OFF)
SELECT t1.a, t2.b FROM fprt1 t1 INNER JOIN fprt2 t2 ON (t1.a = t2.b) WHERE t1.a % 25 = 0 ORDER BY 1,2 FOR UPDATE OF t1;
SELECT t1.a, t2.b FROM fprt1 t1 INNER JOIN fprt2 t2 ON (t1.a = t2.b) WHERE t1.a % 25 = 0 ORDER BY 1,2 FOR UPDATE OF t1;

RESET enable_partitionwise_join;


-- ===================================================================
-- test partitionwise aggregates
-- ===================================================================

CREATE TABLE pagg_tab (a int, b int, c text) PARTITION BY RANGE(a);

CREATE TABLE pagg_tab_p1 (LIKE pagg_tab);
CREATE TABLE pagg_tab_p2 (LIKE pagg_tab);
CREATE TABLE pagg_tab_p3 (LIKE pagg_tab);

INSERT INTO pagg_tab_p1 SELECT i % 30, i % 50, to_char(i/30, 'FM0000') FROM generate_series(1, 3000) i WHERE (i % 30) < 10;
INSERT INTO pagg_tab_p2 SELECT i % 30, i % 50, to_char(i/30, 'FM0000') FROM generate_series(1, 3000) i WHERE (i % 30) < 20 and (i % 30) >= 10;
INSERT INTO pagg_tab_p3 SELECT i % 30, i % 50, to_char(i/30, 'FM0000') FROM generate_series(1, 3000) i WHERE (i % 30) < 30 and (i % 30) >= 20;

-- Create foreign partitions
CREATE FOREIGN TABLE fpagg_tab_p1 PARTITION OF pagg_tab FOR VALUES FROM (0) TO (10) SERVER loopback OPTIONS (table_name 'pagg_tab_p1');
CREATE FOREIGN TABLE fpagg_tab_p2 PARTITION OF pagg_tab FOR VALUES FROM (10) TO (20) SERVER loopback OPTIONS (table_name 'pagg_tab_p2');
CREATE FOREIGN TABLE fpagg_tab_p3 PARTITION OF pagg_tab FOR VALUES FROM (20) TO (30) SERVER loopback OPTIONS (table_name 'pagg_tab_p3');

ANALYZE pagg_tab;
ANALYZE fpagg_tab_p1;
ANALYZE fpagg_tab_p2;
ANALYZE fpagg_tab_p3;

-- When GROUP BY clause matches with PARTITION KEY.
-- Plan with partitionwise aggregates is disabled
SET enable_partitionwise_aggregate TO false;
EXPLAIN (COSTS OFF)
SELECT a, sum(b), min(b), count(*) FROM pagg_tab GROUP BY a HAVING avg(b) < 22 ORDER BY 1;

-- Plan with partitionwise aggregates is enabled
SET enable_partitionwise_aggregate TO true;
EXPLAIN (COSTS OFF)
SELECT a, sum(b), min(b), count(*) FROM pagg_tab GROUP BY a HAVING avg(b) < 22 ORDER BY 1;
SELECT a, sum(b), min(b), count(*) FROM pagg_tab GROUP BY a HAVING avg(b) < 22 ORDER BY 1;

-- Check with whole-row reference
-- Should have all the columns in the target list for the given relation
EXPLAIN (VERBOSE, COSTS OFF)
SELECT a, count(t1) FROM pagg_tab t1 GROUP BY a HAVING avg(b) < 22 ORDER BY 1;
SELECT a, count(t1) FROM pagg_tab t1 GROUP BY a HAVING avg(b) < 22 ORDER BY 1;

-- When GROUP BY clause does not match with PARTITION KEY.
EXPLAIN (COSTS OFF)
SELECT b, avg(a), max(a), count(*) FROM pagg_tab GROUP BY b HAVING sum(a) < 700 ORDER BY 1;
*/

/*
-- Skip these tests, sqlite fdw does not support nosuper user.
-- ===================================================================
-- access rights and superuser
-- ===================================================================

-- Non-superuser cannot create a FDW without a password in the connstr
CREATE ROLE regress_nosuper NOSUPERUSER;

GRANT USAGE ON FOREIGN DATA WRAPPER sqlite_fdw TO regress_nosuper;

SET ROLE regress_nosuper;

SHOW is_superuser;

-- This will be OK, we can create the FDW
DO $d$
    BEGIN
        EXECUTE $$CREATE SERVER sqlite_nopw FOREIGN DATA WRAPPER sqlite_fdw
            OPTIONS (database '/tmp/sqlitefdw_test_post.db')$$;
    END;
$d$;

-- But creation of user mappings for non-superusers should fail
CREATE USER MAPPING FOR public SERVER sqlite_nopw;
CREATE USER MAPPING FOR CURRENT_USER SERVER sqlite_nopw;

CREATE FOREIGN TABLE ft1_nopw (
	c1 int OPTIONS (key 'true'),
	c2 int NOT NULL,
	c3 text,
	c4 timestamptz,
	c5 timestamp,
	c6 varchar(10),
	c7 char(10) default 'ft1',
	c8 text
) SERVER sqlite_nopw;

ALTER FOREIGN TABLE ft1_nopw OPTIONS (table 'T 1');
ALTER FOREIGN TABLE ft1_nopw ALTER COLUMN c1 OPTIONS (column_name 'C 1');

SELECT 1 FROM ft1_nopw LIMIT 1;

-- If we add a password to the connstr it'll fail, because we don't allow passwords
-- in connstrs only in user mappings.

DO $d$
    BEGIN
        EXECUTE $$ALTER SERVER sqlite_nopw OPTIONS (ADD password 'dummypw')$$;
    END;
$d$;

-- If we add a password for our user mapping instead, we should get a different
-- error because the password wasn't actually *used* when we run with trust auth.
--
-- This won't work with installcheck, but neither will most of the FDW checks.

ALTER USER MAPPING FOR CURRENT_USER SERVER sqlite_nopw OPTIONS (ADD password 'dummypw');

SELECT 1 FROM ft1_nopw LIMIT 1;

-- Unpriv user cannot make the mapping passwordless
ALTER USER MAPPING FOR CURRENT_USER SERVER sqlite_nopw OPTIONS (ADD password_required 'false');


SELECT 1 FROM ft1_nopw LIMIT 1;

RESET ROLE;

-- But the superuser can
ALTER USER MAPPING FOR regress_nosuper SERVER sqlite_nopw OPTIONS (ADD password_required 'false');

SET ROLE regress_nosuper;

-- Should finally work now
SELECT 1 FROM ft1_nopw LIMIT 1;

-- unpriv user also cannot set sslcert / sslkey on the user mapping
-- first set password_required so we see the right error messages
ALTER USER MAPPING FOR CURRENT_USER SERVER sqlite_nopw OPTIONS (SET password_required 'true');
ALTER USER MAPPING FOR CURRENT_USER SERVER sqlite_nopw OPTIONS (ADD sslcert 'foo.crt');
ALTER USER MAPPING FOR CURRENT_USER SERVER sqlite_nopw OPTIONS (ADD sslkey 'foo.key');

-- We're done with the role named after a specific user and need to check the
-- changes to the public mapping.
DROP USER MAPPING FOR CURRENT_USER SERVER sqlite_nopw;

-- This will fail again as it'll resolve the user mapping for public, which
-- lacks password_required=false
SELECT 1 FROM ft1_nopw LIMIT 1;

RESET ROLE;

-- The user mapping for public is passwordless and lacks the password_required=false
-- mapping option, but will work because the current user is a superuser.
SELECT 1 FROM ft1_nopw LIMIT 1;

-- cleanup
DROP USER MAPPING FOR public SERVER sqlite_nopw;
DROP OWNED BY regress_nosuper;
DROP ROLE regress_nosuper;

-- Clean-up
RESET enable_partitionwise_aggregate;
*/
-- Two-phase transactions are not supported.
BEGIN;
--Testcase 731:
SELECT count(*) FROM ft1;
-- error here
--Testcase 732:
PREPARE TRANSACTION 'fdw_tpc';
ROLLBACK;

-- ===================================================================
-- reestablish new connection
-- ===================================================================
-- -- Test case relative with option application_name is not suitable for SQLite FDW.
-- -- Because this option is in libpq of postgres.
-- -- Change application_name of remote connection to special one
-- -- so that we can easily terminate the connection later.
-- ALTER SERVER sqlite_svr OPTIONS (application_name 'fdw_retry_check');
-- -- If debug_discard_caches is active, it results in
-- -- dropping remote connections after every transaction, making it
-- -- impossible to test termination meaningfully.  So turn that off
-- -- for this test.
-- SET debug_discard_caches = 0;
-- -- Make sure we have a remote connection.
-- SELECT 1 FROM ft1 LIMIT 1;
-- -- Terminate the remote connection and wait for the termination to complete.
-- SELECT pg_terminate_backend(pid, 180000) FROM pg_stat_activity
-- 	WHERE application_name = 'fdw_retry_check';
-- -- This query should detect the broken connection when starting new remote
-- -- transaction, reestablish new connection, and then succeed.
-- BEGIN;
-- SELECT 1 FROM ft1 LIMIT 1;
-- -- If we detect the broken connection when starting a new remote
-- -- subtransaction, we should fail instead of establishing a new connection.
-- -- Terminate the remote connection and wait for the termination to complete.
-- SELECT pg_terminate_backend(pid, 180000) FROM pg_stat_activity
-- 	WHERE application_name = 'fdw_retry_check';
-- SAVEPOINT s;
-- -- The text of the error might vary across platforms, so only show SQLSTATE.
-- \set VERBOSITY sqlstate
-- SELECT 1 FROM ft1 LIMIT 1;    -- should fail
-- \set VERBOSITY default
-- COMMIT;

-- RESET debug_discard_caches;

-- =============================================================================
-- test connection invalidation cases and sqlite_fdw_get_connections function
-- =============================================================================
-- Let's ensure to close all the existing cached connections.
--Testcase 880:
SELECT 1 FROM sqlite_fdw_disconnect_all();
-- No cached connections, so no records should be output.
--Testcase 881:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;
-- This test case is for closing the connection in sqlitefdw_xact_callback
BEGIN;
-- Connection xact depth becomes 1 i.e. the connection is in midst of the xact.
--Testcase 882:
SELECT 1 FROM ft1 LIMIT 1;
--Testcase 883:
SELECT 1 FROM ft7 LIMIT 1;
-- List all the existing cached connections. sqlite_svr and sqlite_svr3 should be
-- output.
--Testcase 884:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;
-- Connections are not closed at the end of the alter and drop statements.
-- That's because the connections are in midst of this xact,
-- they are just marked as invalid in sqlitefdw_inval_callback.
--Testcase 885:
ALTER SERVER sqlite_svr OPTIONS (ADD keep_connections 'off');
--Testcase 886:
DROP SERVER sqlite_svr3 CASCADE;
-- List all the existing cached connections. sqlite_svr and sqlite_svr3
-- should be output as invalid connections. Also the server name for
-- sqlite_svr3 should be NULL because the server was dropped.
--Testcase 887:
SELECT * FROM sqlite_fdw_get_connections() ORDER BY 1;
-- The invalid connections get closed in sqlitefdw_xact_callback during commit.
COMMIT;
--Testcase 888:
ALTER SERVER sqlite_svr OPTIONS (DROP keep_connections);
-- All cached connections were closed while committing above xact, so no
-- records should be output.
--Testcase 889:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;

-- =======================================================================
-- test sqlite_fdw_disconnect and sqlite_fdw_disconnect_all functions
-- =======================================================================
BEGIN;
-- Ensure to cache loopback connection.
--Testcase 890:
SELECT 1 FROM ft1 LIMIT 1;
-- Ensure to cache loopback2 connection.
--Testcase 891:
SELECT 1 FROM ft6 LIMIT 1;
-- List all the existing cached connections. sqlite_svr and sqlite_svr2 should be
-- output.
--Testcase 892:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;
-- Issue a warning and return false as sqlite_svr connection is still in use and
-- can not be closed.
--Testcase 893:
SELECT sqlite_fdw_disconnect('sqlite_svr');
-- List all the existing cached connections. sqlite_svr and sqlite_svr2 should be
-- output.
--Testcase 894:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;
-- Return false as connections are still in use, warnings are issued.
-- But disable warnings temporarily because the order of them is not stable.
--Testcase 895:
SET client_min_messages = 'ERROR';
--Testcase 896:
SELECT sqlite_fdw_disconnect_all();
--Testcase 897:
RESET client_min_messages;
COMMIT;
-- Ensure that sqlite_svr2 connection is closed.
--Testcase 898:
SELECT 1 FROM sqlite_fdw_disconnect('sqlite_svr2');
--Testcase 899:
SELECT server_name FROM sqlite_fdw_get_connections() WHERE server_name = 'sqlite_svr2';
-- Return false as sqlite_svr2 connection is closed already.
--Testcase 900:
SELECT sqlite_fdw_disconnect('sqlite_svr2');
-- Return an error as there is no foreign server with given name.
--Testcase 901:
SELECT sqlite_fdw_disconnect('unknownserver');
-- Let's ensure to close all the existing cached connections.
--Testcase 902:
SELECT 1 FROM sqlite_fdw_disconnect_all();
-- No cached connections, so no records should be output.
--Testcase 903:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;

-- =============================================================================
-- test case for having multiple cached connections for a foreign server
-- =============================================================================
--Testcase 904:
CREATE ROLE regress_multi_conn_user1 SUPERUSER;
--Testcase 905:
CREATE ROLE regress_multi_conn_user2 SUPERUSER;
--Testcase 906:
CREATE USER MAPPING FOR regress_multi_conn_user1 SERVER sqlite_svr;
--Testcase 907:
CREATE USER MAPPING FOR regress_multi_conn_user2 SERVER sqlite_svr;

BEGIN;
-- Will cache sqlite_svr connection with user mapping for regress_multi_conn_user1
--Testcase 908:
SET ROLE regress_multi_conn_user1;
--Testcase 909:
SELECT 1 FROM ft1 LIMIT 1;
--Testcase 910:
RESET ROLE;

-- Will cache sqlite_svr connection with user mapping for regress_multi_conn_user2
--Testcase 911:
SET ROLE regress_multi_conn_user2;
--Testcase 912:
SELECT 1 FROM ft1 LIMIT 1;
--Testcase 913:
RESET ROLE;

-- Should output two connections for sqlite_svr server
--Testcase 914:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;
COMMIT;
-- Let's ensure to close all the existing cached connections.
--Testcase 915:
SELECT 1 FROM sqlite_fdw_disconnect_all();
-- No cached connections, so no records should be output.
--Testcase 916:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;

-- Clean up
--Testcase 917:
DROP USER MAPPING FOR regress_multi_conn_user1 SERVER sqlite_svr;
--Testcase 918:
DROP USER MAPPING FOR regress_multi_conn_user2 SERVER sqlite_svr;
--Testcase 919:
DROP ROLE regress_multi_conn_user1;
--Testcase 920:
DROP ROLE regress_multi_conn_user2;

-- ===================================================================
-- Test foreign server level option keep_connections
-- ===================================================================
-- By default, the connections associated with foreign server are cached i.e.
-- keep_connections option is on. Set it to off.
--Testcase 921:
ALTER SERVER sqlite_svr OPTIONS (keep_connections 'off');
-- connection to sqlite_svr server is closed at the end of xact
-- as keep_connections was set to off.
--Testcase 922:
SELECT 1 FROM ft1 LIMIT 1;
-- No cached connections, so no records should be output.
--Testcase 923:
SELECT server_name FROM sqlite_fdw_get_connections() ORDER BY 1;
--Testcase 924:
ALTER SERVER sqlite_svr OPTIONS (SET keep_connections 'on');

-- ===================================================================
-- batch insert
-- ===================================================================

BEGIN;

--Testcase 925:
CREATE SERVER batch10 FOREIGN DATA WRAPPER sqlite_fdw OPTIONS( batch_size '10' );

--Testcase 926:
SELECT count(*)
FROM pg_foreign_server
WHERE srvname = 'batch10'
AND srvoptions @> array['batch_size=10'];

--Testcase 927:
ALTER SERVER batch10 OPTIONS( SET batch_size '20' );

--Testcase 928:
SELECT count(*)
FROM pg_foreign_server
WHERE srvname = 'batch10'
AND srvoptions @> array['batch_size=10'];

--Testcase 929:
SELECT count(*)
FROM pg_foreign_server
WHERE srvname = 'batch10'
AND srvoptions @> array['batch_size=20'];

--Testcase 930:
CREATE FOREIGN TABLE table30 ( x int ) SERVER batch10 OPTIONS ( batch_size '30' );

--Testcase 931:
SELECT COUNT(*)
FROM pg_foreign_table
WHERE ftrelid = 'table30'::regclass
AND ftoptions @> array['batch_size=30'];

--Testcase 932:
ALTER FOREIGN TABLE table30 OPTIONS ( SET batch_size '40');

--Testcase 933:
SELECT COUNT(*)
FROM pg_foreign_table
WHERE ftrelid = 'table30'::regclass
AND ftoptions @> array['batch_size=30'];

--Testcase 934:
SELECT COUNT(*)
FROM pg_foreign_table
WHERE ftrelid = 'table30'::regclass
AND ftoptions @> array['batch_size=40'];

ROLLBACK;

--Testcase 935:
CREATE FOREIGN TABLE ftable ( x int OPTIONS (key 'true') ) SERVER sqlite_svr OPTIONS ( table 'batch_table', batch_size '10' );
--Testcase 936:
EXPLAIN (VERBOSE, COSTS OFF) INSERT INTO ftable SELECT * FROM generate_series(1, 10) i;
--Testcase 937:
INSERT INTO ftable SELECT * FROM generate_series(1, 10) i;
--Testcase 938:
INSERT INTO ftable SELECT * FROM generate_series(11, 31) i;
--Testcase 939:
INSERT INTO ftable VALUES (32);
--Testcase 940:
INSERT INTO ftable VALUES (33), (34);
--Testcase 941:
SELECT COUNT(*) FROM ftable;
--Testcase 942:
DELETE FROM ftable;
--Testcase 943:
DROP FOREIGN TABLE ftable;

-- try if large batches exceed max number of bind parameters
--Testcase 944:
CREATE FOREIGN TABLE ftable ( x int OPTIONS (key 'true') ) SERVER sqlite_svr OPTIONS ( table 'batch_table', batch_size '100000' );
--Testcase 945:
INSERT INTO ftable SELECT * FROM generate_series(1, 70000) i;
--Testcase 946:
SELECT COUNT(*) FROM ftable;
--Testcase 947:
DELETE FROM ftable;
--Testcase 948:
DROP FOREIGN TABLE ftable;

-- Disable batch insert
--Testcase 949:
CREATE FOREIGN TABLE ftable ( x int ) SERVER sqlite_svr OPTIONS ( table 'batch_table', batch_size '1' );
--Testcase 950:
EXPLAIN (VERBOSE, COSTS OFF) INSERT INTO ftable VALUES (1), (2);
--Testcase 951:
INSERT INTO ftable VALUES (1), (2);
--Testcase 952:
SELECT COUNT(*) FROM ftable;
--Testcase 953:
DROP FOREIGN TABLE ftable;
-- DROP TABLE batch_table;

-- -- Use partitioning
-- CREATE TABLE batch_table ( x int ) PARTITION BY HASH (x);

-- CREATE TABLE batch_table_p0 (LIKE batch_table);
-- CREATE FOREIGN TABLE batch_table_p0f
	-- PARTITION OF batch_table
	-- FOR VALUES WITH (MODULUS 3, REMAINDER 0)
	-- SERVER sqlite_svr
	-- OPTIONS (table 'batch_table_p0', batch_size '10');

-- CREATE TABLE batch_table_p1 (LIKE batch_table);
-- CREATE FOREIGN TABLE batch_table_p1f
	-- PARTITION OF batch_table
	-- FOR VALUES WITH (MODULUS 3, REMAINDER 1)
-- 	SERVER sqlite_svr
-- 	OPTIONS (table 'batch_table_p1', batch_size '1');

-- CREATE TABLE batch_table_p2
-- 	PARTITION OF batch_table
-- 	FOR VALUES WITH (MODULUS 3, REMAINDER 2);

-- INSERT INTO "S 1".batch_table SELECT * FROM generate_series(1, 66) i;
-- SELECT COUNT(*) FROM "S 1".batch_table;

-- -- Check that enabling batched inserts doesn't interfere with cross-partition
-- -- updates
-- CREATE TABLE batch_cp_upd_test (a int) PARTITION BY LIST (a);
-- CREATE TABLE batch_cp_upd_test1 (LIKE batch_cp_upd_test);
-- CREATE FOREIGN TABLE batch_cp_upd_test1_f
-- 	PARTITION OF batch_cp_upd_test
-- 	FOR VALUES IN (1)
-- 	SERVER sqlite_svr
-- 	OPTIONS (table_name 'batch_cp_upd_test1', batch_size '10');
-- CREATE TABLE batch_cp_up_test1 PARTITION OF batch_cp_upd_test
-- 	FOR VALUES IN (2);
-- INSERT INTO batch_cp_upd_test VALUES (1), (2);

-- -- The following moves a row from the local partition to the foreign one
-- UPDATE batch_cp_upd_test t SET a = 1 FROM (VALUES (1), (2)) s(a) WHERE t.a = s.a;
-- SELECT tableoid::regclass, * FROM batch_cp_upd_test;

-- -- Clean up
-- DROP TABLE batch_table, batch_cp_upd_test, batch_table_p0, batch_table_p1 CASCADE;

-- -- Use partitioning
-- ALTER SERVER loopback OPTIONS (ADD batch_size '10');

-- CREATE TABLE batch_table ( x int, field1 text, field2 text) PARTITION BY HASH (x);

-- CREATE TABLE batch_table_p0 (LIKE batch_table);
-- ALTER TABLE batch_table_p0 ADD CONSTRAINT p0_pkey PRIMARY KEY (x);
-- CREATE FOREIGN TABLE batch_table_p0f
-- 	PARTITION OF batch_table
-- 	FOR VALUES WITH (MODULUS 2, REMAINDER 0)
-- 	SERVER loopback
-- 	OPTIONS (table_name 'batch_table_p0');

-- CREATE TABLE batch_table_p1 (LIKE batch_table);
-- ALTER TABLE batch_table_p1 ADD CONSTRAINT p1_pkey PRIMARY KEY (x);
-- CREATE FOREIGN TABLE batch_table_p1f
-- 	PARTITION OF batch_table
-- 	FOR VALUES WITH (MODULUS 2, REMAINDER 1)
-- 	SERVER loopback
-- 	OPTIONS (table_name 'batch_table_p1');

-- INSERT INTO batch_table SELECT i, 'test'||i, 'test'|| i FROM generate_series(1, 50) i;
-- SELECT COUNT(*) FROM batch_table;
-- SELECT * FROM batch_table ORDER BY x;

-- ALTER SERVER loopback OPTIONS (DROP batch_size);

-- ===================================================================
-- test asynchronous execution
-- ===================================================================

-- ALTER SERVER loopback OPTIONS (DROP extensions);
-- ALTER SERVER loopback OPTIONS (ADD async_capable 'true');
-- ALTER SERVER loopback2 OPTIONS (ADD async_capable 'true');

-- CREATE TABLE async_pt (a int, b int, c text) PARTITION BY RANGE (a);
-- CREATE TABLE base_tbl1 (a int, b int, c text);
-- CREATE TABLE base_tbl2 (a int, b int, c text);
-- CREATE FOREIGN TABLE async_p1 PARTITION OF async_pt FOR VALUES FROM (1000) TO (2000)
--   SERVER loopback OPTIONS (table_name 'base_tbl1');
-- CREATE FOREIGN TABLE async_p2 PARTITION OF async_pt FOR VALUES FROM (2000) TO (3000)
--   SERVER loopback2 OPTIONS (table_name 'base_tbl2');
-- INSERT INTO async_p1 SELECT 1000 + i, i, to_char(i, 'FM0000') FROM generate_series(0, 999, 5) i;
-- INSERT INTO async_p2 SELECT 2000 + i, i, to_char(i, 'FM0000') FROM generate_series(0, 999, 5) i;
-- ANALYZE async_pt;

-- -- simple queries
-- CREATE TABLE result_tbl (a int, b int, c text);

-- EXPLAIN (VERBOSE, COSTS OFF)
-- INSERT INTO result_tbl SELECT * FROM async_pt WHERE b % 100 = 0;
-- INSERT INTO result_tbl SELECT * FROM async_pt WHERE b % 100 = 0;

-- SELECT * FROM result_tbl ORDER BY a;
-- DELETE FROM result_tbl;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- INSERT INTO result_tbl SELECT * FROM async_pt WHERE b === 505;
-- INSERT INTO result_tbl SELECT * FROM async_pt WHERE b === 505;

-- SELECT * FROM result_tbl ORDER BY a;
-- DELETE FROM result_tbl;

-- -- Check case where multiple partitions use the same connection
-- CREATE TABLE base_tbl3 (a int, b int, c text);
-- CREATE FOREIGN TABLE async_p3 PARTITION OF async_pt FOR VALUES FROM (3000) TO (4000)
--   SERVER loopback2 OPTIONS (table_name 'base_tbl3');
-- INSERT INTO async_p3 SELECT 3000 + i, i, to_char(i, 'FM0000') FROM generate_series(0, 999, 5) i;
-- ANALYZE async_pt;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- INSERT INTO result_tbl SELECT * FROM async_pt WHERE b === 505;
-- INSERT INTO result_tbl SELECT * FROM async_pt WHERE b === 505;

-- SELECT * FROM result_tbl ORDER BY a;
-- DELETE FROM result_tbl;

-- DROP FOREIGN TABLE async_p3;
-- DROP TABLE base_tbl3;

-- -- Check case where the partitioned table has local/remote partitions
-- CREATE TABLE async_p3 PARTITION OF async_pt FOR VALUES FROM (3000) TO (4000);
-- INSERT INTO async_p3 SELECT 3000 + i, i, to_char(i, 'FM0000') FROM generate_series(0, 999, 5) i;
-- ANALYZE async_pt;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- INSERT INTO result_tbl SELECT * FROM async_pt WHERE b === 505;
-- INSERT INTO result_tbl SELECT * FROM async_pt WHERE b === 505;

-- SELECT * FROM result_tbl ORDER BY a;
-- DELETE FROM result_tbl;

-- -- partitionwise joins
-- SET enable_partitionwise_join TO true;

-- CREATE TABLE join_tbl (a1 int, b1 int, c1 text, a2 int, b2 int, c2 text);

-- EXPLAIN (VERBOSE, COSTS OFF)
-- INSERT INTO join_tbl SELECT * FROM async_pt t1, async_pt t2 WHERE t1.a = t2.a AND t1.b = t2.b AND t1.b % 100 = 0;
-- INSERT INTO join_tbl SELECT * FROM async_pt t1, async_pt t2 WHERE t1.a = t2.a AND t1.b = t2.b AND t1.b % 100 = 0;

-- SELECT * FROM join_tbl ORDER BY a1;
-- DELETE FROM join_tbl;

-- RESET enable_partitionwise_join;

-- -- Test rescan of an async Append node with do_exec_prune=false
-- SET enable_hashjoin TO false;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- INSERT INTO join_tbl SELECT * FROM async_p1 t1, async_pt t2 WHERE t1.a = t2.a AND t1.b = t2.b AND t1.b % 100 = 0;
-- INSERT INTO join_tbl SELECT * FROM async_p1 t1, async_pt t2 WHERE t1.a = t2.a AND t1.b = t2.b AND t1.b % 100 = 0;

-- SELECT * FROM join_tbl ORDER BY a1;
-- DELETE FROM join_tbl;

-- RESET enable_hashjoin;

-- -- Test interaction of async execution with plan-time partition pruning
-- EXPLAIN (VERBOSE, COSTS OFF)
-- SELECT * FROM async_pt WHERE a < 3000;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- SELECT * FROM async_pt WHERE a < 2000;

-- -- Test interaction of async execution with run-time partition pruning
-- SET plan_cache_mode TO force_generic_plan;

-- PREPARE async_pt_query (int, int) AS
--   INSERT INTO result_tbl SELECT * FROM async_pt WHERE a < $1 AND b === $2;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- EXECUTE async_pt_query (3000, 505);
-- EXECUTE async_pt_query (3000, 505);

-- SELECT * FROM result_tbl ORDER BY a;
-- DELETE FROM result_tbl;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- EXECUTE async_pt_query (2000, 505);
-- EXECUTE async_pt_query (2000, 505);

-- SELECT * FROM result_tbl ORDER BY a;
-- DELETE FROM result_tbl;

-- RESET plan_cache_mode;

-- CREATE TABLE local_tbl(a int, b int, c text);
-- INSERT INTO local_tbl VALUES (1505, 505, 'foo'), (2505, 505, 'bar');
-- ANALYZE local_tbl;

-- CREATE INDEX base_tbl1_idx ON base_tbl1 (a);
-- CREATE INDEX base_tbl2_idx ON base_tbl2 (a);
-- CREATE INDEX async_p3_idx ON async_p3 (a);
-- ANALYZE base_tbl1;
-- ANALYZE base_tbl2;
-- ANALYZE async_p3;

-- ALTER FOREIGN TABLE async_p1 OPTIONS (use_remote_estimate 'true');
-- ALTER FOREIGN TABLE async_p2 OPTIONS (use_remote_estimate 'true');

-- EXPLAIN (VERBOSE, COSTS OFF)
-- SELECT * FROM local_tbl, async_pt WHERE local_tbl.a = async_pt.a AND local_tbl.c = 'bar';
-- EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
-- SELECT * FROM local_tbl, async_pt WHERE local_tbl.a = async_pt.a AND local_tbl.c = 'bar';
-- SELECT * FROM local_tbl, async_pt WHERE local_tbl.a = async_pt.a AND local_tbl.c = 'bar';

-- ALTER FOREIGN TABLE async_p1 OPTIONS (DROP use_remote_estimate);
-- ALTER FOREIGN TABLE async_p2 OPTIONS (DROP use_remote_estimate);

-- DROP TABLE local_tbl;
-- DROP INDEX base_tbl1_idx;
-- DROP INDEX base_tbl2_idx;
-- DROP INDEX async_p3_idx;

-- -- Test that pending requests are processed properly
-- SET enable_mergejoin TO false;
-- SET enable_hashjoin TO false;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- SELECT * FROM async_pt t1, async_p2 t2 WHERE t1.a = t2.a AND t1.b === 505;
-- SELECT * FROM async_pt t1, async_p2 t2 WHERE t1.a = t2.a AND t1.b === 505;

-- CREATE TABLE local_tbl (a int, b int, c text);
-- INSERT INTO local_tbl VALUES (1505, 505, 'foo');
-- ANALYZE local_tbl;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- SELECT * FROM local_tbl t1 LEFT JOIN (SELECT *, (SELECT count(*) FROM async_pt WHERE a < 3000) FROM async_pt WHERE a < 3000) t2 ON t1.a = t2.a;
-- EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
-- SELECT * FROM local_tbl t1 LEFT JOIN (SELECT *, (SELECT count(*) FROM async_pt WHERE a < 3000) FROM async_pt WHERE a < 3000) t2 ON t1.a = t2.a;
-- SELECT * FROM local_tbl t1 LEFT JOIN (SELECT *, (SELECT count(*) FROM async_pt WHERE a < 3000) FROM async_pt WHERE a < 3000) t2 ON t1.a = t2.a;

-- EXPLAIN (VERBOSE, COSTS OFF)
-- SELECT * FROM async_pt t1 WHERE t1.b === 505 LIMIT 1;
-- EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
-- SELECT * FROM async_pt t1 WHERE t1.b === 505 LIMIT 1;
-- SELECT * FROM async_pt t1 WHERE t1.b === 505 LIMIT 1;

-- -- Check with foreign modify
-- CREATE TABLE base_tbl3 (a int, b int, c text);
-- CREATE FOREIGN TABLE remote_tbl (a int, b int, c text)
--   SERVER loopback OPTIONS (table_name 'base_tbl3');
-- INSERT INTO remote_tbl VALUES (2505, 505, 'bar');

-- CREATE TABLE base_tbl4 (a int, b int, c text);
-- CREATE FOREIGN TABLE insert_tbl (a int, b int, c text)
--   SERVER loopback OPTIONS (table_name 'base_tbl4');

-- EXPLAIN (VERBOSE, COSTS OFF)
-- INSERT INTO insert_tbl (SELECT * FROM local_tbl UNION ALL SELECT * FROM remote_tbl);
-- INSERT INTO insert_tbl (SELECT * FROM local_tbl UNION ALL SELECT * FROM remote_tbl);

-- SELECT * FROM insert_tbl ORDER BY a;

-- -- Check with direct modify
-- EXPLAIN (VERBOSE, COSTS OFF)
-- WITH t AS (UPDATE remote_tbl SET c = c || c RETURNING *)
-- INSERT INTO join_tbl SELECT * FROM async_pt LEFT JOIN t ON (async_pt.a = t.a AND async_pt.b = t.b) WHERE async_pt.b === 505;
-- WITH t AS (UPDATE remote_tbl SET c = c || c RETURNING *)
-- INSERT INTO join_tbl SELECT * FROM async_pt LEFT JOIN t ON (async_pt.a = t.a AND async_pt.b = t.b) WHERE async_pt.b === 505;

-- SELECT * FROM join_tbl ORDER BY a1;
-- DELETE FROM join_tbl;

-- DROP TABLE local_tbl;
-- DROP FOREIGN TABLE remote_tbl;
-- DROP FOREIGN TABLE insert_tbl;
-- DROP TABLE base_tbl3;
-- DROP TABLE base_tbl4;

-- RESET enable_mergejoin;
-- RESET enable_hashjoin;

-- -- Test that UPDATE/DELETE with inherited target works with async_capable enabled
-- EXPLAIN (VERBOSE, COSTS OFF)
-- UPDATE async_pt SET c = c || c WHERE b = 0 RETURNING *;
-- UPDATE async_pt SET c = c || c WHERE b = 0 RETURNING *;
-- EXPLAIN (VERBOSE, COSTS OFF)
-- DELETE FROM async_pt WHERE b = 0 RETURNING *;
-- DELETE FROM async_pt WHERE b = 0 RETURNING *;

-- -- Check EXPLAIN ANALYZE for a query that scans empty partitions asynchronously
-- DELETE FROM async_p1;
-- DELETE FROM async_p2;
-- DELETE FROM async_p3;

-- EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
-- SELECT * FROM async_pt;

-- -- Clean up
-- DROP TABLE async_pt;
-- DROP TABLE base_tbl1;
-- DROP TABLE base_tbl2;
-- DROP TABLE result_tbl;
-- DROP TABLE join_tbl;

-- ALTER SERVER loopback OPTIONS (DROP async_capable);
-- ALTER SERVER loopback2 OPTIONS (DROP async_capable);

-- ===================================================================
-- test invalid server and foreign table options
-- ===================================================================
-- -- Invalid fdw_startup_cost option
-- CREATE SERVER inv_scst FOREIGN DATA WRAPPER postgres_fdw
-- 	OPTIONS(fdw_startup_cost '100$%$#$#');
-- -- Invalid fdw_tuple_cost option
-- CREATE SERVER inv_scst FOREIGN DATA WRAPPER postgres_fdw
-- 	OPTIONS(fdw_tuple_cost '100$%$#$#');
-- -- Invalid fetch_size option
-- CREATE FOREIGN TABLE inv_fsz (c1 int )
-- 	SERVER loopback OPTIONS (fetch_size '100$%$#$#');
-- Invalid batch_size option
--Testcase 954:
CREATE FOREIGN TABLE inv_bsz (c1 int )
	SERVER sqlite_svr OPTIONS (batch_size '100$%$#$#');

-- Clean-up
--Testcase 733:
DROP USER MAPPING FOR CURRENT_USER SERVER sqlite_svr;
--Testcase 734:
DROP USER MAPPING FOR CURRENT_USER SERVER sqlite_svr2;
--Testcase 735:
DROP SERVER sqlite_svr CASCADE;
--Testcase 736:
DROP SERVER sqlite_svr2 CASCADE;
--Testcase 737:
DROP EXTENSION sqlite_fdw CASCADE;
