#!/bin/sh

# Bash 'strict' mode
set -euo pipefail

berks -q && berks upload -q

for i in roles/*.json; do
  knife role from file $i
done
