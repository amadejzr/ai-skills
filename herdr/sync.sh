#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config="${HERDR_APP_CONFIG:-$HOME/.config/herdr-app}"

files=(settings.json keys.json layouts/amadej.json themes/ghostty.json)

usage() {
  echo "usage: $0 pull|push" >&2
  echo "  pull  copy the user-owned Herdr files from $config into this folder" >&2
  echo "  push  copy this folder's files into $config (Herdr applies them live)" >&2
  exit 2
}

copy() {
  local from="$1" to="$2"
  for f in "${files[@]}"; do
    mkdir -p "$to/$(dirname "$f")"
    cp "$from/$f" "$to/$f"
  done
}

case "${1:-}" in
  pull) copy "$config" "$here" ;;
  push) copy "$here" "$config" ;;
  *) usage ;;
esac
