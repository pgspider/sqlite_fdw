#!/bin/bash

################################################################################
#
# This script downloads PostgreSQL from the official web site into ./workdir
#
# Usage: ./unpack_postgres.sh pg_version
#     pg_version is a PostgreSQL version to be installed like 16.0.
#
# Requirements
# - be able to connect to the PostgreSQL official web site by curl.
#
################################################################################

VERSION=$1
mkdir -p -v ./workdir
(
cd ./workdir
curl -O https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.bz2
tar xjf postgresql-${VERSION}.tar.bz2
)
