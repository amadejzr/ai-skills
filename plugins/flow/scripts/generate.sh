#!/usr/bin/env bash
# Compose the generator templates into a project's .claude/ directory.
#   generate.sh --out <project> [--templates <dir>] [--<setting> <value> ...]   write skills, agents, the flow data dirs, and .claude/flow/settings with the values used
#   generate.sh --check <project>     list every "<!-- fill: ... -->" still present; fails while any remains
#   generate.sh --exclude <project>   add the generated paths to the repo's .git/info/exclude (private mode)
#   generate.sh --include <project>   remove them again (committed mode)
# Settings, values and directives: generator/README.md
set -euo pipefail

plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
templates="$plugin_root/generator"
action=""
target=""

keys="mode scope pacing commits gate stops tracker domain reviewers implementer_model builder_model research_model research_agents"
setting_mode=private
setting_scope=ticket
setting_pacing=checkpoint
setting_commits=agent
setting_gate=none
setting_stops="seams,spec,builder,tickets"
setting_tracker=local
setting_domain=off
setting_reviewers="spec,correctness"
setting_implementer_model=opus
setting_builder_model=opus
setting_research_model=opus
setting_research_agents=1

models="opus sonnet haiku fable"
allowed() {
  case "$1" in
    mode) echo "private committed" ;;
    scope) echo "ticket epic" ;;
    pacing) echo "checkpoint autonomous" ;;
    commits) echo "agent user" ;;
    gate) echo "none confirm grill" ;;
    tracker) echo "local github gitlab other" ;;
    domain) echo "off on" ;;
    implementer_model|builder_model|research_model) echo "$models" ;;
  esac
}
value_of() { eval "printf '%s' \"\$setting_$1\""; }
is_key() { [[ " $keys " == *" $1 "* ]]; }

usage() { sed -n '2,7p' "${BASH_SOURCE[0]}" >&2; exit 2; }

while (($#)); do
  case "$1" in
    --out|--check|--exclude|--include)
      [[ -n "$action" ]] && usage
      action="${1#--}"; target="${2:-}"; [[ -n "$target" ]] || usage; shift 2 ;;
    --templates) templates="$(cd "$2" && pwd)"; shift 2 ;;
    --*)
      key="${1#--}"; key="${key//-/_}"
      is_key "$key" || { echo "unknown setting: $1" >&2; exit 2; }
      eval "setting_$key=\"\${2:-}\""; shift 2 ;;
    *) usage ;;
  esac
done
[[ -n "$action" ]] || usage

