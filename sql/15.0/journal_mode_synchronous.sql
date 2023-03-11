CREATE EXTENSION sqlite_fdw;
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
select * from test_pragma_jms;