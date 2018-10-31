rm /tmp/sqlitefdw_test.db
sqlite3 /tmp/sqlitefdw_test.db < sql/init.sql
export USE_PGXS=1
make clean && make && make install && make installcheck
