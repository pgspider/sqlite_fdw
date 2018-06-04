sqlite_fdw
==========

PostgreSQL Foreign Data Wrapper for SQLite

Currently this FDW is tested on PostgreSQL10 and 9.6.

Feature
-----------
- Support update to foreign table
- WHERE pushdown
- Aggregate pushdown(PG10 only)
- Transaction

Install
-----------
<pre>
make
make install
</pre>


Usage
--------

Load extension:
<pre>
CREATE EXTENSION sqlite_fdw;
</pre>

Create server specifying SQLite database path as option:
<pre>
CREATE SERVER sqlite_server FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/test.db');
</pre>


Create foreign table:
<pre>
CREATE FOREIGN TABLE t1(a integer, b text) SERVER sqlite_server OPTIONS (table 't1_sqlite');
</pre>

Or you can use import foreign schema:
<pre>
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_server INTO public;
</pre>


Access foregin table:
<pre>
SELECT * FROM t1;
</pre>


License
--------
Copyright (c) 2017-2018, TOSHIBA Corporation
Copyright (c) 2011 - 2016, EnterpriseDB Corporation

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

See the LICENSE file for full details.