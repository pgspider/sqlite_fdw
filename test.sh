testdir='/tmp/sqlite_fdw_test';
rm -rf "$testdir";
mkdir "$testdir";
cp -a sql/init_data/*.data "$testdir";

sqlite3 "$testdir/post.db" < sql/init_data/init_post.sql;
sqlite3 "$testdir/core.db" < sql/init_data/init_core.sql;
sqlite3 "$testdir/common.db" < sql/init_data/init.sql;
sqlite3 "$testdir/selectfunc.db" < sql/init_data/init_selectfunc.sql;

sed -i 's/REGRESS =.*/REGRESS = extra\/sqlite_fdw_post extra\/float4 extra\/float8 extra\/int4 extra\/int8 extra\/numeric extra\/out_of_range extra\/bitstring extra\/join extra\/limit extra\/aggregates extra\/prepare extra\/select_having extra\/select extra\/insert extra\/update extra\/timestamp extra\/encodings extra\/bool extra\/uuid sqlite_fdw type aggregate selectfunc /' Makefile

make clean;
make $1;
make check $1 | tee make_check.out;
