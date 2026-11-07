#!/usr/bin/env bash
set -euo pipefail

runner=opencode.sh

usage() {
  echo "usage: $runner <diff-file> <reviewer-file> <contract-file> <output-path> [input-file...]" >&2
  exit 2
}

fail() {
  echo "$runner: $1" >&2
  exit "${2:-1}"
}

frontmatter_value() {
  awk -v key="$1" '
    NR == 1 && $0 == "---" { inside = 1; next }
    inside && $0 == "---" { exit }
    inside && index($0, key ":") == 1 { sub("^" key ":[ \t]*", ""); print; exit }
  ' "$2" | sed -E "s/^[\"']//; s/[\"'][[:space:]]*\$//; s/[[:space:]]+\$//"
}

reviewer_body() {
  awk '
    NR == 1 && $0 == "---" { inside = 1; next }
    inside && $0 == "---" { inside = 0; next }
    !inside { print }
  ' "$1"
}

build_prompt() {
  printf '%s\n' "You are one reviewer in a multi-reviewer code review, running non-interactively with read-only access to this repository."
  printf '%s\n' "Follow the reviewer contract for scope, severity, confidence and output, and judge the change strictly through your reviewer instructions."
  printf '%s\n\n' "Your final message is the report itself in the contract's output format: the opening line, one block per finding with its rule field, and the Declined to judge list, with nothing before or after it."
  cat "$contract_file"
  printf '\n# Reviewer instructions\n\n'
  reviewer_body "$reviewer_file"
  local input_file
  for input_file in "${input_files[@]+"${input_files[@]}"}"; do
    printf '\n# Input: %s\n\n' "$input_file"
    cat "$input_file"
  done
  printf '\n# The change\n\n'
  diff_section
}

diff_section() {
  printf '%s\n' "The diff under review is the attached file $(basename "$diff_file")."
}

[[ $# -ge 4 ]] || usage
diff_file=$1
reviewer_file=$2
contract_file=$3
output_path=$4
shift 4
input_files=("$@")

for required_file in "$diff_file" "$reviewer_file" "$contract_file" "${input_files[@]+"${input_files[@]}"}"; do
  [[ -f "$required_file" ]] || fail "no such file: $required_file" 2
done

model=$(frontmatter_value model "$reviewer_file")
[[ -n "$model" ]] || fail "no model: in the frontmatter of $reviewer_file" 2

command -v opencode >/dev/null 2>&1 || fail "opencode is not on PATH; install it from https://opencode.ai and sign in with opencode auth login"
command -v jq >/dev/null 2>&1 || fail "jq is not on PATH; the opencode runner reads its JSON events with jq"
[[ "$model" == */* ]] || fail "model $model in $reviewer_file is not in opencode's provider/model form" 2

read_only_config='{"permission":{"edit":"deny","webfetch":"deny","websearch":"deny","task":"deny","bash":{"*":"deny","git diff*":"allow","git log*":"allow","git show*":"allow","git ls-files*":"allow","git grep*":"allow"}}}'

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

build_prompt > "$work_dir/prompt.md"

status=0
OPENCODE_CONFIG_CONTENT="$read_only_config" opencode run --format json -m "$model" -f "$diff_file" \
  < "$work_dir/prompt.md" > "$work_dir/events.jsonl" 2> "$work_dir/stderr" || status=$?

error_message=$(jq -rRs '[split("\n")[] | fromjson? | select(.type == "error") | (.error.message // .error.data.message // (.error | tostring))] | last // empty' "$work_dir/events.jsonl")

if [[ $status -ne 0 || -n "$error_message" ]]; then
  tail -n 20 "$work_dir/stderr" >&2 || true
  fail "opencode failed with status $status: ${error_message:-see the output above}" "$(( status == 0 ? 1 : status ))"
fi

jq -rRs '[split("\n")[] | fromjson? | select(.type == "text") | .part.text] | last // empty' "$work_dir/events.jsonl" > "$work_dir/report.md"

[[ -n "$(tr -d '[:space:]' < "$work_dir/report.md")" ]] || {
  tail -n 20 "$work_dir/stderr" >&2 || true
  fail "opencode returned no text"
}

mkdir -p "$(dirname "$output_path")"
cp "$work_dir/report.md" "$output_path"

grep -q '^## Declined to judge' "$output_path" || fail "the report in $output_path does not follow the contract: it has no ## Declined to judge list" 3
