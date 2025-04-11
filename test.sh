#!/bin/bash

# Usage:
# ./test.sh                -- test without GIS support
# ./test.sh ENABLE_GIS     -- test with GIS support

testdir='/tmp/sqlite_fdw_test';
rm -rf "$testdir";
mkdir "$testdir";
cp -a sql/init_data/*.data "$testdir";

if [ -z "$SQLITE_FOR_TESTING_DIR" ]; then
  sqlite3=sqlite3;
else
  sqlite3="$SQLITE_FOR_TESTING_DIR/bin/sqlite3";
fi

"$sqlite3" "$testdir/post.db" < sql/init_data/init_post.sql;
"$sqlite3" "$testdir/core.db" < sql/init_data/init_core.sql;
"$sqlite3" "$testdir/common.db" < sql/init_data/init.sql;
"$sqlite3" "$testdir/selectfunc.db" < sql/init_data/init_selectfunc.sql;

# full test sequence,
# you can put your own test sequence here by following example
# undefined REGRESS environment variable will cause full test sequence from Makefile
#export REGRESS="extra/sqlite_fdw_post extra/test2 test3 types/test4 .... ";

make clean $@;
make $@;
make check $@ | tee make_check.out;
