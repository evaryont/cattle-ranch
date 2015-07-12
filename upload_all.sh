#!/bin/sh

# Bash 'strict' mode
set -euo pipefail

berks -q && berks upload -q

roles_diff_lc=$(knife diff roles | wc -l)
if [[ $roles_diff_lc > 0 ]]; then
  for i in roles/*.json; do
    knife role from file $i >/dev/null
  done
fi

dbags_diff_lc=$(knife diff data_bags | wc -l)
if [[ $dbags_diff_lc > 0 ]]; then
  for dbag in data_bags/*; do
    for dbag_item in $dbag/*.json; do
      knife data bag from file $(basename $dbag) $dbag_item >/dev/null
    done
  done
fi
