SQLite Foreign Data Wrapper for PostgreSQL
==========================================

This is a foreign data wrapper (FDW) to connect [PostgreSQL](https://www.postgresql.org/)
to [SQLite](https://sqlite.org/) database file. This FDW works with PostgreSQL 13, 14, 15, 16, 17 and confirmed with SQLite 3.46.0.

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
- Support `INSERT`/`UPDATE`/`DELETE` (both Direct modification and Foreign modification), see [access control](#connection-to-sqlite-database-file-and-access-control) about conditions of succesfully data modification.
- Support `TRUNCATE` by deparsing into `DELETE` statement without `WHERE` clause.
- Allow control over whether foreign servers keep connections open after transaction completion. This is controlled by `keep_connections` and defaults to on.
- Support list cached connections to foreign servers by using function `sqlite_fdw_get_connections()`
- Support discard cached connections to foreign servers by using function `sqlite_fdw_disconnect()`, `sqlite_fdw_disconnect_all()`.
- Support Bulk `INSERT` by using `batch_size` option
- Support `INSERT`/`UPDATE` with generated column
- Support `ON CONFLICT DO NOTHING`
- Support mixed SQLite [data affinity](https://www.sqlite.org/datatype3.html) input and filtering (`SELECT`/`WHERE` usage) for such data types as
	- `timestamp`: `text` and `int`,
	- `uuid`: `text`(32..39) and `blob`(16),
 	- `bool`: `text`(1..5) and `int`,
 	- `double precision`, `float` and `numeric`: `real` values and special values with `text` affinity (`+Infinity`, `-Infinity`, `NaN`),
 	- `macaddr`: `text`(12..17) or `blob`(6) or `integer`,
 	- `macaddr8`: `text`(16..23) or `blob`(8) or `integer`.
- Support mixed SQLite [data affinity](https://www.sqlite.org/datatype3.html) output (`INSERT`/`UPDATE`) for such data types as
	- `timestamp`: `text`(default) or `int`,
 	- `uuid`: `text`(36) or `blob`(16)(default),
 	- `macaddr`: `text`(17) or `blob`(6) or `integer`(default),
 	- `macaddr8`: `text`(23) or `blob`(8) or `integer`(default).
- Full support for `+Infinity` (means ∞) and `-Infinity` (means -∞) special values for IEEE 754-2008 numbers in `double precision`, `float` and `numeric` columns including such conditions as ` n < '+Infinity'` or ` m > '-Infinity'`.

### Pushdowning
- `WHERE` clauses are pushdowned
- Aggregate function are pushdowned
- `ORDER BY` is pushdowned
- Joins (left/right/inner/cross/semi) are pushdowned
- `CASE` expressions are pushdowned.
- `LIMIT` and `OFFSET` are pushdowned when all tables in the query are foreign tables belongs to the same PostgreSQL `FOREIGN SERVER` object.
- Support `GROUP BY`, `HAVING` push-down.
- `mod()` is pushdowned. In PostgreSQL this function gives [argument-dependend data type](https://www.postgresql.org/docs/current/functions-math.html), but result from SQLite always [have `real` affinity](https://www.sqlite.org/lang_mathfunc.html#mod).
- `upper`, `lower` and other character case functions are **not** pushed down because they does not work with UNICODE character in SQLite.
- `WITH TIES` option is **not** pushed down.
- Bit string `#` (XOR) operator is **not** pushed down because there is no equal SQLite operator.
- Operations with `macaddr` or `macaddr8` data are **not** pushdowned.

### Notes about pushdowning

- For push-down case, the number after floating point may be different from the result of PostgreSQL.

### Notes about features
- SQLite evaluates division by zero as `NULL`. It is different from PostgreSQL, which will display `Division by zero` error.
- The data type of column of foreign table should match with data type of column in SQLite to avoid wrong result. For example, if the column of SQLite is `float` (which will be stored as `float8`), the column of foreign table should be `float8`, too. If the column of foreign table is `float4`, it may cause wrong result when `SELECT`.
- For `key` option, user needs to specify the primary key column of SQLite table corresponding with the `key` option. If not, wrong result may occur when `UPDATE` or `DELETE`.
- When `sum` function result value is out of range, `sqlite_fdw` will display `Infinity` value. It is different from PostgreSQL, which gives `ERROR: value out of range: overflow` error.
- For `numeric` data type, `sqlite_fdw` use `sqlite3_column_double` to get value, while SQLite shell uses `sqlite3_column_text` to get value. Those 2 APIs may return different numeric value. Therefore, for `numeric` data type, the value returned from `sqlite_fdw` may different from the value returned from SQLite shell.
- `sqlite_fdw` can return implementation-dependent order for column if the column is not specified in `ORDER BY` clause.
- When the column type is `varchar array`, if the string is shorter than the declared length, values of type character will be space-padded; values of type `character varying` will simply store the shorter string.
- [String literals for `boolean`](https://www.postgresql.org/docs/current/datatype-boolean.html) (`t`, `f`, `y`, `n`, `yes`, `no`, `on`, `off` etc. case insensitive) can be readed and filtred but cannot writed, because SQLite documentation recommends only `int` affinity values (`0` or `1`)  for boolean data and usually text boolean data belongs to legacy datasets.

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

### CREATE SERVER options

`sqlite_fdw` accepts the following options via the `CREATE SERVER` command:

- **database** as *string*, **required**, no default

  SQLite database file address.

- **updatable** as *boolean*, optional, default *true*

  This option can allow or disallow data modification on foreign server for all foreign objects by default. Please note, this option can be overwritten on table level or have no effect because of some filesystem restrictions, see [connection to SQLite database file and access control](#connection-to-sqlite-database-file-and-access-control). This is only recommentadion of PostgreSQL foreign server owner user not to modify data in foreign server tables. For strong restriction see the next option `force_readonly`.

- **force_readonly** as *boolean*, optional, default *false*

  This option is useful if you need grant user permission to create a foreign tables on the foreign server and revoke user permission to modify any table data on this foreign server. This option with `true` value can disallow any write operations on foreign server table data through SQLite file readonly access mode. This option driven only by foreign server owner role can not be overwritten by any `updatable` option value. This is a strong restriction given by PostgreSQL foreign server owner user not to modify data in any foreign server tables. Also see [Connection to SQLite database file and access control](#connection-to-sqlite-database-file-and-access-control).

- **truncatable** as *boolean*, optional, default *false*

  Allows foreign tables to be truncated using the `TRUNCATE` command.

- **keep_connections** as *boolean*, optional, default *true*

  Allows to keep connections to SQLite while there is no SQL operations between PostgreSQL and SQLite.

- **batch_size** as *integer*, optional, default *1*

  Specifies the number of rows which should be inserted in a single `INSERT` operation. This setting can be overridden for individual tables.

### CREATE USER MAPPING options

There is no user or password conceptions in SQLite, hence `sqlite_fdw` no need any `CREATE USER MAPPING` command. About access model and possible data modifications problems see about [connection to SQLite database file and access control](#connection-to-sqlite-database-file-and-access-control).

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

  This option can allow or disallow data modification on separate foreign table. Please note, this option can have no effect if there is foreign server option `force_readonly` = `true` or depends on filesystem context, see about [connection to SQLite database file and access control](#connection-to-sqlite-database-file-and-access-control).

`sqlite_fdw` accepts the following column-level options via the
`CREATE FOREIGN TABLE` command:

- **column_name** as *string*, optional, no default

  This option gives the column name to use for the column on the remote server. Also see about [identifier case handling](#identifier-case-handling).

- **column_type** as *string*, optional, no default

	Set preferred SQLite affinity for some PostgreSQL data types can be stored in different ways
in SQLite (mixed affinity case). Updated and inserted values will have this affinity. Default preferred SQLite affinity for `timestamp` and `uuid` PostgreSQL data types is `text`.

  - Use `INT` value for SQLite column (epoch Unix Time) to be treated/visualized as `timestamp` in PostgreSQL.
  - Use `BLOB` value for SQLite column to be treated/visualized as `uuid`.

- **key** as *boolean*, optional, default *false*

  Indicates a column as a part of primary key or unique key of SQLite table.

### Datatypes
This table represents `sqlite_fdw` behaviour if in PostgreSQL foreign table column some [affinity](https://www.sqlite.org/datatype3.html) of SQLite data is detected. Some details about data values support see in [limitations](#limitations).

* **∅**  - no support (runtime error)
* **✔**  - 1↔1, PostgreSQL datatype is equal to SQLite affinity
* **✔-** - PostgreSQL datatype is equal to SQLite affinity, but possible out of range error
* **V**  - transparent transformation if possible
* **V+** - transparent transformation if possible
* **i**  - ISO:SQL transformation for some special constants
* **?** - not described/not tested
* **T** - cast to text in SQLite utf-8 encoding, then to **PostgreSQL text with current encoding of database** and then transformation for `text` affinity if applicable

SQLite `NULL` affinity always can be transparent converted for a nullable column in PostgreSQL.

**SQLite data processing dependend on affinity**

|  PostgreSQL  |     INT      |     REAL     |    BLOB      |    TEXT      | TEXT but <br>empty|nearest<br>affinity|
|-------------:|:------------:|:------------:|:------------:|:------------:|:------------:|-------------:|
|         bool |      V       |       ∅      |      T       |      i       |      ∅       | INT          |
|       bit(n) | V<br>(n<=64) |       ∅      |      ∅       |      ∅       |      ∅       | INT          |
|        bytea |      ∅       |       ∅      |      ✔       |      V       |      ?       | BLOB         |
|      char(n) |      ?       |       ?      |      T       |      ✔       |      V       | TEXT         |
|         date |      V       |       V      |      T       |      V+      |    `NULL`    | ?            |
|       float4 |      V+      |       ✔      |      ∅       |      i       |    `NULL`    | REAL         |
|       float8 |      V+      |       ✔      |      ∅       |      i       |    `NULL`    | REAL         |
|         int2 |      ✔-      |       ?      |      ∅       |      ∅       |    `NULL`    | INT          |
|         int4 |      ✔-      |       ?      |      ∅       |      ∅       |    `NULL`    | INT          |
|         int8 |      ✔       |       ?      |      ∅       |      ∅       |    `NULL`    | INT          |
|         json |      ?       |       ?      |      T       |      V+      |      ?       | TEXT         |
|      macaddr |      ✔-      |       ∅      | V<br>(Len=6b)|      V+      |      ?       | INT          |
|     macaddr8 |      ✔       |       ∅      | V<br>(Len=8b)|      V+      |      ?       | INT          |
|         name |      ?       |       ?      |      T       |      i       |    `NULL`    | TEXT         |
|      numeric |      V       |       V      |      T       |      i       |    `NULL`    | REAL         |
|         text |      ?       |       ?      |      T       |      ✔       |      V       | TEXT         |
|         time |      V       |       V      |      T       |      V+      |    `NULL`    | ?            |
|    timestamp |      V       |       V      |      T       |      V+      |    `NULL`    | ?            |
|timestamp + tz|      V       |       V      |      T       |      V+      |    `NULL`    | ?            |
|         uuid |      ∅       |       ∅      |V+<br>(Len=16b)|     V+      |      ∅       | TEXT, BLOB   |
|   varchar(n) |      ?       |       ?      |      T       |      ✔       |      V       | TEXT         |
|    varbit(n) | V<br>(n<=64) |       ∅      |      ∅       |      ∅       |      ∅       | INT          |

### IMPORT FOREIGN SCHEMA options

`sqlite_fdw` supports [IMPORT FOREIGN SCHEMA](https://www.postgresql.org/docs/current/sql-importforeignschema.html)
(PostgreSQL 9.5+) and accepts following options via the `IMPORT FOREIGN SCHEMA` command:

- **import_default** as *boolean*, optional, default *false*

  Allow borrowing default values from SQLite table DDL.

- **import_not_null** as *boolean*, optional, default *true*

  Allow borrowing `NULL`/`NOT NULL` constraints from SQLite table DDL.

#### Datatype translation rules for `IMPORT FOREIGN SCHEMA`

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
| uuid         | uuid             |
| macaddr      | macaddr          |
| macaddr8     | macaddr8         |

### TRUNCATE support

`sqlite_fdw` implements the foreign data wrapper `TRUNCATE` API, available
from PostgreSQL 14.

As SQLite does not provide a `TRUNCATE` command, it is simulated with a
simple unqualified `DELETE` operation.

Actually, `TRUNCATE ... CASCADE` can be simulated if we create child table of SQLite with foreign keys and `ON DELETE CASCADE`, and then executing `TRUNCATE` (which will be deparsed to `DELETE`).

Following restrictions apply:
 - `TRUNCATE ... RESTART IDENTITY` is not supported
 - SQLite tables with foreign key references can cause errors during truncating

### Connection to SQLite database file and access control

In OS `sqlite_fdw` works as executed code with permissions of user of PostgreSQL server. Usually it is `postgres` OS user.

#### Data read access
For succesfully connection to SQLite database file you must have at least existed and correct SQLite file readable for OS user of PostgreSQL server process. This means all directories by path to the file must be also readable (listable) for OS user of PostgreSQL server process. There are no other conditions for PostreSQL database superuser to read all of SQLite data if there are also `sqlite_fdw` extension in the database and `FOREIGN SERVER` for SQLite database file.

#### Data change access

Data modification access in `sqlite_fdw` drived by both operating system and PostgreSQL.

OS restrictions can disallow any SQLite data modifications. Hence any PostgreSQL `FOREIGN SERVER` or `FOREIGN TABLE` options or `GRANT`s can be absolutely not effective. In this case SQLite data modification operations allowed by PostgreSQL can cause error message from SQLite like `attempt to write a readonly database` with result code `8`.

Full list of OS-leveled conditions of data modification access to SQLite database file
- Existed SQLite file is not corrupted by SQLite engine conditions.
- All path elements of the file are readable (listable) for OS user of PostgreSQL server process.
- The file and a directory of the file placed on readwrite filesystem. For example `sqashfs` is always read-only, remote `sshfs` can be read-only, a disk partition can be mounted in read-only mode etc.
- The file is writable for OS user of PostgreSQL server process.
- The directory of the file is writable for OS user of PostgreSQL server process because SQLite creates some temporary transaction files.

Full list of PostgreSQL-leveled conditions of data modification access to SQLite database file
- The `FOREIGN SERVER` of the SQLite file have no `force_readonly` = `true` option value.
- You have `USAGE` right `GRANT` for the `FOREIGN SERVER`.
- The `FOREIGN TABLE` of SQLite table have no `updatable` = `false` option value.
- If the `FOREIGN TABLE` have no `updatable` option, ensure `FOREIGN SERVER` have no `updatable` = `false` option value.

Generally for `sqlite_fdw` access management `FOREIGN SERVER` owner can be like _remote access manager_ for other FDWs.

_Remote access manager_ can block any data modififcations in remote database for _remote user_ of a FDW. In this case SQLite have no user or separate access conceptions, hence `FOREIGN SERVER` owner combines _remote access manager_ role with internal PostgreSQL roles such as `FOREIGN SERVER` access management.

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
              20500
```

Identifier case handling
------------------------

PostgreSQL folds identifiers to lower case by default, SQLite is case insensitive by default
only for uppercase and lowercase ASCII base latin letters. It's important
to be aware of potential issues with table and column names.

Following SQL isn't correct for SQLite: `Error: duplicate column name: a`, but is correct for PostgreSQL

```sql
	CREATE TABLE T (
	  "A" INTEGER,
	  "a" NUMERIC
	);
```
Following SQLs is correct for both SQLite and PostgreSQL because there is no column
with names composed from ASCII base latin letters *only*.

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
Please note this table name composed from ASCII base latin letters *only*. This is not applicable for other
alphabet systems or mixed names. This is because `toLower` operation in PostgreSQL is Unicode operation but
ASCII only operation in SQLite, hence other characters will not be changed.

```sql
	SELECT * FROM т;   -- №5
	SELECT * FROM Т;   -- №6
	SELECT * FROM "т"; -- №7
	SELECT * FROM "Т"; -- №8
```
In this case for PostgreSQL the query with comment `№8` is independend query to table `Т`, not to table `т`
as other queries. But for SQLite the queries with comments `№6` and `№8` belongs to table `Т`, and the queries with
comments `№5` and `№7` belongs to table `т`.

If there is

```sql
	CREATE TABLE T (
	  A INTEGER,
	  b REAL
	);
```
in SQLite, both `a` and `A` , `b` and `B` columns will have the same real datasource in SQLite in follow foreign table:

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

Character case functions such as `upper`, `lower` and other are not pushed down because they does not work with Unicode character in SQLite.

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

### Mixed affinity support
SQLite `text` affinity values which is different for SQLite unique checks can be equal for PostgreSQL because `sqlite_fdw` unifyes semantics of values, not storage form. For example `1`(integer), `Y`(text) and `tRuE`(text) SQLite values is different in SQLite but equal in PostgreSQL as `true` values of `boolean` column. This is also applicable for a data with `text` affinity in `uuid`, `timestamp`, `double precision`, `float` and `numeric` columns of foreign tables. **Please be carefully if you want to use mixed affinity column as PostgreSQL foreign table primary key**.

### Arrays
- `sqlite_fdw` only supports `ARRAY` const, for example, `ANY (ARRAY[1, 2, 3])` or `ANY ('{1, 2 ,3}')`.
- `sqlite_fdw` does not support `ARRAY` expression, for example, `ANY (ARRAY[c1, 1, c1+0])`.
- For `ANY(ARRAY)` clause, `sqlite_fdw` deparses it using `IN` operator.

### Numbers (range and precision)
- For `sum` function of SQLite, output of `sum(bigint)` is `integer` value. If input values are big, the overflow error may occurs on SQLite because it overflow within the range of signed 64bit. For PostgreSQL, it can calculate as over the precision of `bigint`, so overflow does not occur.
- SQLite promises to preserve the 15 most significant digits of a floating point value. The big value which exceed 15 most significant digits may become different value after inserted.
- SQLite does not support `numeric` type as PostgreSQL. Therefore, it does not allow to store numbers with too high precision and scale. Error out of range occurs.
- SQLite does not support `NaN` special value for IEEE 754-2008 numbers. Please use this special value very cerefully because there is no such conception in SQLite at all and `NaN` value treated in SQLite as `NULL`.
- SQLite support `+Infinity` and `-Infinity` special values for IEEE 754-2008 numbers in SQL expressions with numeric context. This values can be readed with both `text` and `real` affiniy, but can be writed to SQLite only with `real` affinity (as signed out of range value `9.0e999`).

### Boolean values
- `sqlite_fdw` boolean values support exists only for `bool` columns in foreign table. SQLite documentation recommends to store boolean as value with `integer` [affinity](https://www.sqlite.org/datatype3.html). `NULL` isn't converted, 1 converted to `true`, all other `NOT NULL` values converted to `false`. During `SELECT ... WHERE condition_column` condition converted only to `condition_column`.
- `sqlite_fdw` don't provides limited support of boolean values if `bool` column in foreign table mapped to SQLite `text` [affinity](https://www.sqlite.org/datatype3.html).

### UUID values
- `sqlite_fdw` UUID values support exists only for `uuid` columns in foreign table. SQLite documentation recommends to store UUID as value with both `blob` and `text` [affinity](https://www.sqlite.org/datatype3.html). `sqlite_fdw` can pushdown both reading and filtering both `text` and `blob` values.
- Expected affinity of UUID value in SQLite table determined by `column_type` option of the column
for `INSERT` and `UPDATE` commands. PostgreSQL supports both `blob` and `text` [affinity](https://www.sqlite.org/datatype3.html).

### bit and varbit support
- `sqlite_fdw` PostgreSQL `bit`/`varbit` values support based on `int` SQLite data affinity, because there is no per bit operations for SQLite `blob` affinity data. Maximum SQLite `int` affinity value is 8 bytes length, hence maximum `bit`/`varbit` values length is 64 bits.
- `sqlite_fdw` doesn't pushdown `#` (XOR) operator because there is no equal SQLite operator.

### MAC address support
- `sqlite_fdw` PostgreSQL `macaddr`/`macaddr8` values support based on `int` SQLite data affinity, because there is no per bit operations for SQLite `blob` affinity data. For `macaddr` out of range error is possible because this type is 6 bytes length, but SQLite `int` can store value up to 8 bytes.
- `sqlite_fdw` doesn't pushdown any operations with MAC adresses because there is 3 possible affinities for it in SQLite: `integer`, `blob` and `text`.

Tests
-----
Test directory have structure as following:

```
+---sql
|   +---13.15
|   |       filename1.sql
|   |       filename2.sql
|   |
|   +---14.12
|   |       filename1.sql
|   |       filename2.sql
|   |
.................
|   \---17.0
|          filename1.sql
|          filename2.sql
|
\---expected
|   +---13.15
|   |       filename1.out
|   |       filename2.out
|   |
|   +---14.12
|   |       filename1.out
|   |       filename2.out
|   |
.................
|   \---17.0
            filename1.out
            filename2.out
```
The test cases for each version are based on the test of corresponding version of PostgreSQL.
You can execute test by test.sh directly.
The version of PostgreSQL is detected automatically by $(VERSION) variable in Makefile.
The corresponding sql and expected directory will be used to compare the result. For example, for Postgres 15.0, you can execute "test.sh" directly, and the sql/15.0 and expected/15.0 will be used to compare automatically.

Test data directory is `/tmp/sqlite_fdw_test`. If you have `/tmp` mounted as `tmpfs` the tests will be up to 800% faster.

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
	t1 var1 = value1;
	t2 var2 = value2;

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
* Copyright © 2018, TOSHIBA CORPORATION
* Copyright © 2011 - 2016, EnterpriseDB Corporation

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

See the [`License`][3] file for full details.

[1]: https://www.sqlite.org/download.html
[2]: https://www.sqlite.org/howtocompile.html
[3]: License
