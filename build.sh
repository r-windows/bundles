#!/bin/sh
source lib/functions.sh
export package="$1"
if [ -f "${package}.sh" ]; then
  source ${package}.sh
fi
create_bundles
