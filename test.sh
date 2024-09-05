#!/bin/bash

echo " -> Testing mode: gis $ENABLE_GIS"
[ -z "$ENABLE_GIS" ] && postf='' || postf='ENABLE_GIS=1'

testdir='/tmp/sqlite_fdw_test';
rm -rf "$testdir";
mkdir "$testdir";
cp -a sql/init_data/*.data "$testdir";

sqlite3 "$testdir/post.db" < sql/init_data/init_post.sql;
sqlite3 "$testdir/core.db" < sql/init_data/init_core.sql;
sqlite3 "$testdir/common.db" < sql/init_data/init.sql;
sqlite3 "$testdir/selectfunc.db" < sql/init_data/init_selectfunc.sql;

sed -i 's/REGRESS =.*/REGRESS = extra\/sqlite_fdw_post extra\/bitstring extra\/bool extra\/float4 extra\/float8 extra\/int4 extra\/int8 extra\/numeric extra\/out_of_range extra\/timestamp extra\/uuid extra\/join extra\/limit extra\/aggregates extra\/prepare extra\/select_having extra\/select extra\/insert extra\/update extra\/encodings sqlite_fdw type aggregate selectfunc /' Makefile

make clean $postf;
make $postf;
make check $postf | tee make_check.out;
