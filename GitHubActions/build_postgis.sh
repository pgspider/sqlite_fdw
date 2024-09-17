#!/bin/bash

################################################################################
#
# This script downloads PostgreSQL from the official web site into ./workdir
# then builds it.
#
# Usage: ./build_postgres.sh pg_version postgis_version
#     pg_version is a PostgreSQL version to be installed like 16.0.
#     postgis_version is a PostGIS version to be installed.
#
# Requirements
# - be able to connect to the PostgreSQL official web site by curl.
#
################################################################################

POSTGRESQL_VERSION=$1
POSTGIS_VERSION=$2

cd ./workdir
cd postgresql-${POSTGRESQL_VERSION}

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
export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config --with-geosconfig=$GEOS_CONFIG_PATH
make
sudo make install
