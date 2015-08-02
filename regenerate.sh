#!/bin/sh

# Bash 'strict' mode
set -euo pipefail

# Update the Berksfile.lock
berks -q

# Then commit everything
git add --all
git commit --quiet

# Finally, upload it all
./upload_all.sh
