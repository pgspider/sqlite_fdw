#!/bin/bash

################################################################################
#
# This script installs PostGIS libraries used by geoinformational sqlite_fdw
# tests in Ubuntu.
#
# Usage: ./install_postgis_lib.sh
#
# Requirements:
# - having superuser privileges
#
################################################################################

sudo apt-get install libproj-dev libgeos-dev libxml2-dev gettext libjson-c-dev libgdal-dev libsfcgal-dev libprotobuf-c-dev protobuf-c-compiler -y
sudo apt-get install docbook-xsl docbook-utils docbook -y
