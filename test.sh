rm -rf /tmp/sqlitefdw_test*.db
rm -rf /tmp/*.data
cp -a sql/*.data /tmp/

sqlite3 /tmp/sqlitefdw_test.db < sql/init.sql
sqlite3 /tmp/sqlitefdw_test_post.db < sql/init_post.sql
sqlite3 /tmp/sqlitefdw_test_core.db < sql/init_core.sql

sed -i 's/REGRESS =.*/REGRESS = sqlite_fdw_post float4 float8 int4 int8 numeric join limit aggregates prepare select_having select insert update sqlite_fdw type aggregate /' Makefile

# export USE_PGXS=1
make clean
make
make check | tee make_check.out
