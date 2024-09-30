#!/bin/bash

################################################################################
#
# This script executes a regression test pf sqlite_fdw by calling test.sh in
# sqlite_fdw. If all tests are passed, this script will exit successfully.
# Otherwise, it will exit with failure.

# Usage: ./execute_test.sh pg_version mode
#     pg_version is a PostgreSQL version to be tested like 16.0.
#	  mode is flag for sqlite_fdw compiler.
#
# Requiremets
# - the source code of PostgreSQL is located in ./workdir/postgresql-{pg_version}.
# - the source code of sqlite_fdw is loacted in ./workdir/postgresql-{pg_version}/contrib/sqlite_fdw.
# - PostgreSQL and sqlite_fdw were built.
# - this script assumes that tests are passed if this file (created by executing
#   the test) contains " ALL {number} tests passed" at the last or the 3rd line
#   from the end.
#
################################################################################

VERSION=$1
MODE="$2"

cd ./workdir/postgresql-${VERSION}/contrib/sqlite_fdw

if [ "$MODE" == "postgis" ]; then
	MAKEFILE_OPT="ENABLE_GIS=1"
	echo "$MODE mode, makefile option = $MAKEFILE_OPT"

	# Start postgres server
	POSTGRES_HOME=/usr/local/pgsql
	${POSTGRES_HOME}/bin/initdb ${POSTGRES_HOME}/databases
	${POSTGRES_HOME}/bin/pg_ctl -D ${POSTGRES_HOME}/databases -l logfile start

	# Change the testing method
	sed -i 's/make check/make installcheck/' test.sh
fi

# Execute test script
chmod +x ./test.sh
./test.sh $MAKEFILE_OPT

last_line=$(tail -n 1 make_check.out)
third_line_from_the_last=$(tail -n 3 make_check.out | head -n 1)

pattern=" All [0-9]+ tests passed.+"

if [[ "$last_line" =~ $pattern ]]; then
	echo "last_line"

elif [[ "$third_line_from_the_last" =~ $pattern ]]; then
	 echo "$third_line_from_the_last"
else
	echo "Error : not All the tests passed"
	echo "last line : '$last_line'"
	echo "thierd_line_from_the_last : '$third_line_from_the_last'"
	exit 1
fi
