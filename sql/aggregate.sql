-- test for aggregate pushdown
explain (costs off, verbose) select count(distinct a) from multiprimary;

explain (costs off, verbose) select sum(b),max(b), min(b), avg(b) from multiprimary;

explain (costs off, verbose) select sum(b+5)+2 from multiprimary group by b/2 order by b/2;

explain (costs off, verbose) select sum(a) from multiprimary group by b having sum(a) > 0;

explain (costs off, verbose) select sum(a) from multiprimary group by b having avg(a^2) > 0 and sum(a) > 0;

-- stddev and variance are not pushed down
explain (costs off, verbose) select stddev(a) from multiprimary;
explain (costs off, verbose) select sum(a) from multiprimary group by b having variance(a) > 0;