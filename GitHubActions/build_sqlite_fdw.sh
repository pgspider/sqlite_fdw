#!/bin/bash

################################################################################
#
# This script builds sqlite_fdw in PostgreSQL source tree.
#
# Usage: ./build_sqlite_fdw.sh pg_version mode sqlite_for_testing_dir
#     pg_version is a PostgreSQL version like 17.0 to be built in.
#     mode is flag for sqlite_fdw compiler.
#     sqlite_for_testing_dir: path to install directory of SQLite version for testing
#
# Requirements
# - the source code of sqlite_fdw is available by git clone.
# - the source code of PostgreSQL is located in ~/workdir/postgresql-{pg_version}.
# - SQLite development package is installed in a system.
################################################################################

VERSION="$1"
MODE="$2"

mkdir -p ./workdir/postgresql-${VERSION}/contrib/sqlite_fdw
tar zxf ./sqlite_fdw.tar.gz -C ./workdir/postgresql-${VERSION}/contrib/sqlite_fdw/
cd ./workdir/postgresql-${VERSION}/contrib/sqlite_fdw

# show locally compiled sqlite library
ls -la /usr/local/lib

if [ "$MODE" == "postgis" ]; then
  make ENABLE_GIS=1 SQLITE_FOR_TESTING_DIR="$3"
else
  make SQLITE_FOR_TESTING_DIR="$3"
fi

sudo make install
