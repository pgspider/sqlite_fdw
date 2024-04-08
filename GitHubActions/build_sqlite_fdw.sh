#!/bin/bash

################################################################################
#
# This script builds sqlite_fdw in PostgreSQL source tree.
#
# Usage: ./build_sqlite_fdw.sh pg_version
#     pg_version is a PostgreSQL version like 16.0 to be built in.
#
# Requirements
# - the source code of sqlite_fdw is available by git clone.
# - the source code of PostgreSQL is located in ~/workdir/postgresql-{pg_version}.
# - SQLite development package is installed in a system.
################################################################################

VERSION=$1
mkdir -p ./workdir/postgresql-${VERSION}/contrib/sqlite_fdw
tar zxvf ./sqlite_fdw.tar.gz -C ./workdir/postgresql-${VERSION}/contrib/sqlite_fdw/
cd ./workdir/postgresql-${VERSION}/contrib/sqlite_fdw
export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
make
