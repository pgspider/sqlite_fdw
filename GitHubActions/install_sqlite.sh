#!/bin/bash

################################################################################
#
# This sript downloads SQLite source code from the official web site into
# ./workdir then builds and installs it.
#
# Usage: ./install_sqlite.sh version year
#     version: SQLite version to be installed
#     year: A year of SQLite released. It is used for determining a download URL.
#
#     Ex) ./install_sqlite.sh 3420000 2023
#
# Requirements
# - be able to connect to the SQLite official web site by curl.
# - having superuser privileges
#
################################################################################

VERSION=$1
YEAR=$2
mkdir -p ./workdir
cd ./workdir
curl -O https://www.sqlite.org/${YEAR}/sqlite-src-${VERSION}.zip
unzip sqlite-src-${VERSION}.zip
cd sqlite-src-${VERSION}
./configure --enable-fts5
make
sudo make install
