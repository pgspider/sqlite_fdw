#!/bin/bash

################################################################################
#
# This script installs libsptialite-dev used by geoinformational sqlite_fdw
# tests in Ubuntu.
#
# Usage: ./install_spatialite.sh
#
# Requirements:
# - having superuser privileges
#
################################################################################

sudo apt-get install libspatialite-dev -y
