SQLite Foreign Data Wrapper for PostgreSQL
==========================================

This is a foreign data wrapper (FDW) to connect [PostgreSQL](https://www.postgresql.org/)
to [SQLite](https://sqlite.org/) database file. This FDW works with PostgreSQL 12, 13, 14, 15, 16 and confirmed with SQLite 3.42.0.

<img src="https://upload.wikimedia.org/wikipedia/commons/2/29/Postgresql_elephant.svg" align="center" height="100" alt="PostgreSQL"/>	+	<img src="https://upload.wikimedia.org/wikipedia/commons/3/38/SQLite370.svg" align="center" height="100" alt="SQLite"/>

Contents
--------

1. [Features](#features)
2. [Supported platforms](#supported-platforms)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Functions](#functions)
6. [Identifier case handling](#identifier-case-handling)
7. [Generated columns](#generated-columns)
8. [Character set handling](#character-set-handling)
9. [Examples](#examples)
10. [Limitations](#limitations)
11. [Tests](#tests)
12. [Contributing](#contributing)
13. [Useful links](#useful-links)

Features
--------

### Common features
- Transactions
- Support `INSERT`/`UPDATE`/`DELETE` (both Direct modification and Foreign modification).
- Support `TRUNCATE` by deparsing into `DELETE` statement without `WHERE` clause
- Allow control over whether foreign servers keep connections open after transaction completion. This is controlled by `keep_connections` and defaults to on
- Support list cached connections to foreign servers by using function `sqlite_fdw_get_connections()`
- Support discard cached connections to foreign servers by using function `sqlite_fdw_disconnect()`, `sqlite_fdw_disconnect_all()`.
- Support Bulk `INSERT` by using `batch_size` option
- Support `INSERT`/`UPDATE` with generated column
- Support `ON CONFLICT DO NOTHING`.

### Pushdowning
- `WHERE` clauses are pushdowned
- Aggregate function are pushdowned
- `ORDER BY` is pushdowned
- Joins (left/right/inner/cross) are pushdowned
- `CASE` expressions are pushdowned.
- `LIMIT` and `OFFSET` are pushdowned (*when all tables queried are fdw)
- Support `GROUP BY`, `HAVING` push-down.
- `mod()` is pushdowned. In PostgreSQL gives [argument-dependend data type](https://www.postgresql.org/docs/current/functions-math.html), but result from SQLite always [have `real` affinity](https://www.sqlite.org/lang_mathfunc.html#mod).
- `upper`, `lower` and other character case functions are **not** pushed down because they does not work with UNICODE character in SQLite.
- `WITH TIES` option is **not** pushed down.
- Bit string `#` (XOR) operator is **not** pushed down becasuse there is no equal SQLite operator.

### Notes about pushdowning

- For push-down case, the number after floating point may be different from the result of PostgreSQL.

### Notes about features
- SQLite evaluates division by zero as `NULL`. It is different from PostgreSQL, which will display `Division by zero` error.
- The data type of column of foreign table should match with data type of column in SQLite to avoid wrong result. For example, if the column of SQLite is `float` (which will be stored as `float8`), the column of foreign table should be `float8`, too. If the column of foreign table is `float4`, it may cause wrong result when `SELECT`.
- For `key` option, user needs to specify the primary key column of SQLite table corresponding with the `key` option. If not, wrong result may occur when `UPDATE` or `DELETE`.
- When `Sum` of data in table is out of range, `sqlite_fdw` will display `Infinity` value. It is different from PostgreSQL FDW, which will display `ERROR: value out of range: overflow` error.
- For `numeric` data type, `sqlite_fdw` use `sqlite3_column_double` to get value, while SQLite shell uses `sqlite3_column_text` to get value. Those 2 APIs may return different numeric value. Therefore, for `numeric` data type, the value returned from `sqlite_fdw` may different from the value returned from SQLite shell.
- `sqlite_fdw` can return implementation-dependent order for column if the column is not specified in `ORDER BY` clause.
- When the column type is `varchar array`, if the string is shorter than the declared length, values of type character will be space-padded; values of type `character varying` will simply store the shorter string.

Also see [Limitations](#limitations)

Supported platforms
-------------------

`sqlite_fdw` was developed on Linux and should run on any
reasonably POSIX-compliant system.

Installation
------------

### Package installation

For some Linux distributives internal packages with `sqlite_fdw` are avalilable.

- [sqlite_fdw_14 rpm](https://pkgs.org/download/sqlite_fdw_14(x86-64)) for CentOS 9, RHEL 9, Rocky Linux 9, AlmaLinux 9. Also there is other versions.
- [sqlite_fdw git package](https://aur.archlinux.org/packages/sqlite_fdw) for Arch Linux.

### Source installation

Prerequisites:
* `libsqlite3-dev`, especially `sqlite.h`
* `postgresql-server-dev`, especially `postgres.h`
* `gcc`
* `make`

#### 1. Install SQLite & Postgres Development Libraries

For Debian or Ubuntu:
`apt-get install libsqlite3-dev`
`apt-get install postgresql-server-dev-XX`, where XX matches your postgres version, i.e. `apt-get install postgresql-server-dev-15`

You can also [download SQLite source code][1] and [build SQLite][2] with FTS5 for full-text search.

#### 2. Build and install sqlite_fdw

Add a directory of `pg_config` to PATH and build and install `sqlite_fdw`.

```sh
make USE_PGXS=1
make install USE_PGXS=1
```

If you want to build `sqlite_fdw` in a source tree of PostgreSQL, use
```sh
make
make install
```

Usage
-----

### Datatypes
**WARNING! The table above represents roadmap**, work still in progress. Untill it will be ended please refer real behaviour in non-obvious cases, where there is no ✔ or ∅ mark.

This table represents `sqlite_fdw` behaviour if in PostgreSQL foreign table column some [affinity](https://www.sqlite.org/datatype3.html) of SQLite data is detected. Some details about data values support see in [limitations](#limitations).

* **∅** - no support (runtime error)
* **V** - transparent transformation
* **b** - show per-bit form
* **T** - cast to text in SQLite utf-8 encoding, then to **PostgreSQL text with current encoding of database** and then transparent transformation if applicable
* **✔** - transparent transformation where PostgreSQL datatype is equal to SQLite affinity
* **V+** - transparent transformation if appliacable
* **?** - not described/not tested
* **-** - transparent transformation is possible for PostgreSQL (always or for some special values), but not implemented in `sqlite_fdw`.

SQLite `NULL` affinity always can be transparent converted for a nullable column in PostgreSQL.

| PostgreSQL   | SQLite <br> INT  | SQLite <br> REAL | SQLite <br> BLOB | SQLite <br> TEXT | SQLite <br> TEXT but <br>empty|SQLite<br>nearest<br>affinity|
|-------------:|:------------:|:------------:|:------------:|:------------:|:------------:|-------------:|
|         bool |      V       |       ?      |      T       |      -       |      ∅       | INT          |
|       bit(n) |    V n<=64   |       ∅      |      V       |      ?       |      ∅       | INT          |
|        bytea |      b       |       b      |      ✔       |      -       |      ?       | BLOB         |
|         date |      V       |       V      |      T       |      V+      |    `NULL`    | ?            |
|       float4 |      V+      |       ✔      |      T       |      -       |    `NULL`    | REAL         |
|       float8 |      V+      |       ✔      |      T       |      -       |    `NULL`    | REAL         |
|         int2 |      ✔       |       ?      |      T       |      -       |    `NULL`    | INT          |
|         int4 |      ✔       |       ?      |      T       |      -       |    `NULL`    | INT          |
|         int8 |      ✔       |       ?      |      T       |      -       |    `NULL`    | INT          |
|         json |      ?       |       ?      |      T       |      V+      |      ?       | TEXT         |
|         name |      ?       |       ?      |      T       |      V       |    `NULL`    | TEXT         |
|      numeric |      V       |       V      |      T       |      ∅       |    `NULL`    | REAL         |
|         text |      ?       |       ?      |      T       |      ✔       |      V       | TEXT         |
|         time |      V       |       V      |      T       |      V+      |    `NULL`    | ?            |
|    timestamp |      V       |       V      |      T       |      V+      |    `NULL`    | ?            |
|timestamp + tz|      V       |       V      |      T       |      V+      |    `NULL`    | ?            |
|         uuid |      ∅       |       ∅      |V+<br>(only<br>16 bytes)| V+ |      ∅       | TEXT, BLOB   |
|      varchar |      ?       |       ?      |      T       |      ✔       |      V       | TEXT         |
|    varbit(n) |    V n<=64   |       ∅      |      V       |      ?       |      ∅       | INT          |

### CREATE SERVER options

`sqlite_fdw` accepts the following options via the `CREATE SERVER` command:

- **database** as *string*, **required**, no default

  SQLite database path.

- **updatable** as *boolean*, optional, default *true*

  This option allow or disallow write operations on SQLite database file.

- **truncatable** as *boolean*, optional, default *true*

  Allows foreign tables to be truncated using the `TRUNCATE` command.

- **keep_connections** as *boolean*, optional, default *true*

  Allows to keep connections to SQLite while there is no SQL operations between PostgreSQL and SQLite.

- **batch_size** as *integer*, optional, default *1*

  Specifies the number of rows which should be inserted in a single `INSERT` operation. This setting can be overridden for individual tables.

### CREATE USER MAPPING options

There is no user or password conceptions in SQLite, hence `sqlite_fdw` no need any `CREATE USER MAPPING` command.

In OS `sqlite_fdw` works as executed code with permissions of user of PostgreSQL server. Usually it is `postgres` OS user. For interacting with SQLite database without access errors ensure this user have follow permissions:
- read permission on all directories by path to the SQLite database file;
- read permission on SQLite database file;
- write permissions both on SQLite database file and *directory it contains* if you need a modification. During `INSERT`, `UPDATE` or `DELETE` in SQLite database, SQLite engine functions makes temporary files with transaction data in the directory near SQLite database file. Hence without write permissions you'll have a message `failed to execute remote SQL: rc=8 attempt to write a readonly database`.

### CREATE FOREIGN TABLE options

`sqlite_fdw` accepts the following table-level options via the
`CREATE FOREIGN TABLE` command:

- **table** as *string*, optional, no default

  SQLite table name. Use if not equal to name of foreign table in PostgreSQL. Also see about [identifier case handling](#identifier-case-handling).

- **truncatable** as *boolean*, optional, default from the same `CREATE SERVER` option

  See `CREATE SERVER` options section for details.

- **batch_size** as *integer*, optional, default from the same `CREATE SERVER` option

  See `CREATE SERVER` options section for details.

- **updatable** as *boolean*, optional, default *true*

  This option can allow or disallow write operations on a SQLite table independed of the same server option.

`sqlite_fdw` accepts the following column-level options via the
`CREATE FOREIGN TABLE` command:

- **column_name** as *string*, optional, no default

  This option gives the column name to use for the column on the remote server. Also see about [identifier case handling](#identifier-case-handling).

- **column_type** as *string*, optional, no default

	Gives preferred SQLite affinity for some PostgreSQL data types can be stored in different ways in SQLite. Default preferred SQLite affinity for this types is `text`.
	
  - Use `INT` value for SQLite column (epoch Unix Time) to be treated/visualized as `timestamp` in PostgreSQL.
  - Use `BLOB` value for SQLite column to be treated/visualized as `uuid` in PostgreSQL.

- **key** as *boolean*, optional, default *false*

  Indicates a column as a part of primary key or unique key of SQLite table.

### IMPORT FOREIGN SCHEMA options

`sqlite_fdw` supports [IMPORT FOREIGN SCHEMA](https://www.postgresql.org/docs/current/sql-importforeignschema.html)
(PostgreSQL 9.5+) and accepts following options via the `IMPORT FOREIGN SCHEMA` command:

- **import_default** as *boolean*, optional, default *false*

  Allow borrowing default values from SQLite table DDL.

- **import_not_null** as *boolean*, optional, default *true*

  Allow borrowing `NULL`/`NOT NULL` constraints from SQLite table DDL.

#### Datatype tranlsation rules for `IMPORT FOREIGN SCHEMA`

| SQLite       | PostgreSQL       |
|-------------:|:----------------:|
| int          | bigint           |
| char         | text             |
| clob         | text             |
| text         | text             |
| blob         | bytea            |
| real         | double precision |
| floa         | double precision |
| doub         | double precision |
| datetime     | timestamp        |
| time         | time             |
| date         | date             |

### TRUNCATE support

`sqlite_fdw` implements the foreign data wrapper `TRUNCATE` API, available
from PostgreSQL 14.

As SQlite does not provide a `TRUNCATE` command, it is simulated with a
simple unqualified `DELETE` operation.

Actually, `TRUNCATE ... CASCADE` can be simulated if we create child table of SQLite with foreign keys and `ON DELETE CASCADE`, and then executing `TRUNCATE` (which will be deparsed to `DELETE`).

Following restrictions apply:
 - `TRUNCATE ... RESTART IDENTITY` is not supported
 - SQLite tables with foreign key references can cause errors during truncating

Functions
---------

As well as the standard `sqlite_fdw_handler()` and `sqlite_fdw_validator()`
functions, `sqlite_fdw` provides the following user-callable utility functions:

- SETOF record **sqlite_fdw_get_connections**(server_name text, valid bool)

- bool **sqlite_fdw_disconnect**(text)

  Closes connection from PostgreSQL to SQLite in the current session.

- bool **sqlite_fdw_disconnect_all()**

- **sqlite_fdw_version()**;
Returns standard "version integer" as `major version * 10000 + minor version * 100 + bugfix`.
```
sqlite_fdw_version
--------------------
              20400
```
Identifier case handling
------------------------

PostgreSQL folds identifiers to lower case by default, SQLite is case insensetive by default
and doesn't differ uppercase and lowercase ASCII base latin letters. It's important
to be aware of potential issues with table and column names.

Following SQL isn't correct for SQLite: `Error: duplicate column name: a`, but is correct for PostgreSQL

```sql
	CREATE TABLE T (
	  "A" INTEGER,
	  "a" NUMERIC
	);
```
Following SQLs is correct for both SQLite and PostgreSQL because there is no column
names with ASCII base latin letters *only*.

```sql
	CREATE TABLE T_кир (
	  "А" INTEGER,
	  "а" NUMERIC
	);
	CREATE TABLE T_ελλ (
	  "Α" INTEGER,
	  "α" NUMERIC
	);
	CREATE TABLE T_dia (
	  "Ä" INTEGER,
	  "ä" NUMERIC
	);		
```

For SQLite there is no difference between

```sql
	SELECT * FROM t;   -- №1
	SELECT * FROM T;   -- №2
	SELECT * FROM "t"; -- №3
	SELECT * FROM "T"; -- №4
```
For PostgreSQL the query with comment `№4` is independend query to table `T`, not to table `t` as other queries.

If there is

```sql
	CREATE TABLE T (
	  A INTEGER,
	  b REAL
	);
```
in SQLite, both `a` and `A` , `b` and `B` columns will have the same real datasource in SQlite in follow foreign table:

```sql
	CREATE FOREIGN TABLE "SQLite test" (
	  "A" int4 NULL,
	  "B" float8 NULL,
	  "a" int8 NULL,
	  "b" numeric NULL
	)
	SERVER sqlite_server
	OPTIONS (table 'T');
```

Generated columns
-----------------

SQLite provides support for [generated columns](https://www.sqlite.org/gencol.html).
Behaviour of `sqlite_fdw` with this columns _isn't yet described_.

Note that while `sqlite_fdw` will `INSERT` or `UPDATE` the generated column value
in SQLite, there is nothing to stop the value being modified within SQLite,
and hence no guarantee that in subsequent `SELECT` operations the column will
still contain the expected generated value. This limitation also applies to
`postgres_fdw`.

For more details on generated columns see:

- [Generated Columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html)
- [CREATE FOREIGN TABLE](https://www.postgresql.org/docs/current/sql-createforeigntable.html)

Character set handling
----------------------

There is [no character set metadata](https://www.sqlite.org/search?s=d&q=character+set)
stored in SQLite, only [`PRAGMA encoding;`](https://www.sqlite.org/pragma.html#pragma_encoding) with UTF-only values (`UTF-8`, `UTF-16`, `UTF-16le`, `UTF-16be`). [SQLite text output function](https://www.sqlite.org/c3ref/column_blob.html) guarantees UTF-8 encoding.

When `sqlite_fdw` connects to a SQLite, all strings are interpreted acording the PostgreSQL database's server encoding.
It's not a problem if your PostgreSQL database encoding belongs to Unicode family. Otherewise interpretation transformation problems can occur. Some unproper for PostgreSQL database encoding characters will be replaced to default 'no such character' character or there will error like `character with byte sequence 0x** in encoding "UTF8" has no equivalent in encoding "**"`.

Character case functions such as `upper`, `lower` and other are not pushed down because they does not work with UNICODE character in SQLite.

`Sqlite_fdw` tested with PostgreSQL database encodings `EUC_JP`, `EUC_KR`, `ISO_8859_5`, `ISO_8859_6`, `ISO_8859_7`, `ISO_8859_8`, `LATIN1`, `LATIN2`, `LATIN3`, `LATIN4`, `LATIN5`, `LATIN6`, `LATIN7`, `LATIN8`, `LATIN9`, `LATIN9`, `LATIN10`, `WIN1250`, `WIN1251`, `WIN1252`, `WIN1253`, `WIN1254`, `WIN1255`, `WIN1256`, `WIN1257` and it's synomyms. Some other encodings also can be supported, but not tested.

Examples
--------

### Install the extension:

Once for a database you need, as PostgreSQL superuser.

```sql
	CREATE EXTENSION sqlite_fdw;
```

### Create a foreign server with appropriate configuration:

Once for a foreign datasource you need, as PostgreSQL superuser. Please specify SQLite database path using `database` option.

```sql
	CREATE SERVER sqlite_server
	FOREIGN DATA WRAPPER sqlite_fdw
	OPTIONS (
          database '/path/to/database'
	);
```

### Grant usage on foreign server to normal user in PostgreSQL:

Once for a normal user (non-superuser) in PostgreSQL, as PostgreSQL superuser. It is a good idea to use a superuser only where really necessary, so let's allow a normal user to use the foreign server (this is not required for the example to work, but it's secirity recomedation).

```sql
	GRANT USAGE ON FOREIGN SERVER sqlite_server TO pguser;
```
Where `pguser` is a sample user for works with foreign server (and foreign tables).

### User mapping

There is no user or password conceptions in SQLite, hence `sqlite_fdw` no need any `CREATE USER MAPPING` command. About access problems see in [CREATE USER MAPPING options](#create-user-mapping-options).

### Create foreign table
All `CREATE FOREIGN TABLE` SQL commands can be executed as a normal PostgreSQL user if there were correct `GRANT USAGE ON FOREIGN SERVER`. No need PostgreSQL supersuer for secirity reasons but also works with PostgreSQL supersuer.

Please specify `table` option if SQLite table name is different from foreign table name.

```sql
	CREATE FOREIGN TABLE t1 (
	  a integer,
	  b text
	)
	SERVER sqlite_server
	OPTIONS (
	  table 't1_sqlite'
	);
```

If you want to update tables, please add `OPTIONS (key 'true')` to a primary key or unique key like the following:

```sql
	CREATE FOREIGN TABLE t1(
	  a integer OPTIONS (key 'true'),
	  b text
	)
	SERVER sqlite_server
	OPTIONS (
	  table 't1_sqlite'
	);
```

If you need to convert INT SQLite column (epoch Unix Time) to be treated/visualized as `TIMESTAMP` in PostgreSQL, please add `OPTIONS (column_type 'INT')` when defining FOREIGN table at PostgreSQL like the following:

```sql
	CREATE FOREIGN TABLE t1(
	  a integer,
	  b text,
	  c timestamp without time zone OPTIONS (column_type 'INT')
	)
	SERVER sqlite_server
	OPTIONS (
	  table 't1_sqlite'
	);
```

As above, but with aliased column names:

```sql
	CREATE FOREIGN TABLE t1(
	  a integer,
	  b text OPTIONS (column_name 'test_id'),
	  c timestamp without time zone OPTIONS (column_type 'INT', column_name 'unixtime')
	)
	SERVER sqlite_server
	OPTIONS (
	  table 't1_sqlite'
	);
```

### Import a SQLite database as schema to PostgreSQL:

```sql
	IMPORT FOREIGN SCHEMA someschema
	FROM SERVER sqlite_server
	INTO public;
```

Note: `someschema` has no particular meaning and can be set to an arbitrary value.

### Access foreign table
For the table from previous examples

```sql
	SELECT * FROM t1;
```

Limitations
-----------

### SQL commands
- `COPY` command for foreign tables is not supported
- `IMPORT` of generated column is not supported
- `INSERT` into a partitioned table which has foreign partitions is not supported. Error `Not support partition insert` will display.
- `TRUNCATE` in `sqlite_fdw` always delete data of both parent and child tables (no matter user inputs `TRUNCATE table CASCADE` or `TRUNCATE table RESTRICT`) if there are foreign-keys references with `ON DELETE CASCADE` clause.
- `RETURNING` is not supported.

### Arrays
- `sqlite_fdw` only supports `ARRAY` const, for example, `ANY (ARRAY[1, 2, 3])` or `ANY ('{1, 2 ,3}')`.
- `sqlite_fdw` does not support `ARRAY` expression, for example, `ANY (ARRAY[c1, 1, c1+0])`.
- For `ANY(ARRAY)` clause, `sqlite_fdw` deparses it using `IN` operator.

### Numbers (range and precision)
- For `sum` function of SQLite, output of `sum(bigint)` is `integer` value. If input values are big, the overflow error may occurs on SQLite because it overflow within the range of signed 64bit. For PostgreSQL, it can calculate as over the precision of `bigint`, so overflow does not occur.
- SQLite promises to preserve the 15 most significant digits of a floating point value. The big value which exceed 15 most significant digits may become different value after inserted.
- SQLite does not support `numeric` type as PostgreSQL. Therefore, it does not allow to store numbers with too high precision and scale. Error out of range occurs.
- SQLite does not support special values for IEEE 754-2008 numbers such as `NaN`, `+Infinity` and `-Infinity` in SQL expressions with numeric context. Also SQLite can not store this values with `real` [affinity](https://www.sqlite.org/datatype3.html). In opposite to SQLite, PostgreSQL can store special values in columns belongs to `real` datatype family such as `float` or `double precision` and use arithmetic comparation for this values. In oppose to PostgreSQL, SQLite stores `NaN`, `+Infinity` and `-Infinity` as a text values. Also conditions with special literals (such as ` n < '+Infinity'` or ` m > '-Infinity'` ) isn't numeric conditions in SQLite and gives unexpected result after pushdowning in oppose to internal PostgreSQL calculations. During `INSERT INTO ... SELECT` or in `WHERE` conditions `sqlite_fdw` uses given by PostgreSQL standard case sensetive literals **only** in follow forms: `NaN`, `-Infinity`, `Infinity`, not original strings from `WHERE` condition. *This can caused selecting issues*.

### Boolean values
- `sqlite_fdw` boolean values support exists only for `bool` columns in foreign table. SQLite documentation recommends to store boolean as value with `integer` [affinity](https://www.sqlite.org/datatype3.html). `NULL` isn't converted, 1 converted to `true`, all other `NOT NULL` values converted to `false`. During `SELECT ... WHERE condition_column` condition converted only to `condition_column`.
- `sqlite_fdw` don't provides limited support of boolean values if `bool` column in foreign table mapped to SQLite `text` [affinity](https://www.sqlite.org/datatype3.html).

### UUID values
- `sqlite_fdw` UUID values support exists only for `uuid` columns in foreign table. SQLite documentation recommends to store UUID as value with both `blob` and `text` [affinity](https://www.sqlite.org/datatype3.html). `sqlite_fdw` can pushdown both reading and filtering both `text` and `blob` values.
- Expected affinity of UUID value in SQLite table determined by `column_type` option of the column
for `INSERT` and `UPDATE` commands.

### bit and varbit support
- `sqlite_fdw` PostgreSQL `bit`/`varbit` values support based on `int` SQLite data affinity, because there is no per bit operations for SQLite `blob` affinity data. Maximum SQLite `int` affinity value is 8 bytes length, hence maximum `bit`/`varbit` values length is 64 bits.
- `sqlite_fdw` doesn't pushdown `#` (XOR) operator becasuse there is no equal SQLite operator.

Tests
-----
Test directory have structure as following:

```sql
+---sql
|   +---12.15
|   |       filename1.sql
|   |       filename2.sql
|   |
|   +---13.11
|   |       filename1.sql
|   |       filename2.sql
|   |
.................
|   \---15.3
|          filename1.sql
|          filename2.sql
|
\---expected
|   +---12.15
|   |       filename1.out
|   |       filename2.out
|   |
|   +---13.11
|   |       filename1.out
|   |       filename2.out
|   |
.................
|   \---15.3
            filename1.out
            filename2.out
```
The test cases for each version are based on the test of corresponding version of PostgreSQL.
You can execute test by test.sh directly.
The version of PostgreSQL is detected automatically by $(VERSION) variable in Makefile.
The corresponding sql and expected directory will be used to compare the result. For example, for Postgres 15.0, you can execute "test.sh" directly, and the sql/15.0 and expected/15.0 will be used to compare automatically.

Contributing
------------

Opening issues and pull requests on GitHub are welcome.
For pull request, please make sure these items below for testing:
- Create test cases (if needed) for the latest version of PostgreSQL supported by `sqlite_fdw`. All error testcases should have a comment about test purpose.
- Execute test cases and update expectations for the latest version of PostgreSQL
- Test creation and execution for other PostgreSQL versions are welcome but not required.

Preferred code style see in PostgreSQL source codes. For example

```C
type
funct_name (type arg ...)
{
	for (;;)
	{
	}
	if ()
	{
	}
}
```
Useful links
------------

### Source

 - https://github.com/pgspider/sqlite_fdw
 - https://pgxn.org/dist/sqlite_fdw/

### General FDW Documentation

 - https://www.postgresql.org/docs/current/ddl-foreign-data.html
 - https://www.postgresql.org/docs/current/sql-createforeigndatawrapper.html
 - https://www.postgresql.org/docs/current/sql-createforeigntable.html
 - https://www.postgresql.org/docs/current/sql-importforeignschema.html
 - https://www.postgresql.org/docs/current/fdwhandler.html
 - https://www.postgresql.org/docs/current/postgres-fdw.html

### Other FDWs

 - https://wiki.postgresql.org/wiki/Fdw
 - https://pgxn.org/tag/fdw/

License
-------

Copyright (c) 2018, TOSHIBA CORPORATION
Copyright (c) 2011 - 2016, EnterpriseDB Corporation

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

See the [`License`][3] file for full details.

[1]: https://www.sqlite.org/download.html
[2]: https://www.sqlite.org/howtocompile.html
[3]: License
