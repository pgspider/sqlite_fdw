#!/bin/bash

################################################################################
#
# This script downloads PostgreSQL from the official web site into ./workdir
# then builds it.
#
# Usage: ./build_postgres.sh pg_version [configure_options]
#     pg_version is a PostgreSQL version to be installed like 16.0.
#     configure_options are a list of option for postgres server.
#
# Requirements
# - be able to connect to the PostgreSQL official web site by curl.
#
################################################################################

VERSION=$1
CONFIGURE_OPTIONS=""

while (( "$#" )); do
  CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS $2"
  shift
done

mkdir -p ./workdir
cd ./workdir
curl -O https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.bz2
tar xjf postgresql-${VERSION}.tar.bz2
cd postgresql-${VERSION}

if [ -z "$CONFIGURE_OPTIONS" ]; then
  ./configure
else
  ./configure $CONFIGURE_OPTIONS
fi

make
sudo make install
sudo chown -R $USER /usr/local/pgsql