rm /tmp/sqlitefdw_test.db
sqlite3 /tmp/sqlitefdw_test.db < sql/init.sql
export USE_PGXS=1

sed -i 's/REGRESS =.*/REGRESS = aggregate sqlite_fdw type /' Makefile

make clean && make && make installcheck
