#!/bin/bash

################################################################################
#
# This script normalize the sqlite version number x.x.x or x.x.x.x into sqlite
# download version with exactly 7 digits.
#
# Usage: ./convert_sqlite_download_version.sh SQLITE_VERSION
#
# Requirements
# - SQLITE_VERSION is required
#
################################################################################

# Check if input version is provided
if [ -z "$1" ]; then
  echo "Error: SQLITE_VERSION is required."
  echo "Usage: ./convert_sqlite_download_version.sh SQLITE_VERSION"
  exit 1
fi

version=$1

# Validate version format: Should be in the form of x.x.x.x, where x is a non-negative integer
if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Error: Invalid SQLITE_VERSION format. Expected format: x.x.x or x.x.x.x (where x is a non-negative integer)."
  exit 1
fi

# Separate version parts
IFS='.' read -r major minor patch extra <<< "$version"

# Set default value if not present
major=${major:-0}
minor=${minor:-0}
patch=${patch:-0}
extra=${extra:-0}

# Format parts into 1, 2, 2, and 2 digits
major=$(printf "%01d" "$major")
minor=$(printf "%02d" "$minor")
patch=$(printf "%02d" "$patch")
extra=$(printf "%02d" "$extra")

# Combine the parts into a string of numbers with exactly 7 digits
sqlite_download_version="${major}${minor}${patch}${extra}"

echo $sqlite_download_version