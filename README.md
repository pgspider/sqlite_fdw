SQLite Foreign Data Wrapper for PostgreSQL
==========================================

This is a foreign data wrapper (FDW) to connect [PostgreSQL](https://www.postgresql.org/)
to [SQLite](https://sqlite.org/) database file. This FDW works with PostgreSQL 11, 12, 13, 14, 15 and confirmed with SQLite 3.38.5.

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
- `upper`, `lower` and other character case functions are **not** pushed down because they does not work with UNICODE character in SQLite.
- `WITH TIES` option is **not** pushed down.

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
* `postgresql-server-dev-**`, where ** must be removed to needed PostgreSQL version number, especially `postgres.h`
* `gcc`
* `make`

#### 1. Install SQLite & Postgres Development Libraries

For Debian or Ubuntu:
`apt-get install libsqlite3-dev`
`apt-get install postgresql-server-dev-XX`, where XX matches your postgres version, i.e. `apt-get install postgresql-server-dev-15`

You can also [download SQLite source code][1] and [build SQLite][2].

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

### RPM package building

RPM is a software distribution file format for such Linux distributives as REHL, openSUSE, Fuduntu, ALT Linux, Fedora etc. You can build RPM with actual code base before release with following commands in the main directory of your copy of this repository:

```sh
rpmbuild -bs rpm.spec # for source RPM file
rpmbuild -bb rpm.spec # for binary RPM file for current processor architecture
```

Usage
-----

### Datatypes
**WARNING! The table above represents roadmap**, work still in progress. Untill it will be ended please refer real behaviour in non-obvious cases.

This table represents `sqlite_fdw` behaviour if in PostgreSQL foreign table column data of some SQLite [affinity](https://www.sqlite.org/datatype3.html) is detected.

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
|         bool |     V     |     ?     |     T     |     -     |     ∅     |   INT|
|       bit(n) |     V     |     ∅     |     V     |     ?     |     ∅     |   INT|
|        bytea |     b     |     b     |     ✔     |     -     |     ?     |  BLOB|
|         date |     V     |     V     |     T     |     V+    |   `NULL`  | ? |
|       float4 |     V+    |     ✔     |     T     |     -    |   `NULL`  | REAL|
|       float8 |     V+    |     ✔     |     T     |     -    |   `NULL`  | REAL|
|         int2 |     ✔     |     ?     |     T     |     -    |   `NULL`  |   INT|
|         int4 |     ✔     |     ?     |     T     |     -    |   `NULL`  |   INT|
|         int8 |     ✔     |     ?     |     T     |     -    |   `NULL`  |   INT|
|         json |     ?     |     ?     |     T     |     V+    |     ?     |  TEXT|
|         name |     ?     |     ?     |     T     |     V     |   `NULL`  |  TEXT|
|      numeric |     V     |     V     |     T     |     ∅     |   `NULL`  | REAL|
|         text |     ?     |     ?     |     T     |     ✔     |     V     |  TEXT|
|         time |     V     |     V     |     T     |     V+    |   `NULL`  | ? |
|    timestamp |     V     |     V     |     T     |     V+    |   `NULL`  | ? |
|timestamp + tz|     V     |     V     |     T     |     V+    |   `NULL`  | ? |
|         uuid |     ∅     |     ∅     |V+<br>(only<br>16 bytes)|     V+    |   `NULL`  |  TEXT, BLOB|
|      varchar |     ?     |     ?     |     T     |     ✔     |     V     |  TEXT|

### CREATE SERVER options

`sqlite_fdw` accepts the following options via the `CREATE SERVER` command:

- **database** as *string*, **required**

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
- write permissions both on SQLite database file and *directory it contains* if you need a modification. During `INSERT`, `UPDATE` or `DELETE` in SQLite database, SQLite engine functions makes [temporary files with transaction data](https://www.sqlite.org/tempfiles.html) in the directory near SQLite database file. Hence without write permissions you'll have a message `failed to execute remote SQL: rc=8 attempt to write a readonly database`. 

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

  Option to convert INT SQLite column (epoch Unix Time) to be treated/visualized as TIMESTAMP in PostgreSQL.

- **key** as *boolean*, optional, default *false*

  Indicates a column as a part of primary key or unique key of SQLite table.
  
### IMPORT FOREIGN SCHEMA options

`sqlite_fdw` supports [IMPORT FOREIGN SCHEMA](https://www.postgresql.org/docs/current/sql-importforeignschema.html)
(PostgreSQL 9.5+) and accepts no custom options for this command.

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
              20300
```
Identifier case handling
------------------------

PostgreSQL folds identifiers to lower case by default, SQlite is case insensetive by default. It's important
to be aware of potential issues with table and column names.

This SQL isn't correct for SQLite: `Error: duplicate column name: a`, but is correct for PostgreSQL

```sql
	CREATE TABLE T (
	  "A" INTEGER,
	  "a" NUMERIC
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

When `sqlite_fdw` connects to a SQLite [no character set metadata](https://www.sqlite.org/search?s=d&q=character+set)
stored in SQLite. There is only [`PRAGMA encoding;`](https://www.sqlite.org/pragma.html#pragma_encoding) with UTF-only values (`UTF-8`, `UTF-16`, `UTF-16le`, `UTF-16be`). All strings are interpreted acording the PostgreSQL database's server encoding. It's not a problem
if both PostgreSQL database and SQLite character data from database file has UTF-8 or UTF-16 encoding. Otherewise
character interpretation transformation problems will occur.

Character case functions such as `upper`, `lower` and other are not pushed down because they does not work with UNICODE character in SQLite.

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

Tests
-----
We don't profess a specific environment. You can use any POSIX-compliant system. Main testing script see in [test.sh](test.sh) file.
*Testing framework* based on UTF-8 files with SQL commands for `psql` and comparing actual outputs with saved expected outputs.  About base testing mechanism see in [PostgreSQL documentation](https://www.postgresql.org/docs/current/regress-run.html). The simplest analogue of testing framework look like `cat Some_test_script.sql | LANGUAGE=C psql --echo-all -d contrib_regression > Some_test_script.actual.out; diff Some_test_script.out Some_test_script.actual.out;`

### Prerequisites

- For testing you need to install **`sqlite3`** from packgage of your OS or from source code to a directory from `PATH` environment variable. Hence `sqlite3` must be a correct command in your environment.
- `git`, `make` and `gcc` also will be used

Test script creates some SQLite databases for testing in `/tmp` directory. This databases used in 
`CREATE SERVER` SQL commands, gives access to testing interactions between PostgreSQL and SQLite.

### Testing modes

For `sqlite_fdw` there is 3 testing modes:

- Multi - versional testing in source code tree (recommemded)
- One - versional testing in source tree for the latest version (allowed)
- Testing on OS PostgreSQL environment (usually isn't very representative)

### Quick start 

#### Multi - versional testing in source code tree

This is recommended testing mode. Requires not more than 1.2 Gb of disk space. First loading near 30 min, testig cycle not more than 8 min for all versions.

1. Install packages for PostgreSQL build from source code.

For `apt` use `sudo apt-get install build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils xsltproc ccache;` or for `yum` use `sudo yum install -y bison-devel readline-devel zlib-devel openssl-devel wget ccache; sudo yum groupinstall -y 'Development Tools'`. For details see https://wiki.postgresql.org/wiki/Compile_and_Install_from_source_code

2. Get and check PostgreSQL source trees for different versions

Here and later we use notation of version branches from https://git.postgresql.org/gitweb/?p=postgresql.git;a=summary for directory nameing.

Please set preferred values for variables based on your branch for testing. Then *carefully* read and run the following script for environment setup

```bash
autor='';
branch='';
#pg_multver_src_dir='🐘';
pg_multver_src_dir='PostgreSQL source'; 

d0=$(date);

# Clone original sqlite_fdw.
[ ! -d "sqlite_fdw" ] && git clone https://github.com/pgspider/sqlite_fdw || (echo "Problem getting sqlite_fdw source
Press any key"; read x; exit;);

# Make directory for multiversional PostgreSQL source code
[ ! -d "$pg_multver_src_dir" ] && (mkdir "$pg_multver_src_dir" && echo 'OK pg dir' || (echo "Problem creating PostgreSQL source code directory
Press any key"; read x; exit;));
cd "$pg_multver_src_dir";

# Get and read list of PostgreSQL versions. We should replace . to _ and beta to _.
ver=$(ls -1 ../sqlite_fdw/expected/ | tr '.' '_' | sed -e "s/beta/\_/g");
echo "$ver";

# Get or pull (update) individual PostgreSQL source trees for different versions.
echo "$ver" | while read ver_curs; do
    [ ! -d "REL_$ver_curs" ] && mkdir "REL_$ver_curs";
    cd "REL_$ver_curs";
    git clone https://git.postgresql.org/git/postgresql.git -b "REL_$ver_curs" || ( cd postgresql; git pull https://git.postgresql.org/git/postgresql.git "REL_$ver_curs"; cd ..;);
    cd ..;
done;

# Configure PostgreSQL sources
echo "$ver" | while read ver_curs; do cd "REL_$ver_curs/postgresql"; ./configure; cd ../..; done;

# Make PostgreSQL sources
echo "$ver" | while read ver_curs; do cd "REL_$ver_curs/postgresql"; make; cd ../..; done;

# Run internal checks for PostgreSQL. 
echo "$ver" | while read ver_curs; do cd "REL_$ver_curs/postgresql"; make check; cd ../..; done;

echo "Beginned at $d0";
echo -n "Completed at ";
date;
cd ..;

```

Please carefully read output of `make check` command for all versions. Ensure all tests is successfuly. If yes, source code of all PostgreSQL versions is suitable for any FDW integration. Warning! Internal tests output is long. Then you should try to reproduce clean tests for current generic `sqlite_fdw` version. Please continue to execute the following commans in the same terminal(environment).

```bash

cd "$pg_multver_src_dir";

# Copy generic sqlite_fdw to contrib directory of all PostgreSQL versions.
echo "$ver" | while read ver_curs; do [ ! -d "REL_$ver_curs/postgresql/contrib/sqlite_fdw" ] && cp -r -v "../sqlite_fdw" "REL_$ver_curs/postgresql/contrib"; done;

# Run sqlite_fdw regression tests for generic version.
echo "$ver" | while read ver_curs; do pwd; cd "REL_$ver_curs/postgresql/contrib/sqlite_fdw"; pwd; ./test.sh; cd ../../../..; pwd; done;

# Copy diff files from regression tests from different PostgreSQL version source code trees.
echo "$ver" | while read ver_curs; do rm "rel_$ver_curs regression.diff" > /dev/null; cp -v "REL_$ver_curs/postgresql/contrib/sqlite_fdw/regression.diffs" "rel_$ver_curs regression.diff"; done;
```
 Please read all diff files in current directory. If all files have 0 bytes, you have testing environment equal to original `pgspider` `sqlite_fdw`. If some tests are failed, please verify SQLite library version in your OS environment. `Sqlite_fdw` was linked to this version, hence compare your system version with version from first lines of this README file.

```bash
# Verify base sqlite library for sqlite_fdw
echo "$ver" | while read ver_curs; do echo "REL_$ver_curs"; ldd "REL_$ver_curs/postgresql/contrib/sqlite_fdw/sqlite_fdw.so"; done;
```

If all tests passed, you can copy or archive current directory as clear multi - versional testing envoronment for future usage as base for any modifications.

Delete generic `sqlite_fdw` and replace to tested git branch and load tested branch.
Following script represets full testing cycle:

```bash
# Delete generic sqlite_fdw version
echo "$ver" | while read ver_curs; do rm -r -f "REL_$ver_curs/postgresql/contrib/sqlite_fdw"; done;
rm -r -v -f ../sqlite_fdw;

cd ..;
git clone "https://github.com/$autor/sqlite_fdw" -b "$branch";
cd "$pg_multver_src_dir";

# Copy tested sqlite_fdw to contrib directory of all PostgreSQL versions.
echo "$ver" | while read ver_curs; do [ ! -d "REL_$ver_curs/postgresql/contrib/sqlite_fdw" ] && cp -r -v "../sqlite_fdw" "REL_$ver_curs/postgresql/contrib"; done;

# Run sqlite_fdw regression tests for tested version.
echo "$ver" | while read ver_curs; do pwd; cd "REL_$ver_curs/postgresql/contrib/sqlite_fdw"; pwd; ./test.sh; cd ../../../..; pwd; done;
# Copy diff files from regression tests from different PostgreSQL version source code trees.
echo "$ver" | while read ver_curs; do rm "rel_$ver_curs regression.diff" > /dev/null; cp -v "REL_$ver_curs/postgresql/contrib/sqlite_fdw/regression.diffs" "rel_$ver_curs regression.diff"; done;
```
Please read all diff files in current directory.

#### One - versional testing in source code tree

This is simplification of previous testing mode. Most of steps are equal without version cycle.

1. Install packages for PostgreSQL build from source code.

For `apt` use `sudo apt-get install build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils xsltproc ccache;` or for `yum` use `sudo yum install -y bison-devel readline-devel zlib-devel openssl-devel wget ccache; sudo yum groupinstall -y 'Development Tools'`. For details see https://wiki.postgresql.org/wiki/Compile_and_Install_from_source_code

2. Get and check PostgreSQL source trees for different versions

Here and later we use notation of version branches from https://git.postgresql.org/gitweb/?p=postgresql.git;a=summary for directory nameing.

Please set preferred values for variables based on your branch for testing. Then *carefully* read and run the following script for environment setup

```bash
autor='mkgrgis';
branch='draft_updatable_option';

d0=$(date);

# Clone original sqlite_fdw.
[ ! -d "sqlite_fdw" ] && git clone https://github.com/pgspider/sqlite_fdw || (echo "Problem getting sqlite_fdw source
Press any key"; read x;);

# Get and read list of PostgreSQL versions. We should replace . to _ and beta to _.
ver=$(ls -1 -r sqlite_fdw/expected/ | tr '.' '_' | sed -e "s/beta/\_/g");
echo "$ver";
ver_curs=$(echo "$ver" | head -1);
echo " --- $ver_curs selected";

git clone https://git.postgresql.org/git/postgresql.git -b "REL_$ver_curs" || ( cd postgresql; git pull https://git.postgresql.org/git/postgresql.git "REL_$ver_curs"; cd ..;);

# Configure PostgreSQL sources
cd "postgresql" && ./configure && make && make check && cd ..;

echo "Beginned at $d0";
echo -n "Completed at ";
date;

```

Please carefully read output of `make check`. Ensure all tests is successfuly. If yes, source code of a PostgreSQL version is suitable for any FDW integration. Then you should try to reproduce clean tests for current generic `sqlite_fdw` version. Please continue to execute the following commans in the same terminal(environment).

```bash

# Copy generic sqlite_fdw to contrib directory of all PostgreSQL versions.
mv "sqlite_fdw" "postgresql/contrib";
ln -s -r "postgresql/contrib/sqlite_fdw" .;

# Run sqlite_fdw regression tests for generic version.
cd "postgresql/contrib/sqlite_fdw"; pwd; ./test.sh; cd ../../..; pwd;

```
 Please read diff file in *postgresql/contrib/sqlite_fdw* directory. If the file have 0 bytes, you have testing environment equal to original `pgspider` `sqlite_fdw` for the last PostgreSQL testing version. If some tests are failed, please verify SQLite library version in your OS environment. `Sqlite_fdw` was linked to this version, hence compare your system version with version from first lines of this README file.

```bash
# Verify base sqlite library for sqlite_fdw
ldd "postgresql/contrib/sqlite_fdw/sqlite_fdw.so";
```

If all tests passed, you can copy or archive current directory as one - versional clear testing envoronment for future usage as base for any modifications.

Delete generic `sqlite_fdw` and replace to tested git branch and load tested branch.
Following script represets full testing cycle from repository refresh:

```bash
# Delete generic sqlite_fdw version
rm -r -v "sqlite_fdw";
rm -r -v "postgresql/contrib/sqlite_fdw";

git clone "https://github.com/$autor/sqlite_fdw" -b "$branch";


# Copy tested sqlite_fdw to contrib directory of PostgreSQL.
mv "sqlite_fdw" "postgresql/contrib";
ln -s -r "postgresql/contrib/sqlite_fdw" .;

# Run sqlite_fdw regression tests for generic version.
cd "postgresql/contrib/sqlite_fdw"; pwd; ./test.sh; cd ../../..; pwd;
```
Pease read diff file.

#### Testing on OS PostgreSQL environment 

Usually this testing mode isn't very representative, because for testing you should have in your OS packages of PostgreSQL and SQLite in one or more of version conbinations from  [sql](sql) directory. Sometimes minor versions also have all succesfully tests, not only listed base version, but this is not good testing way. 

**WARNING**: in this testing mode testing framework works with PostgreSQL database **`contrib_regression`**. If you have such database please rename to any safe name. Database `contrib_regression` will be droped before first tests if exists.

You can execute test by `test.sh` directly or with `make installcheck`. Don't forget use `USE_PGXS=1` environment variable.

In OS testing scripts running by a user we called **testing user**.

If you execute [`test.sh`](test.sh) as testing user, ensure
- Testing user can directly write to `/tmp`
- Testing user can write to directory of local copy of `sqlite_fdw` and some subdirectories
- Testing user can login to `psql` without password or any other wainting. SQL look like `CREATE USER "user" LOGIN;` can be helpful for creating testing user under PostgreSQL superuser.
- Testing user is superuser in PostgreSQL and can drop and create a database. Database `contrib_regression` will be used for tests.
- SQLite databases in `/tmp` are RW accessable for PosgreSQL server user such as `postgres` or other.

Full sample shell test commands for Ubuntu or Debian after `cd` to code directory can be like
```sh
export USE_PGXS=1;
./test.sh ;
chmod og+rw -v /tmp/*.db;
LANGUAGE=C make installcheck;
```

### Tests are multiversional for PsotgreSQL
The version of PostgreSQL is detected automatically by `$(VERSION)` variable in Makefile. The corresponding [sql](sql) and [expected](expected) directory will be used to compare the result. For example, for Postgres 15.0, you can execute [`test.sh`](test.sh) directly, and the sql/15.0 and expected/15.0 will be used to compare automatically.

Testing directory have structure as following:

```sql
+---sql
|   +---11.7
|   |       filename1.sql
|   |       filename2.sql
|   | 
|   +---12.12
|   |       filename1.sql
|   |       filename2.sql
|   | 
.................  
|   \---15.0
|          filename1.sql
|          filename2.sql
|          
\---expected
|   +---11.7
|   |       filename1.out
|   |       filename2.out
|   | 
|   +---12.12
|   |       filename1.out
|   |       filename2.out
|   | 
.................  
|   \---15.0
            filename1.out
            filename2.out
```

### SQLite library requirements and fixing

When installing `sqlite3`, it will create some libraries: `libsqlite3.xx`.
If you use `make install`, libraries will be in `/usr/local/lib` directory, replacing the old library of `sqlite3` if exist.

If a machine has default library folder is `/usr/lib/x86_64-linux-gnu`, and when making `sqlite_fdw`, it will find library in this folder, but the library of `sqlite3` in this folder is old. So `sqlite_fdw` use the wrong library of `sqlite3` in this case. You can use `ldd` command to verify all is ok:
```
    ldd sqlite_fdw.so
    linux-vdso.so.1 (0x00007ffd3798f000)
    libsqlite3.so.0 => /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 (0x00007fb9aa491000)
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb9aa2bc000)
    libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fb9aa178000)
    libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fb9aa172000)
    libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fb9aa150000)
    /lib64/ld-linux-x86-64.so.2 (0x00007fb9aa5f9000)
```
To resolve SQLite library mismatch, you can replace the old library of `sqlite3` in `/usr/lib/x86_64-linux-gnu` by the new library of `sqlite3` (`/usr/local/lib` or folder `.libs` of source building).

Contributing
------------

Opening issues and pull requests on GitHub are welcome.

You don't need to squash small commits to one big in pull requests.

For pull request, please make sure these items below for testing:
- Create test cases (if needed) for the latest version of PostgreSQL supported by `sqlite_fdw`.
- Execute test cases and update expectations for the latest version of PostgreSQL
- Test creation and execution for other PostgreSQL versions are welcome but not required.

For C code please indent by Tabs, not Spaces. Comments should be in style as in PostgresSQL code
```c
/* comment */
```
or 
```c
/*
 * comment 
 */
```

Useful links
------------

### Source

 - https://github.com/pgspider/sqlite_fdw
 - https://pgxn.org/dist/sqlite_fdw/
 
 Reference FDW realisation, `postgres_fdw`
 - https://git.postgresql.org/gitweb/?p=postgresql.git;a=tree;f=contrib/postgres_fdw;hb=HEAD

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
