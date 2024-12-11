#!/bin/bash

testdir='/tmp/sqlite_fdw_test';
rm -rf "$testdir";
mkdir "$testdir";
cp -a sql/init_data/*.data "$testdir";

sqlite3 "$testdir/post.db" < sql/init_data/init_post.sql;
sqlite3 "$testdir/core.db" < sql/init_data/init_core.sql;
sqlite3 "$testdir/common.db" < sql/init_data/init.sql;
sqlite3 "$testdir/selectfunc.db" < sql/init_data/init_selectfunc.sql;

#sed -i 's/REGRESS =.*/REGRESS = extra\/sqlite_fdw_post types\/bitstring types\/bool types\/float4 types\/float8 types\/int4 types\/int8 types\/macaddr types\/macaddr8 types\/numeric types\/out_of_range types\/timestamp types\/uuid extra\/join extra\/limit extra\/aggregates extra\/prepare extra\/select_having extra\/select extra\/insert extra\/update extra\/encodings sqlite_fdw type aggregate selectfunc /' Makefile

make clean $1;
make $1;
make check $1 | tee make_check.out;
