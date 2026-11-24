#!/usr/bin/env bash
# TA-02: only LISTS what takes disk space around the project; deletes and moves nothing.
# Usage: tools/disk_report.sh   (sizes per category, warns when the junk passes LIMIT_GB)
LIMIT_GB=5
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# the main checkout is where .claude/worktrees lives; from inside a worktree go up to it
MAIN="${ROOT%%/.claude/worktrees/*}"
PARENT="$(dirname "$MAIN")"
junk_kb=0
JUNK_ADD=0

row() { # label path -> prints one line, sets JUNK_ADD (kB)
  JUNK_ADD=0
  [ -e "$2" ] || return 0
  JUNK_ADD=$(du -sk "$2" 2>/dev/null | cut -f1)
  printf '  %10d MB  %s  (%s)\n' "$((JUNK_ADD / 1024))" "$1" "$2"
}
junk() { row "$1" "$2"; junk_kb=$((junk_kb + JUNK_ADD)); }
section() { echo; echo "== $1"; }

section "Agent worktrees (junk once the agent is finished)"
for d in "$MAIN"/.claude/worktrees/*/; do [ -d "$d" ] && junk "worktree" "${d%/}"; done
section "GPU copies on Windows (eterra-gpu is the only allowed copy)"
for d in /mnt/c/Users/*/tools/eterra-gpu*; do [ -d "$d" ] && junk "gpu copy" "$d"; done
for d in /mnt/c/Users/*/tools/godot*; do [ -d "$d" ] && row "godot for windows (kept)" "$d"; done
section "Backups and archives next to the project"
for d in "$PARENT"/eterra-backups/*; do [ -e "$d" ] && junk "backup" "$d"; done
section "Caches"
junk "godot cache" "$HOME/.cache/godot"
junk "project import cache" "$MAIN/.godot"
section "Builds and captures inside the project"
row "build/" "$MAIN/build"
row "docs/gallery" "$MAIN/docs/gallery"
row "docs/qa" "$MAIN/docs/qa"
section "Sources (kept)"
row "assets" "$MAIN/assets"
row "assets/baked (cap 70 MB)" "$MAIN/assets/baked"
row "audio" "$MAIN/audio"
row "PO originals (never cleaned)" "$MAIN/docs/art/ref"
row "PO originals (never cleaned)" "$PARENT/eterra-downloads-backup"
section "Total"
printf '  junk listed above: %d MB (warns above %d GB)\n' "$((junk_kb / 1024))" "$LIMIT_GB"
if [ "$junk_kb" -gt $((LIMIT_GB * 1048576)) ]; then
  echo "  WARNING: more than ${LIMIT_GB} GB of junk; clean by hand (this script deletes nothing)"
fi
df -h "$MAIN" /mnt/c 2>/dev/null | sed 's/^/  /'
