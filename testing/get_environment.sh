#!/bin/bash
f=$(readlink -f "$0");
f=$(dirname "$f");
f=$(readlink -f "$f/..");
fdwname=$(basename "$f");
echo "-------------------------------------------------------------------------------
Multiversional testing environment will be
- downloaded from official PostgreSQL git URLs,
- compiled,
- tested against internal regress tests
Mainstream $fdwname version will be also
- downloadaed,
- compiled against all available PostgreSQL versions,
- tested with all available PostgreSQL versions

This need
- 1.2+ Gb of disk space,
- not less than 30 minutes and
- 1+ Gb of network traffic.

* Please ensure your OS have needed packages for PostgreSQL source code compilation
See https://wiki.postgresql.org/wiki/Compile_and_Install_from_source_code

* Please ensure also you have got special environment for $fdwname

Press Ctrl+C to interrupt this execution, otherwise press any key";
read x;
fn=$(readlink -f "$0");
dir=$(dirname "$fn");
rm -v "$fn";
dest="$dir/../..";
mv -v "$dir"/*.sh "$dest";
cd "$dest";
rmdir -v "$dir/../testing";
echo -n "Testing multiversional environment getting is started, base directory: ";
pwd;
."/getmvpgenv.sh" "$fdwname" "PostgreSQL source";
# ."/getmvpgenv.sh" "$fdwname" "🐘"; # also tested
# ."/getmvpgenv.sh" "$fdwname" "🐢"; # also tested, in Japan this is PostgreSQL mascot
