#!/bin/bash

NO_CLEAN=false
REGRESS_PGSpider=false

while (( "$#" )); do
    if [ "$1" == "--no-clean" ]; then
        NO_CLEAN=true
    elif [ "$1" == "REGRESS_PREFIX=PGSpider" ]; then
        REGRESS_PGSpider=true
    shift
done

testdir='/tmp/sqlite_fdw_test';
rm -rf "$testdir";
mkdir "$testdir";
cp -a sql/init_data/*.data "$testdir";

sqlite3 "$testdir/post.db" < sql/init_data/init_post.sql;
sqlite3 "$testdir/core.db" < sql/init_data/init_core.sql;
sqlite3 "$testdir/common.db" < sql/init_data/init.sql;
sqlite3 "$testdir/selectfunc.db" < sql/init_data/init_selectfunc.sql;

sed -i 's/REGRESS =.*/REGRESS = extra\/sqlite_fdw_post extra\/bitstring extra\/bool extra\/float4 extra\/float8 extra\/int4 extra\/int8 extra\/numeric extra\/out_of_range extra\/timestamp extra\/uuid extra\/join extra\/limit extra\/aggregates extra\/prepare extra\/select_having extra\/select extra\/insert extra\/update extra\/encodings sqlite_fdw type aggregate selectfunc /' Makefile

if [ "$NO_CLEAN" = false ]; then
  make clean;
  make;
fi

if [ "$REGRESS_PGSpider" = false ]; then
    make check | tee make_check.out;
else
    make check REGRESS_PREFIX=PGSpider | tee make_check.out;
fi
