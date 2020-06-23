--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test.db');
CREATE FOREIGN TABLE multiprimary(a int, b int OPTIONS (key 'true'), c int OPTIONS(key 'true')) SERVER sqlite_svr;
-- test for aggregate pushdown
explain (costs off, verbose) select count(distinct a) from multiprimary;

explain (costs off, verbose) select sum(b),max(b), min(b), avg(b) from multiprimary;

explain (costs off, verbose) select sum(b+5)+2 from multiprimary group by b/2 order by b/2;

explain (costs off, verbose) select sum(a) from multiprimary group by b having sum(a) > 0;

explain (costs off, verbose) select sum(a) from multiprimary group by b having avg(a^2) > 0 and sum(a) > 0;

-- stddev and variance are not pushed down
explain (costs off, verbose) select stddev(a) from multiprimary;
explain (costs off, verbose) select sum(a) from multiprimary group by b having variance(a) > 0;

DROP FOREIGN TABLE multiprimary;
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw CASCADE;
