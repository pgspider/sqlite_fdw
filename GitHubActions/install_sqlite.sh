#!/bin/bash

################################################################################
#
# This sript downloads SQLite source code from the official web site into
# ./workdir then builds and installs it.
#
# Usage: ./install_sqlite.sh version year testing_mode [configure_options]
#     version: SQLite version to be installed.
#     year: A year of SQLite released. It is used for determining a download URL.
#     testing_mode:	'default' or 'postgis' value.
#     configure_options: are a list of option for sqlite server.
#
#     Ex) ./install_sqlite.sh 3420000 2023 postgis --enable-rtree
#
# Requirements
# - be able to connect to the SQLite official web site by curl.
# - having superuser privileges
#
################################################################################

VERSION="$1"
YEAR="$2"
TESTING_MODE="$3"

CONFIGURE_OPTIONS=""

while (( "$#" )); do
  CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS $4"
  shift
done

mkdir -p ./workdir
cd ./workdir
curl -O https://www.sqlite.org/${YEAR}/sqlite-src-${VERSION}.zip
unzip sqlite-src-${VERSION}.zip > /dev/null
cd sqlite-src-${VERSION}

if [ -z "$CONFIGURE_OPTIONS" ]; then
  ./configure --enable-fts5
else
  ./configure --enable-fts5 $CONFIGURE_OPTIONS
fi

make
sudo make install

if [ "$TESTING_MODE" == "postgis" ]; then
  sudo apt-get install libspatialite-dev -y
fi
