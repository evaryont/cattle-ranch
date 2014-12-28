#!/bin/sh

# Bash 'strict' mode
set -euo pipefail

berks -q && berks upload -q
