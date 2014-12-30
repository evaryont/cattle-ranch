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

nodes_diff_lc=$(knife diff nodes | wc -l)
if [[ $nodes_diff_lc > 0 ]]; then
  for i in nodes/*.json; do
    knife node from file $i >/dev/null
  done
fi
