# SQLite Foreign Data Wrapper for PostgreSQL
This PostgreSQL extension is a Foreign Data Wrapper for [SQLite][1].

The current version can work with PostgreSQL 11, 12, 13, 14 and 15.

## Installation
### 1. Install SQLite library

For debian or ubuntu:
<pre>
apt-get install libsqlite3-dev
</pre>

You can also [download SQLite source code][2] and [build SQLite][3].

### 2. Build and install sqlite_fdw

Add a directory of pg_config to PATH and build and install sqlite_fdw.
<pre>
make USE_PGXS=1
make install USE_PGXS=1
</pre>

If you want to build sqlite_fdw in a source tree of PostgreSQL, use
<pre>
make
make install
</pre>

## Usage

### FDW options

| **No** | Option name | Context | Required | Description |
|--------|-------------|---------|----------|-------------|
| 1 | database | SERVER | Required | SQLite database path. |
| 2 | table | FOREIGN TABLE | Required | SQLite table name. |
| 3 | key | ATTRIBUTE | Optional | Primary key or unique key of SQLite table. |
| 4 | column_type | ATTRIBUTE | Optional | Option to convert INT SQLite column (epoch Unix Time) to be treated/visualized as TIMESTAMP in PostgreSQL. |
| 5 | column_name | ATTRIBUTE | Optional | This option gives the column name to use for the column on the remote server. |
| 6 | truncatable | SERVER,<br>FOREIGN TABLE | Optional | This option controls whether sqlite_fdw allows foreign tables to be truncated using the TRUNCATE command. |

### Load extension
<pre>
CREATE EXTENSION sqlite_fdw;
</pre>

### Create server
Please specify SQLite database path using `database` option:
<pre>
CREATE SERVER sqlite_server FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/test.db');
</pre>


### Create foreign table
Please specify `table` option if SQLite table name is different from foreign table name.
<pre>
CREATE FOREIGN TABLE t1(a integer, b text) SERVER sqlite_server OPTIONS (table 't1_sqlite');
</pre>

If you want to update tables, please add `OPTIONS (key 'true')` to a primary key or unique key like the following:
<pre>
CREATE FOREIGN TABLE t1(a integer OPTIONS (key 'true'), b text) SERVER sqlite_server OPTIONS (table 't1_sqlite');
</pre>

If you need to convert INT SQLite column (epoch Unix Time) to be treated/visualized as TIMESTAMP in PostgreSQL, please add `OPTIONS (column_type 'INT')` when
defining FOREIGN table at PostgreSQL like the following:
<pre>
CREATE FOREIGN TABLE t1(a integer, b text, c timestamp without time zone OPTIONS (column_type 'INT')) SERVER sqlite_server OPTIONS (table 't1_sqlite');
</pre>
### Import foreign schema
<pre>
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_server INTO public;
</pre>

### Access foreign table
<pre>
SELECT * FROM t1;
</pre>

## Features
- Support INSERT/UPDATE/DELETE (both Direct modification and Foreign modification).
- WHERE clauses are pushdowned  
- Aggregate function are pushdowned
- Order By is pushdowned
- Joins (left/right/inner/cross) are pushdowned
- CASE expressions are pushdowned.
- Limit and Offset are pushdowned (*when all tables queried are fdw)
- Transactions  
- Support TRUNCATE by deparsing into DELETE statement without WHERE clause  
- Allow control over whether foreign servers keep connections open after transaction completion. This is controlled by `keep_connections` and defaults to on  
- Support list cached connections to foreign servers by using function sqlite_fdw_get_connections()  
- Support discard cached connections to foreign servers by using function sqlite_fdw_disconnect(), sqlite_fdw_disconnect_all().  
- Support Bulk Insert by using batch_size option  
- Support Insert/Update with generated column  
- Support GROUP BY, HAVING push-down.
- Support ON CONFLICT DO NOTHING.
## Limitations
- `COPY` command for foreign tables is not supported
- IMPORT of generated column is not supported
- Insert into a partitioned table which has foreign partitions is not supported. Error "Not support partition insert" will display.
- TRUNCATE in sqlite_fdw always delete data of both parent and child tables (no matter user inputs `TRUNCATE table CASCADE` or `TRUNCATE table RESTRICT`) if there are foreign-keys references with "ON DELETE CASCADE" clause.
- RETURNING is not supported.

## Notes
- SQLite evaluates division by zero as NULL. It is different from PostgreSQL, which will display "Division by zero" error.
- The data type of column of foreign table should match with data type of column in SQLite to avoid wrong result. For example, if the column of SQLite is float (which will be stored as float8), the column of foreign table should be float8, too. If the column of foreign table is float4, it may cause wrong result when select.
- For 'key' option, user needs to specify the primary key column of SQLite table corresponding with the 'key' option. If not, wrong result may occur when update or delete.
- When Sum of data in table is out of range, SQLite FDW will display "Infinity" value. It is different from PostgreSQL FDW, which will display "ERROR: value out of range: overflow" error.
- For push-down case, the number after floating point may be different from the result of PostgreSQL.
- For numeric type, SQLite FDW use sqlite3_column_double to get value, while SQLite shell uses sqlite3_column_text to get value. Those 2 APIs may return different numeric value. Therefore, for numeric type, the value returned from SQLite FDW may different from the value returned from SQLite shell.
- SQLite FDW can return implementation-dependent order for column if the column is not specified in ORDER BY clause.
- WITH TIES option is not pushed down.
- upper, lower functions are not pushed down because they does not work with UNICODE character in SQLite.
- When the column type is varchar array, if the string is shorter than the declared length, values of type character will be space-padded; values of type character varying will simply store the shorter string.
- SQLite FDW only supports ARRAY const, for example, ANY (ARRAY[1, 2, 3]) or ANY ('{1, 2 ,3}'). SQlite FDW does not support ARRAY expression, for example, ANY (ARRAY[c1, 1, c1+0]). For ANY(ARRAY) clause, SQLite FDW deparses it using IN operator.
- For sum function of SQLite, output of sum(bigint) is integer value. If input values are big, the overflow error may occurs on SQLite because it overflow within the range of signed 64bit. For PostgreSQL, it can calculate as over the precision of bigint, so overflow does not occur.
- SQLite promises to preserve the 15 most significant digits of a floating point value. The big value which exceed 15 most significant digits may become different value after inserted.
## Contributing
Opening issues and pull requests on GitHub are welcome.

## License
Copyright (c) 2018, TOSHIBA CORPORATION
Copyright (c) 2011 - 2016, EnterpriseDB Corporation

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

See the [`LICENSE`][4] file for full details.

[1]: https://www.sqlite.org/index.html
[2]: https://www.sqlite.org/download.html
[3]: https://www.sqlite.org/howtocompile.html
[4]: LICENSE
