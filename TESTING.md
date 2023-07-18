### Detailed description of testing

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
