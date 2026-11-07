#!/usr/bin/env bash
set -uo pipefail

plugin="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
references="$plugin/references"
upstream_skills="$plugin/upstream/mattpocock-skills/skills"
size_limit=20000
sandbox="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$sandbox"' EXIT

failures=0
fail() { echo "FAIL [$test_name]: $*"; failures=$((failures + 1)); }
check() { "$@" || fail "expected: $*"; }

under_size_limit() {
  local bytes
  bytes="$(wc -c < "$1" | tr -d ' ')"
  (( bytes < size_limit )) || { echo "$1 is $bytes bytes"; return 1; }
}

upstream_twin() {
  local rel="${1#"$references/verbatim/"}"
  find "$upstream_skills" -path "*/skills/*/$rel" -type f
}

identical_to_upstream() {
  local twin
  twin="$(upstream_twin "$1")"
  [[ -n "$twin" && "$(printf '%s\n' "$twin" | wc -l | tr -d ' ')" -eq 1 ]] || { echo "no single upstream file for $1"; return 1; }
  cmp -s "$1" "$twin" || { echo "$1 differs from $twin"; return 1; }
}

section() {
  awk -v heading="$2" '$0 == heading { inside = 1; next } inside && /^## / { exit } inside' "$1"
}

backticked_paths() {
  grep -oE '`[^`]+`' | tr -d '`' | grep -E '^(recipes|verbatim|reviewers|trackers|runners)/' | grep -v '<'
}

workflow_named_paths() {
  local workflow="$references/workflow.md"
  section "$workflow" "## What every repo gets" | grep '^|' | cut -d'|' -f3 | backticked_paths
  grep -E '^The (recipes|trackers|runners) are ' "$workflow" | backticked_paths
  grep -E '^The reviewer catalogue is ' "$workflow" | grep -oE '`[^`]+`' | tr -d '`' | sed -E 's#^([a-z0-9-]+\.md)$#reviewers/catalogue/\1#'
}

recipe_sections_in_order() {
  local order
  order="$(grep -E '^## (Frontmatter|Varies by|Skill text|Sibling files|Handoffs)$' "$1" | awk '!seen[$0]++' | tr '\n' '|')"
  [[ "$order" == "## Frontmatter|## Varies by|## Skill text|## Sibling files|## Handoffs|" ]] || { echo "$1 sections: $order"; return 1; }
  [[ "$(head -1 "$1")" == "# $(basename "$1" .md)" ]] || { echo "$1 does not start with # $(basename "$1" .md)"; return 1; }
}

not_warned() {
  ! awk '/^Plugin directory checks/ { exit } { print }' "$1" | grep -iE 'found [0-9]+ (warning|error)'
}

no_em_dash() {
  ! grep -n $'\xe2\x80\x94' "$1"
}

test_name="every skill, recipe and reference is under $size_limit bytes"
while IFS= read -r file; do
  check under_size_limit "$file"
done < <(find "$plugin/skills" "$references" -type f | sort)

test_name="every verbatim file is byte-identical to its upstream baseline"
verbatim_count=0
while IFS= read -r file; do
  verbatim_count=$((verbatim_count + 1))
  check identical_to_upstream "$file"
done < <(find "$references/verbatim" -type f | sort)
check test "$verbatim_count" -gt 0
for skill_dir in "$references"/verbatim/*/; do
  skill="$(basename "$skill_dir")"
  while IFS= read -r upstream_file; do
    check test -f "$skill_dir$(basename "$upstream_file")"
  done < <(find "$upstream_skills"/*/"$skill" -maxdepth 1 -type f)
done

test_name="every recipe, tracker, runner and catalogue file named in workflow.md exists"
named="$sandbox/named"
workflow_named_paths | sort -u > "$named"
for kind in recipes trackers runners reviewers/catalogue verbatim; do
  check grep -q "^$kind/" "$named"
done
while IFS= read -r path; do
  check test -e "$references/$path"
done < "$named"
for skill in flow grill spec tickets implement implement-spec review fix pr research retro; do
  check grep -qx "recipes/$skill.md" "$named"
done
for tracker in local github gitlab other; do
  check grep -qx "trackers/$tracker.md" "$named"
done

test_name="every recipe, tracker and runner on disk is named in workflow.md"
while IFS= read -r file; do
  check grep -qx "${file#"$references/"}" "$named"
done < <(find "$references/recipes" "$references/trackers" -name '*.md' -type f; find "$references/runners" -name '*.sh' -type f)

test_name="every recipe has the contract's sections in order"
for recipe in "$references"/recipes/*.md; do
  check recipe_sections_in_order "$recipe"
done

test_name="every shell script parses"
while IFS= read -r script; do
  check bash -n "$script"
done < <(find "$references/runners" "$plugin/scripts" "$plugin/tests" -name '*.sh' -type f | sort)

test_name="no em dash outside the verbatim files"
while IFS= read -r file; do
  check no_em_dash "$file"
done < <(find "$plugin/skills" "$references" -type f ! -path "$references/verbatim/*" | sort)

test_name="the plugin ships one user-invoked skill and a pinned version"
check test "$(find "$plugin/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -eq 1
check test -f "$plugin/skills/setup/SKILL.md"
check grep -qx 'disable-model-invocation: true' "$plugin/skills/setup/SKILL.md"
check grep -qE '"version": "[0-9]+\.[0-9]+\.[0-9]+"' "$plugin/.claude-plugin/plugin.json"
check test ! -e "$plugin/agents"
check test ! -e "$plugin/generator"
check test ! -e "$plugin/scripts/generate.sh"

test_name="claude plugin validate is clean"
if command -v claude >/dev/null 2>&1; then
  claude plugin validate "$plugin" > "$sandbox/validate" 2>&1 || fail "$(cat "$sandbox/validate")"
  check not_warned "$sandbox/validate"
else
  echo "skip [$test_name]: claude is not on PATH"
fi

if (( failures )); then
  echo "$failures failed"
  exit 1
fi
echo "all passed"
