#!/usr/bin/env bash
set -euo pipefail

runner=gemini.sh

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
  printf '%s\n\n' "The diff under review is everything between the BEGIN DIFF and END DIFF lines."
  printf 'BEGIN DIFF\n'
  cat "$diff_file"
  printf '\nEND DIFF\n'
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

command -v gemini >/dev/null 2>&1 || fail "gemini is not on PATH; install it with npm install -g @google/gemini-cli and sign in once interactively or set GEMINI_API_KEY"
command -v jq >/dev/null 2>&1 || fail "jq is not on PATH; the gemini runner reads its JSON output with jq"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

build_prompt > "$work_dir/prompt.md"

status=0
gemini -p "Review the change above as instructed and reply with only the report." \
  --output-format json -m "$model" --approval-mode default \
  < "$work_dir/prompt.md" > "$work_dir/result.json" 2> "$work_dir/stderr" || status=$?

error_message=$(jq -r '.error.message // (.error | select(. != null) | tostring) // empty' "$work_dir/result.json" 2>/dev/null || true)

if [[ $status -ne 0 || -n "$error_message" ]]; then
  tail -n 20 "$work_dir/stderr" >&2 || true
  fail "gemini failed with status $status: ${error_message:-see the output above}" "$(( status == 0 ? 1 : status ))"
fi

jq -r '.response // empty' "$work_dir/result.json" > "$work_dir/report.md" 2>/dev/null || {
  tail -n 20 "$work_dir/stderr" >&2 || true
  tail -n 20 "$work_dir/result.json" >&2 || true
  fail "gemini did not return JSON"
}

[[ -n "$(tr -d '[:space:]' < "$work_dir/report.md")" ]] || fail "gemini returned an empty response"

mkdir -p "$(dirname "$output_path")"
cp "$work_dir/report.md" "$output_path"

grep -q '^## Declined to judge' "$output_path" || fail "the report in $output_path does not follow the contract: it has no ## Declined to judge list" 3
