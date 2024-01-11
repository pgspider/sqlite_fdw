#!/bin/bash

################################################################################
#
# This script downloads PostGIS from the official web site into ./workdir
# then builds it.
#
# Usage: ./build_postgis.sh pg_version
#     pg_version is a PostgreSQL version to be installed like 16.0.
#
# Requirements
# - be able to connect to the PostGIS official web site by curl.
#
################################################################################

VERSION=$1
curl -O https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz
tar -xvzf ./postgis-${POSTGIS_VERSION}.tar.gz -C ./workdir/postgresql-${VERSION}/contrib
mv -v ./workdir/postgresql-${VERSION}/contrib/postgis-${POSTGIS_VERSION} ./workdir/postgresql-${VERSION}/contrib/postgis
