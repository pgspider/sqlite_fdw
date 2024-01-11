#!/bin/bash

################################################################################
#
# This script downloads PostgreSQL from the official web site into ./workdir
# then builds it.
#
# Usage: ./build_postgres.sh pg_version postgis_flag postgis_version [configure_options]
#     pg_version is a PostgreSQL version to be installed like 16.0.
#     postgis_flag to decide whether to install the postgis environment or not.
#     postgis_version is a PostGIS version to be installed.
#     configure_options are a list of option for postgres server.
#
# Requirements
# - be able to connect to the PostgreSQL official web site by curl.
#
################################################################################

VERSION=$1
POSTGIS_FLAG=$2
POSTGIS_VERSION=$3
CONFIGURE_OPTIONS=""

while (( "$#" )); do
  CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS $4"
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

if [ "$POSTGIS_FLAG" == "postgis" ]; then
  # Install necessary dependencies
  sudo apt update
  sudo apt install -y build-essential libxml2-dev libgeos-dev libproj-dev libgdal-dev libjson-c-dev libprotobuf-c-dev protobuf-c-compiler

  GEOS_CONFIG_PATH=$(which geos-config)

  # Download and compile PostGIS
  cd contrib
  wget http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz
  tar -xzf postgis-${POSTGIS_VERSION}.tar.gz
  mv postgis-${POSTGIS_VERSION} postgis -v
  cd postgis
  echo " - PostGIS directory"
  pwd
  ls -la .
  export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
  ./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config --with-geosconfig=$GEOS_CONFIG_PATH
  make
  sudo make install
fi
