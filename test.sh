#!/bin/bash

# Usage:
# ./test.sh                -- test without GIS support
# ./test.sh ENABLE_GIS     -- test with GIS support

testdir='/tmp/sqlite_fdw_test';
rm -rf "$testdir";
mkdir "$testdir";
cp -a sql/init_data/*.data "$testdir";

sqlite3 "$testdir/post.db" < sql/init_data/init_post.sql;
sqlite3 "$testdir/core.db" < sql/init_data/init_core.sql;
sqlite3 "$testdir/common.db" < sql/init_data/init.sql;
sqlite3 "$testdir/selectfunc.db" < sql/init_data/init_selectfunc.sql;

# full composed test sequence, you can put your own test sequence here by example
#export REGRESS="extra/sqlite_fdw_post .... ";

make clean $@;
make $@;
make check $@ | tee make_check.out;
export REGRESS=;