validate() {
  local key value choices item
  for key in $keys; do
    choices="$(allowed "$key")"
    [[ -n "$choices" ]] || continue
    value="$(value_of "$key")"
    [[ " $choices " == *" $value "* ]] || { echo "invalid --${key//_/-}: $value (one of $choices)" >&2; exit 2; }
  done
  [[ "$setting_research_agents" =~ ^[1-9][0-9]*$ ]] || { echo "invalid --research-agents: $setting_research_agents" >&2; exit 2; }
  if [[ "$setting_stops" != none ]]; then
    for item in ${setting_stops//,/ }; do
      [[ " seams spec builder tickets " == *" $item "* ]] || { echo "invalid --stops item: $item" >&2; exit 2; }
    done
  fi
  for item in ${setting_reviewers//,/ }; do
    [[ -f "$templates/agents/$item-reviewer.md" ]] || { echo "no reviewer template: $item (have: $(ls "$templates/agents" | sed -n 's/-reviewer\.md$//p' | tr '\n' ' '))" >&2; exit 2; }
  done
}

settings_blob() {
  local key
  for key in $keys; do printf '%s=%s;' "$key" "$(value_of "$key")"; done
  printf 'flow_dir=.claude/flow'
}

render() {
  awk -v settings="$(settings_blob)" '
    BEGIN {
      n = split(settings, kv, ";")
      for (i = 1; i <= n; i++) if (kv[i] != "") { j = index(kv[i], "="); S[substr(kv[i], 1, j - 1)] = substr(kv[i], j + 1) }
      depth = 0
    }
    function die(msg) { print FILENAME ":" FNR ": " msg > "/dev/stderr"; exit 3 }
    function truth(cond,    key, op, val, m, parts, k) {
      if (!match(cond, /[=~]/)) die("bad condition: " cond)
      key = substr(cond, 1, RSTART - 1); op = substr(cond, RSTART, 1); val = substr(cond, RSTART + 1)
      if (!(key in S)) die("unknown setting in condition: " key)
      if (op == "=") {
        m = split(val, parts, "|")
        for (k = 1; k <= m; k++) if (S[key] == parts[k]) return 1
        return 0
      }
      m = split(S[key], parts, ",")
      for (k = 1; k <= m; k++) if (parts[k] == val) return 1
      return 0
    }
    function active(    i) { for (i = 1; i <= depth; i++) if (!st[i]) return 0; return 1 }
    function substitute(line,    key, out, pos, token) {
      for (key in S) {
        token = "{{" key "}}"
        out = ""
        while ((pos = index(line, token)) > 0) { out = out substr(line, 1, pos - 1) S[key]; line = substr(line, pos + length(token)) }
        line = out line
      }
      return line
    }
    /^<!-- if .* -->$/ { cond = $0; sub(/^<!-- if /, "", cond); sub(/ -->$/, "", cond); depth++; st[depth] = truth(cond); next }
    /^<!-- else -->$/ { if (depth == 0) die("else without if"); st[depth] = !st[depth]; next }
    /^<!-- endif -->$/ { if (depth == 0) die("endif without if"); depth--; next }
    { if (active()) print substitute($0) }
    END { if (depth != 0) die("unbalanced if") }
  ' "$1"
}

generated_manifest() { echo "$1/.claude/flow/generated"; }

compose() {
  validate
  local out="$target" name file rel
  local manifest; manifest="$(generated_manifest "$out")"
  mkdir -p "$out/.claude/skills" "$out/.claude/agents"
  for name in features research; do mkdir -p "$out/.claude/flow/$name"; done
  : > "$manifest"
  for key in $keys; do printf '%s=%s\n' "$key" "$(value_of "$key")"; done > "$out/.claude/flow/settings"
  for dir in "$templates"/skills/*/; do
    name="$(basename "$dir")"
    [[ "$name" == domain-modeling && "$setting_domain" == off ]] && continue
    mkdir -p "$out/.claude/skills/$name"
    for file in "$dir"*; do
      [[ -f "$file" ]] || continue
      render "$file" > "$out/.claude/skills/$name/$(basename "$file")"
    done
    echo ".claude/skills/$name/" >> "$manifest"
  done
  for name in ${setting_reviewers//,/ }; do
    render "$templates/agents/$name-reviewer.md" > "$out/.claude/agents/$name-reviewer.md"
    echo ".claude/agents/$name-reviewer.md" >> "$manifest"
  done
  if [[ "$setting_scope" == epic ]]; then
    render "$templates/agents/implementer.md" > "$out/.claude/agents/implementer.md"
    echo ".claude/agents/implementer.md" >> "$manifest"
  fi
  echo "generated into $out/.claude: $(wc -l < "$manifest" | tr -d ' ') paths" >&2
}

check() {
  local hits
  hits="$(grep -rn '<!-- fill:' "$target/.claude" 2>/dev/null || true)"
  if [[ -n "$hits" ]]; then
    echo "$hits"
    echo "$(echo "$hits" | wc -l | tr -d ' ') fill markers remain" >&2
    exit 1
  fi
  echo "no fill markers remain"
}

exclude_file() { git -C "$target" rev-parse --path-format=absolute --git-path info/exclude; }

exclude_lines() {
  local manifest; manifest="$(generated_manifest "$target")"
  [[ -f "$manifest" ]] || { echo "nothing generated in $target" >&2; exit 1; }
  sed 's|^|/|' "$manifest"
  echo "/.claude/flow/"
}

exclude() {
  local file line; file="$(exclude_file)"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  while read -r line; do grep -qxF "$line" "$file" || echo "$line" >> "$file"; done < <(exclude_lines)
  echo "excluded from git: $(exclude_lines | wc -l | tr -d ' ') paths" >&2
}

include() {
  local file; file="$(exclude_file)"
  [[ -f "$file" ]] || return 0
  grep -vxF -f <(exclude_lines) "$file" > "$file.tmp" || true
  mv "$file.tmp" "$file"
  echo "no longer excluded; commit .claude when ready" >&2
}

case "$action" in
  out) compose ;;
  check) check ;;
  exclude) exclude ;;
  include) include ;;
esac
