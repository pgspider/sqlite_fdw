#!/bin/bash

################################################################################
#
# This sript downloads SQLite source code from the official web site into
# ./workdir then builds and installs it.
#
# Usage: ./install_sqlite.sh version year testing_mode sqlite_for_testing_dir [configure_options]
#     version: SQLite version to be installed.
#     year: A year of SQLite released. It is used for determining a download URL.
#     testing_mode:	'default' or 'postgis' value.
#     sqlite_for_testing_dir: path to install directory of the specified SQLite version
#     configure_options: are a list of option for sqlite server.
#
#     Ex) ./install_sqlite.sh 3420000 2023 postgis /opt/sqlite_for_testing --enable-rtree
#
# Requirements
# - be able to connect to the SQLite official web site by curl.
# - having superuser privileges
#
################################################################################

VERSION="$1"
YEAR="$2"
TESTING_MODE="$3"
SQLITE_FOR_TESTING_DIR="$4"

CONFIGURE_OPTIONS=""

while (( "$#" )); do
  CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS $5"
  shift
done

echo "SQLite ver $VERSION ($YEAR), mode $TESTING_MODE, install to $SQLITE_FOR_TESTING_DIR with options $CONFIGURE_OPTIONS";

mkdir -p ./workdir
cd ./workdir
vsrc="sqlite-src-${VERSION}"
adr="https://www.sqlite.org/${YEAR}/$vsrc.zip"
echo "SQLite source code archive: $adr"
wget "$adr" -O "$vsrc.zip"
unzip "$vsrc.zip" > /dev/null
cd "$vsrc"

export CFLAGS=-DSQLITE_ENABLE_COLUMN_METADATA
confcom="./configure --enable-fts5 --prefix=$SQLITE_FOR_TESTING_DIR"
if [ ! -z "$CONFIGURE_OPTIONS" ]; then
  confcom+="$CONFIGURE_OPTIONS"  
fi
echo "SQLite configure call: $confcom"
$confcom

make
echo "----- SQLITE INSTALL directory $SQLITE_FOR_TESTING_DIR -----"
sudo make install

if [ "$TESTING_MODE" == "postgis" ]; then
  sudo apt-get install libspatialite-dev -y
fi
