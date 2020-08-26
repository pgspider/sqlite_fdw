# SQLite Foreign Data Wrapper for PostgreSQL
This PostgreSQL extension is a Foreign Data Wrapper for [SQLite][1].

The current version can work with PostgreSQL 9.6, 10, 11 and 12.

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
- Support update to foreign table  
- WHERE clauses are pushdowned  
- Aggregate function are pushdowned
- Order By is pushdowned.
- Limit and Offset are pushdowned (*when all tables queried are fdw)
- Transactions  

## Limitations
- `COPY` command for foreign tables is not supported
- Insert into a partitioned table which has foreign partitions is not supported
## Contributing
Opening issues and pull requests on GitHub are welcome.

## License
Copyright (c) 2017 - 2019, TOSHIBA Corporation  
Copyright (c) 2011 - 2016, EnterpriseDB Corporation  

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

See the [`LICENSE`][4] file for full details.

[1]: https://www.sqlite.org/index.html
[2]: https://www.sqlite.org/download.html
[3]: https://www.sqlite.org/howtocompile.html
[4]: LICENSE
