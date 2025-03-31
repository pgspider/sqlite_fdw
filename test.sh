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

while (( "$#" )); do
  export "$1";
  shift;
done

[ "$ENABLE_GIS" == "1" ] && GIS_TEST='post' || GIS_TEST='no';
type_tests="types/bitstring types/bool types/float4 types/float8 types/int4 types/int8 types/numeric types/${GIS_TEST}gis types/macaddr types/macaddr8 types/out_of_range types/timestamp types/uuid";

[ "$ENABLE_GIS" == "1" ] && GIS_DEP_TESTS_DIR='with_gis_support' || GIS_DEP_TESTS_DIR='without_gis_support';
gis_dep_tests="$GIS_DEP_TESTS_DIR/type $GIS_DEP_TESTS_DIR/auto_import";

# full composed test sequence, you can put your own test sequence here
export REGRESS="extra/sqlite_fdw_post $type_tests extra/join extra/limit extra/aggregates extra/prepare extra/select_having extra/select extra/insert extra/update extra/encodings sqlite_fdw aggregate selectfunc $gis_dep_tests";

make clean $1;
make $1;
make check $1 | tee make_check.out;
export REGRESS=;
