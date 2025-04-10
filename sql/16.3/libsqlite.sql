-- Test for SQLite library code source and defaults
--Testcase 1:
CREATE EXTENSION sqlite_fdw;
--Testcase 2:
SELECT sqlite_fdw_sqlite_version();
--Testcase 3:
SELECT length(sqlite_fdw_sqlite_code_source());
--Testcase 4:
SELECT sqlite_fdw_sqlite_code_source();

--Testcase 7:
DROP EXTENSION sqlite_fdw CASCADE;
