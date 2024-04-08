#!/bin/bash

################################################################################
#
# This script detects target PostgreSQL versions for sqlite_fdw testing from 
# directory names in ./sql directory. Detected versions will be outputed to
# the standard output as an array of string like ["15.4","16.0"].
#
# Usage: ./detect_targets.sh
#
# Requirements
# - there is a directory named "sql" in a curent directory.
#
################################################################################

dirs="./sql/*"
pattern="[0-9]+\.[0-9]+"
targets="["
for pathname in $dirs; do
	if [[ "$pathname" =~ $pattern ]]; then
		target=`basename $pathname`
		if [ "$targets" != "[" ]; then
			targets+=","
		fi
		targets+="\"$target\""
	fi
done
targets+="]"

echo "$targets"
