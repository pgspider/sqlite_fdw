# SQLite Foreign Data Wrapper for PostgreSQL
This PostgreSQL extension is a Foreign Data Wrapper for [SQLite][1].  
This version of sqlite_fdw can work with PostgreSQL 9.6 and 10.  

## 1. Installation
1. Preapre SQLite library  
    [Download SQLite source code][2] and [Build SQLite][3]  

2. Build and install sqlite_fdw

<pre>
make
make install
</pre>

## 2. Usage
### Load extension:
<pre>
CREATE EXTENSION sqlite_fdw;
</pre>

### Create server specifying SQLite database path as option:
<pre>
CREATE SERVER sqlite_server FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/test.db');
</pre>


### Create foreign table:
<pre>
CREATE FOREIGN TABLE t1(a integer, b text) SERVER sqlite_server OPTIONS (table 't1_sqlite');
</pre>

### Or you can use import foreign schema:
<pre>
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_server INTO public;
</pre>

### Access foregin table:
<pre>
SELECT * FROM t1;
</pre>

## 3. Features
- Support update to foreign table  
- WHERE clauses are pushdowned  
- Aggregate function are pushdowned (PostgreSQL 10 only)  
- Transactions  

## 4. Limitations
Nothing.

## 5. License
Copyright (c) 2017-2018, TOSHIBA Corporation  
Copyright (c) 2011 - 2016, EnterpriseDB Corporation  

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

See the [`LICENSE`][4] file for full details.

[1]: https://www.sqlite.org/index.html
[2]: https://www.sqlite.org/download.html
[3]: https://www.sqlite.org/howtocompile.html
[4]: LICENSE
