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
FDWdir=./workdir/postgresql-${VERSION}/contrib/sqlite_fdw
mkdir -v -p $FDWdir
tar zxvf ./sqlite_fdw.tar.gz -C $FDWdir/
(
cd $FDWdir
export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
make
)
