#!/usr/bin/env bash
# Compare the forked upstream files against their sources on GitHub.
#   upstream-check.sh            status per tracked file
#   upstream-check.sh --diff     status plus unified diffs
#   upstream-check.sh --accept   copy the current upstream files into the baseline and record the commit
set -euo pipefail

mode="${1:-status}"
plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
baseline_root="$plugin_root/upstream"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

changed=0
for source_dir in "$baseline_root"/*/; do
  name="$(basename "$source_dir")"
  url="$(sed -n 's/^url=//p' "$source_dir/SOURCE")"
  old_sha="$(sed -n 's/^sha=//p' "$source_dir/SOURCE")"
  git clone --quiet --depth 1 "$url" "$work/$name"
  new_sha="$(git -C "$work/$name" rev-parse HEAD)"
  echo "== $name  ${old_sha:0:7} -> ${new_sha:0:7}"

  while IFS= read -r file; do
    rel="${file#"$source_dir"}"
    upstream_file="$work/$name/$rel"
    if [[ ! -f "$upstream_file" ]]; then
      echo "  missing upstream: $rel"
      changed=1
    elif cmp -s "$file" "$upstream_file"; then
      echo "  unchanged: $rel"
    else
      echo "  CHANGED: $rel"
      changed=1
      if [[ "$mode" == "--diff" ]]; then
        diff -u "$file" "$upstream_file" | sed 's/^/    /' || true
      fi
    fi
    if [[ "$mode" == "--accept" && -f "$upstream_file" ]]; then
      cp "$upstream_file" "$file"
    fi
  done < <(find "$source_dir" -type f ! -name SOURCE | sort)

  if [[ "$mode" == "--accept" ]]; then
    printf 'url=%s\nsha=%s\nchecked=%s\n' "$url" "$new_sha" "$(date +%F)" > "$source_dir/SOURCE"
    echo "  baseline accepted at ${new_sha:0:7}"
  fi
done

if [[ "$mode" != "--accept" ]]; then
  [[ $changed -eq 0 ]] && echo "no upstream changes" || echo "upstream changes found; run /flow:upstream to port them"
fi
