-- test for aggregate pushdown
--Testcase 1:
explain (costs off, verbose) select count(distinct a) from multiprimary;

--Testcase 2:
explain (costs off, verbose) select sum(b),max(b), min(b), avg(b) from multiprimary;

--Testcase 3:
explain (costs off, verbose) select sum(b+5)+2 from multiprimary group by b/2 order by b/2;

--Testcase 4:
explain (costs off, verbose) select sum(a) from multiprimary group by b having sum(a) > 0;

--Testcase 5:
explain (costs off, verbose) select sum(a) from multiprimary group by b having avg(a^2) > 0 and sum(a) > 0;

-- stddev and variance are not pushed down
--Testcase 6:
explain (costs off, verbose) select stddev(a) from multiprimary;
--Testcase 7:
explain (costs off, verbose) select sum(a) from multiprimary group by b having variance(a) > 0;