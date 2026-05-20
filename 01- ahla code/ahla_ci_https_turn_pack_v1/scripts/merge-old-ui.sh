#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/merge-old-ui.sh /path/to/OLD_AHLA /path/to/NEW_FULLSUITE [--dry-run]
#
# Copies old Next.js "app" pages and public assets into the new repo, excluding API routes.
# Keeps backups and prints a summary.
#
# Examples:
#   ./scripts/merge-old-ui.sh ../Ahla_Hero_v60_FullSuite .
#   ./scripts/merge-old-ui.sh ../Ahla_Hero_v60_FullSuite . --dry-run

OLD_ROOT="${1:-}"
NEW_ROOT="${2:-.}"
DRY="${3:-}"

if [[ -z "$OLD_ROOT" || -z "$NEW_ROOT" ]]; then
  echo "ERROR: Provide OLD_ROOT and NEW_ROOT"; exit 2
fi

OLD_APP="$OLD_ROOT/apps/web/app"
OLD_PUBLIC="$OLD_ROOT/apps/web/public"

NEW_APP="$NEW_ROOT/apps/web/app"
NEW_PUBLIC="$NEW_ROOT/apps/web/public"

if [[ ! -d "$OLD_APP" ]]; then
  echo "ERROR: Old app path not found: $OLD_APP"; exit 3
fi

mkdir -p "$NEW_APP" "$NEW_PUBLIC"

RSYNC="rsync -a --info=stats1,progress2 --human-readable"
EXCLUDES=(
  "--exclude" "api/**"
  "--exclude" "node_modules"
  "--exclude" ".next"
  "--exclude" ".DS_Store"
)

if [[ "$DRY" == "--dry-run" ]]; then
  RSYNC="$RSYNC -n"
  echo ">>> DRY RUN enabled (no files will be changed)"
fi

echo ">>> Merging UI pages (excluding API)"
$RSYNC "${EXCLUDES[@]}" "$OLD_APP/" "$NEW_APP/"

if [[ -d "$OLD_PUBLIC" ]]; then
  echo ">>> Merging public assets"
  $RSYNC "${EXCLUDES[@]}" "$OLD_PUBLIC/" "$NEW_PUBLIC/"
fi

echo ">>> Merge complete."
echo "Check git diff to review changes before commit."
