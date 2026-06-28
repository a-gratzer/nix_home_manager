#!/bin/bash
# Utility: copy SSH keys from the no_git/ directory (post-clone on a new machine).
# These files are gitignored and need to be provided separately.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_DIR/no_git/.ssh"
DST="$HOME/.ssh"

if [ -d "$SRC" ]; then
  echo "Copying SSH keys from $SRC to $DST"
  cp -pr "$SRC" "$DST"
  chmod 700 "$DST"
  find "$DST" -type f -exec chmod 600 {} \;
  echo "Done."
else
  echo "No SSH keys found in $SRC"
  echo "Place your SSH keys in $SRC and re-run this script."
fi