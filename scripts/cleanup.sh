#!/usr/bin/env bash
# Purpose 5: Clean up old generations and free up disk space.
#
# Usage:
#   ./scripts/cleanup.sh              — dry run (show what would be deleted)
#   ./scripts/cleanup.sh --doit       — actually clean up

set -euo pipefail

DRY_RUN=true
[ "${1:-}" = "--doit" ] && DRY_RUN=false

echo "=== Home-manager generations ==="
home-manager generations 2>/dev/null || echo "(none)"
echo ""

# Remove home-manager generations older than 30 days
echo "=== Expiring old home-manager generations (>30 days) ==="
if home-manager expire-generations "30 days" 2>/dev/null; then
  echo "  Expired generations older than 30 days."
else
  echo "  (expire-generations not available in this home-manager version)"
fi
echo ""

# Garbage collect the nix store
echo "=== Nix store garbage collection ==="
if [ "$DRY_RUN" = true ]; then
  echo "  Dry run — use '$0 --doit' to actually clean."
  echo "  Dead store paths: $(nix store gc --print-dead 2>/dev/null | wc -l)"
else
  echo "  Running garbage collection..."
  nix store gc --verbose
fi

echo ""
if [ "$DRY_RUN" = true ]; then
  echo "Dry run complete. Run '$0 --doit' to reclaim space."
else
  echo "Cleanup complete!"
fi