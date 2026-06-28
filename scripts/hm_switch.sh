#!/bin/bash
# Purpose 3: Apply changes after modifying configs (add/remove software, tweak settings).
# Also used to apply updates after running the update script.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_INSECURE=1

echo "=== Applying home-manager configuration ==="
home-manager switch --flake "$REPO_DIR" --show-trace
echo "Done."
