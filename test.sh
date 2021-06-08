rm -rf /tmp/sqlitefdw_test*.db
rm -rf /tmp/*.data
rm -rf /tmp/sqlitefdw_test*.db
cp -a sql/init_data/*.data /tmp/

sqlite3 /tmp/sqlitefdw_test_post.db < sql/init_data/init_post.sql
sqlite3 /tmp/sqlitefdw_test_core.db < sql/init_data/init_core.sql
sqlite3 /tmp/sqlitefdw_test.db < sql/init_data/init.sql
sqlite3 /tmp/sqlitefdw_test_selectfunc.db < sql/init_data/init_selectfunc.sql

sed -i 's/REGRESS =.*/REGRESS = extra\/sqlite_fdw_post extra\/float4 extra\/float8 extra\/int4 extra\/int8 extra\/numeric extra\/join extra\/limit extra\/aggregates extra\/prepare extra\/select_having extra\/select extra\/insert extra\/update extra\/timestamp sqlite_fdw type aggregate selectfunc /' Makefile

make clean
make
make check | tee make_check.out
