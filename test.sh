#!/bin/bash
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

while (( "$#" )); do
  export "$1";
  shift;
done

[ "$ENABLE_GIS" == "1" ] && gispref='post' || gispref='no';
[ "$ENABLE_GIS" == "1" ] && gissuf='ok' || gissuf='no';

# full test sequence, you can put your own test sequence here
type_tests="types/bitstring types/bool types/float4 types/float8 types/int4 types/int8 types/json types/numeric types/${gispref}gis types/macaddr types/macaddr8 types/out_of_range types/timestamp types/uuid";
gis_dep_tests="gis_$gissuf/type gis_$gissuf/auto_import";
export REGRESS="libsqlite extra/sqlite_fdw_post $type_tests extra/join extra/limit extra/aggregates extra/prepare extra/select_having extra/select extra/insert extra/update extra/encodings sqlite_fdw aggregate selectfunc $gis_dep_tests";
make clean $1;
make $1;
make check $1 | tee make_check.out;
export REGRESS=;
