#!/usr/bin/env bash
#
# Copilot‑TreeSize (Linux)
# Minimaler TreeSize‑ähnlicher Überblick für Ubuntu‑Bash.
# Features:
#   - nach Größe sortiert (größte zuerst)
#   - farbige Größen (je größer, desto „heißer“)
#   - einfache Tiefen‑Indentation
# Usage:
#   ./copilot-treesize.sh [Pfad] [Tiefe]
# Beispiel:
#   ./copilot-treesize.sh /var/log 3
#

set -euo pipefail

TARGET="${1:-.}"
MAX_DEPTH="${2:-4}"

RED=$'\033[31m'
MAG=$'\033[35m'
YEL=$'\033[33m'
CYA=$'\033[36m'
GRN=$'\033[32m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

if ! [ -d "$TARGET" ]; then
  echo "Error: '$TARGET' is not a directory" >&2
  exit 1
fi

du -b --max-depth="$MAX_DEPTH" "$TARGET" 2>/dev/null \
| sort -h -r \
| awk -F'\t' -v RED="$RED" -v MAG="$MAG" -v YEL="$YEL" -v CYA="$CYA" -v GRN="$GRN" -v BOLD="$BOLD" -v RESET="$RESET" '
function color(n) {
  if (n > 1073741824) return RED
  if (n > 536870912) return MAG
  if (n > 134217728) return YEL
  if (n > 33554432) return CYA
  return GRN
}
function human(n) {
  if (n < 1024) return n " B"
  if (n < 1048576) return sprintf("%.1f KB", n/1024)
  if (n < 1073741824) return sprintf("%.1f MB", n/1048576)
  return sprintf("%.1f GB", n/1073741824)
}
{
  size=$1
  path=$2
  depth=gsub("/", "/", path)
  indent=""
  for (i=1; i<depth; i++) indent=indent "  "
  printf "%s%s%s%s  %s\n", indent, color(size), human(size), RESET, path
}
'
