rm test.db
sqlite3 test.db < sql/init.sql
make && make install && make check
