#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: upstream-check.sh [--diff | --accept]" >&2
  echo "  no flag   status of every baseline file and every verbatim copy" >&2
  echo "  --diff    the same, with a unified diff per changed file" >&2
  echo "  --accept  copy upstream into the baseline and into references/verbatim/, record the commit" >&2
  exit 2
}

mode="${1:-status}"
case "$mode" in
  status | --diff | --accept) ;;
  *) usage ;;
esac

plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
baseline_root="$plugin_root/upstream"
verbatim_root="$plugin_root/references/verbatim"
verbatim_forks=(
  "grilling:mattpocock-skills/skills/productivity/grilling"
  "tdd:mattpocock-skills/skills/engineering/tdd"
  "domain-modeling:mattpocock-skills/skills/engineering/domain-modeling"
)
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

echo "== verbatim copies in references/verbatim/"
for fork in "${verbatim_forks[@]}"; do
  skill="${fork%%:*}"
  baseline_dir="$baseline_root/${fork#*:}"
  while IFS= read -r baseline_file; do
    file_name="$(basename "$baseline_file")"
    verbatim_file="$verbatim_root/$skill/$file_name"
    if [[ "$mode" == "--accept" ]]; then
      mkdir -p "$verbatim_root/$skill"
      cp "$baseline_file" "$verbatim_file"
      echo "  copied: $skill/$file_name"
    elif [[ ! -f "$verbatim_file" ]]; then
      echo "  missing verbatim: $skill/$file_name"
      changed=1
    elif cmp -s "$baseline_file" "$verbatim_file"; then
      echo "  identical: $skill/$file_name"
    else
      echo "  DIFFERS FROM BASELINE: $skill/$file_name"
      changed=1
      if [[ "$mode" == "--diff" ]]; then
        diff -u "$baseline_file" "$verbatim_file" | sed 's/^/    /' || true
      fi
    fi
  done < <(find "$baseline_dir" -maxdepth 1 -type f | sort)
done

if [[ "$mode" != "--accept" ]]; then
  if [[ $changed -eq 0 ]]; then
    echo "no upstream changes"
  else
    echo "upstream changes found; run /upstream in this checkout to port them"
  fi
fi
