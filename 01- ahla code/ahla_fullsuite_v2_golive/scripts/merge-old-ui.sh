#!/usr/bin/env bash
set -euo pipefail
OLD_ROOT="${1:-}"; NEW_ROOT="${2:-.}"; DRY="${3:-}"
if [[ -z "$OLD_ROOT" || -z "$NEW_ROOT" ]]; then echo "Usage: merge-old-ui.sh <OLD_ROOT> <NEW_ROOT> [--dry-run]"; exit 2; fi
OLD_APP="$OLD_ROOT/apps/web/app"; OLD_PUBLIC="$OLD_ROOT/apps/web/public"
NEW_APP="$NEW_ROOT/apps/web/app"; NEW_PUBLIC="$NEW_ROOT/apps/web/public"
mkdir -p "$NEW_APP" "$NEW_PUBLIC"
RSYNC="rsync -a --info=stats1,progress2 --human-readable"; EXCLUDES=( "--exclude" "api/**" "--exclude" "node_modules" "--exclude" ".next" )
[[ "$DRY" == "--dry-run" ]] && RSYNC="$RSYNC -n" && echo ">>> DRY RUN"
$RSYNC "${EXCLUDES[@]}" "$OLD_APP/" "$NEW_APP/"
[[ -d "$OLD_PUBLIC" ]] && $RSYNC "${EXCLUDES[@]}" "$OLD_PUBLIC/" "$NEW_PUBLIC/"
echo "Merge complete. Review changes with git diff."
