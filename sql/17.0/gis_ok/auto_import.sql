--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 01:
CREATE EXTENSION sqlite_fdw;
--Testcase 02:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

--Testcase 03:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

--Testcase 04:
IMPORT FOREIGN SCHEMA main FROM SERVER sqlite_svr INTO public;

--Testcase 05:
CREATE VIEW ft AS (
SELECT *, row_number() OVER () n
FROM information_schema.foreign_tables
WHERE foreign_table_catalog = current_database()
AND foreign_table_schema = 'public'
);
--Testcase 06:
SELECT * FROM ft;

--Testcase 07:
CREATE VIEW fc AS (
SELECT ft.n, table_name, column_name, ordinal_position tab_no, column_default def, is_nullable "null", data_type, character_maximum_length c_max_len, character_octet_length c_oct_len, numeric_precision num_pr, numeric_precision_radix num_rdx, numeric_scale num_sc, datetime_precision dtp, interval_type it, interval_precision ip, udt_schema, udt_name, maximum_cardinality max_crd, dtd_identifier dtdid, is_self_referencing sref, is_identity ididt,  is_generated isgen
FROM information_schema.columns c
INNER JOIN ft
ON (c.table_catalog, c.table_schema, c.table_name) = (ft.foreign_table_catalog, ft.foreign_table_schema, ft.foreign_table_name)
) order by n, tab_no;
--Testcase 08: base metadata
SELECT n, table_name, column_name, tab_no, def, "null", data_type, udt_schema, udt_name FROM fc;
--Testcase 09: size/length/presision metadata
SELECT n, table_name, column_name, tab_no, c_max_len, c_oct_len, num_pr, num_rdx, num_sc, dtp FROM fc;
--Testcase 10: other metadata
SELECT n, table_name, column_name, tab_no, it, ip, max_crd, dtdid, sref, ididt, isgen FROM fc;

--Testcase 11:
SELECT * FROM information_schema.column_options
WHERE (table_catalog, table_schema, table_name)
IN (SELECT foreign_table_catalog, foreign_table_schema, foreign_table_name FROM ft);

--Testcase 11:
DROP VIEW fc;
--Testcase 12:
DROP VIEW ft;

--Testcase 20:
SET client_min_messages TO ERROR;
--Testcase 21: no details
DROP EXTENSION sqlite_fdw CASCADE;
