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
postgisdir=./workdir/postgresql-${VERSION}/contrib/postgis
ti=$(realpath ./workdir/postgresql-${VERSION}/tmp_install)
inc=$(realpath ./workdir/postgresql-${VERSION}/src/include)
(
cd $postgisdir
./autogen.sh
echo "PostGIS CONFIGURE"
./configure
echo "cflg $inc"
"$ti/usr/local/pgsql/bin/pg_config"
export PATH=$inc:$PATH
export BINDIR="$ti/usr/local/pgsql/bin"
export DOCDIR="$ti/usr/local/pgsql/share/doc"
export HTMLDIR="$ti/usr/local/pgsql/share/doc"
export INCLUDEDIR="$ti/usr/local/pgsql/include"
export PKGINCLUDEDIR="$ti/usr/include/postgresql"
export LIBDIR="$ti/usr/local/pgsql/lib"
export PKGLIBDIR="$ti/usr/local/pgsql/lib"
export LOCALEDIR="$ti/usr/local/pgsql/share/locale"
export MANDIR="$ti/usr/local/pgsql/share/man"
export SHAREDIR="$ti/usr/local/pgsql/share"
export DESTDIR="$ti"
echo "PostGIS MAKE"
make
echo "PostGIS MAKE INSTALL"
make install
)
