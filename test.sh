rm /tmp/sqlitefdw_test.db
sqlite3 /tmp/sqlitefdw_test.db < sql/init.sql
make && make install && make check
