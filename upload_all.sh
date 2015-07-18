#!/bin/sh

# Bash 'strict' mode
set -euo pipefail

# Upload cookbooks
berks upload -q

# Check for any changes in the roles
roles_diff_lc=$(knife diff roles | wc -l)
if [[ $roles_diff_lc > 0 ]]; then
  # and there is some sort of change! Just upload all of them, is very dumb
  for i in roles/*.json; do
    knife role from file $i >/dev/null
  done
fi

# same as roles, check if there are any changes in any data bag, and then upload
# every single one
dbags_diff_lc=$(knife diff data_bags | wc -l)
if [[ $dbags_diff_lc > 0 ]]; then
  for dbag in data_bags/*; do
    for dbag_item in $dbag/*.json; do
      knife data bag from file $(basename $dbag) $dbag_item >/dev/null
    done
  done
fi

# now that the chef server is updated, also update the git server
git push -q --mirror
