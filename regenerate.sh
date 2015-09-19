#!/bin/sh

# Bash 'strict' mode
set -euo pipefail

# Update the Berksfile.lock
berks -q

# Then commit everything
echo -en '\a' # beep to let me know that the terminal needs interaction
git add --all
git commit --quiet

# Finally, upload it all
./upload_all.sh
