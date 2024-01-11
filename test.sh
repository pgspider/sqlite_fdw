#!/bin/bash
NO_CLEAN=false
#ENABLE_GIS=1

while (( "$#" )); do
    if [ "$1" == "--no-clean" ]; then
        NO_CLEAN=true
    fi
    shift
done

echo " -> Testing mode: gis $ENABLE_GIS, noclean $NO_CLEAN"
testdir='/tmp/sqlite_fdw_test';
rm -rf "$testdir";
mkdir "$testdir";
cp -a sql/init_data/*.data "$testdir";

sqlite3 "$testdir/post.db" < sql/init_data/init_post.sql;
sqlite3 "$testdir/core.db" < sql/init_data/init_core.sql;
sqlite3 "$testdir/common.db" < sql/init_data/init.sql;
sqlite3 "$testdir/selectfunc.db" < sql/init_data/init_selectfunc.sql;

[ -z "$ENABLE_GIS" ] && gispref='no' || gispref='post'
  sed -i "s/REGRESS =.*/REGRESS = extra\/sqlite_fdw_post extra\/bitstring extra\/bool extra\/float4 extra\/float8 extra\/int4 extra\/int8 extra\/numeric extra\/${gispref}gis extra\/out_of_range extra\/timestamp extra\/uuid extra\/join extra\/limit extra\/aggregates extra\/prepare extra\/select_having extra\/select extra\/insert extra\/update extra\/encodings sqlite_fdw type aggregate selectfunc /" Makefile;

if [ "$NO_CLEAN" = false ]; then
  make clean;
  [ -z "$ENABLE_GIS" ] && postf='' || postf='ENABLE_GIS=1'
  make "$postf";
fi

make check | tee make_check.out;
