#!/bin/bash

################################################################################
#
# This script builds unpacked PostgreSQL source codes from ./workdir
#
# Usage: ./build_postgres.sh pg_version
#     pg_version is a PostgreSQL version to be installed like 16.0.
#
# Requirements
# - no special.
#
################################################################################

VERSION=$1
(
cd ./workdir/postgresql-${VERSION}
echo "PostgreSQL CONFIGURE"
./configure
echo "PostgreSQL MAKE"
make
)
