CREATE EXTENSION sqlite_fdw;

--Testcase 1: read the content inserted during the initialisation of tests
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
select * from test_pragma_jms;
DROP SERVER server CASCADE;

--Testcase 2: tests for journal_mode 'delete'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlitefdw_test_core.db', journal_mode 'delete');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
SELECT * FROM test_pragma_jms;
INSERT INTO test_pragma_jms (attr) VALUES (1);

DROP SERVER server CASCADE;

--Testcase 3: tests for journal_mode 'truncate'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', journal_mode 'truncate');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
SELECT * FROM test_pragma_jms;
INSERT INTO test_pragma_jms (attr) VALUES (2);

DROP SERVER server CASCADE;

--Testcase 4: tests for journal_mode 'persist'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', journal_mode 'persist');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
SELECT * FROM test_pragma_jms;
INSERT INTO test_pragma_jms (attr) VALUES (3);

DROP SERVER server CASCADE;

--Testcase 5: tests for journal_mode 'memory'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', journal_mode 'memory');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
SELECT * FROM test_pragma_jms;
INSERT INTO test_pragma_jms (attr) VALUES (4);

DROP SERVER server CASCADE;

--Testcase 6: tests for journal_mode 'wal'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', journal_mode 'wal');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
SELECT * FROM test_pragma_jms;
INSERT INTO test_pragma_jms (attr) VALUES (5);

DROP SERVER server CASCADE;

--Testcase 7: tests for journal_mode 'off'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', journal_mode 'off');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
SELECT * FROM test_pragma_jms;
INSERT INTO test_pragma_jms (attr) VALUES (6);

DROP SERVER server CASCADE;

--Testcase 8: tests for wrong value of journal_mode
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', journal_mode 'WrongValue');

--Testcase 9: tests for synchronous 'off'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', synchronous 'off');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
INSERT INTO test_pragma_jms (attr) VALUES (7);
SELECT * FROM test_pragma_jms;

DROP SERVER server CASCADE;

--Testcase 10: tests for synchronous 'normal'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', synchronous 'normal');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
INSERT INTO test_pragma_jms (attr) VALUES (8);
SELECT * FROM test_pragma_jms;

DROP SERVER server CASCADE;

--Testcase 11: tests for synchronous 'full'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', synchronous 'full');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
INSERT INTO test_pragma_jms (attr) VALUES (9);
SELECT * FROM test_pragma_jms;

DROP SERVER server CASCADE;

--Testcase 12: tests for synchronous 'extra'
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', synchronous 'extra');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
INSERT INTO test_pragma_jms (attr) VALUES (10);
SELECT * FROM test_pragma_jms;

DROP SERVER server CASCADE;

--Testcase 13: tests for both journal_mode and synchronous
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', journal_mode 'wal', synchronous 'normal');
CREATE FOREIGN TABLE test_pragma_jms (
  attr int
) SERVER server;
INSERT INTO test_pragma_jms (attr) VALUES (11);
SELECT * FROM test_pragma_jms;

DROP SERVER server CASCADE;

--Testcase 14: tests for wrong value of synchronous
CREATE SERVER server FOREIGN DATA WRAPPER sqlite_fdw 
   	OPTIONS (database '/tmp/sqlitefdw_test_core.db', synchronous 'WrongValue');
DROP EXTENSION sqlite_fdw cascade;
