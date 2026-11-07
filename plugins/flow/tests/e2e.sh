#!/usr/bin/env bash
set -uo pipefail

plugin="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
references="$plugin/references"
size_limit=20000

usage() {
  cat <<'EOF'
usage: e2e.sh run <recommended|grilled> [workdir]   scaffold a sample repo, run /flow:setup headless with every permission bypassed inside it, then grade
       e2e.sh grade <recommended|grilled> <repo>     grade a repo that setup has already run on
       e2e.sh scaffold <dir>                         build the sample repo only

recommended: the one-line offer taken, location committed, tracker github
grilled:     the offer declined, location private, tracker local, domain on, user commits, checkpoint off, implementer sonnet, Checklist dropped from the PR template, a custom migrations reviewer
EOF
  exit 2
}

failures=0
fail() { echo "FAIL: $*"; failures=$((failures + 1)); }
pass() { echo "ok:   $*"; }
check() { local label="$1"; shift; if "$@" >/dev/null 2>&1; then pass "$label"; else fail "$label"; fi; }
check_not() { local label="$1"; shift; if "$@" >/dev/null 2>&1; then fail "$label"; else pass "$label"; fi; }

scaffold() {
  local dir="$1"
  mkdir -p "$dir/src" "$dir/test" "$dir/scripts" "$dir/.github"
  cd "$dir" || exit 1
  git init -q -b main
  git config user.email e2e@example.com
  git config user.name "E2E"
  git remote add origin https://github.com/acme/ledger.git
  cat > package.json <<'EOF'
{
  "name": "ledger",
  "version": "0.4.0",
  "type": "module",
  "scripts": {
    "test": "node --test test/",
    "lint": "node scripts/lint.mjs",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": { "typescript": "^5.6.0" }
}
EOF
  cat > tsconfig.json <<'EOF'
{ "compilerOptions": { "allowJs": true, "checkJs": true, "noEmit": true, "module": "esnext", "target": "es2022", "strict": true }, "include": ["src"] }
EOF
  cat > scripts/lint.mjs <<'EOF'
import { readdirSync, readFileSync } from "node:fs";
let bad = 0;
for (const f of readdirSync("src")) {
  const text = readFileSync(`src/${f}`, "utf8");
  if (/console\.log/.test(text)) { console.error(`${f}: console.log`); bad = 1; }
}
process.exit(bad);
EOF
  cat > src/money.js <<'EOF'
export function add(a, b) {
  return { cents: a.cents + b.cents, currency: assertSame(a, b) };
}
function assertSame(a, b) {
  if (a.currency !== b.currency) throw new Error("currency mismatch");
  return a.currency;
}
EOF
  cat > src/ledger.js <<'EOF'
import { add } from "./money.js";
export class Ledger {
  constructor() { this.entries = []; }
  post(entry) { this.entries.push(entry); }
  balance(account) {
    return this.entries.filter(e => e.account === account).map(e => e.amount).reduce(add, { cents: 0, currency: "EUR" });
  }
}
EOF
  cat > src/http.js <<'EOF'
import { createServer } from "node:http";
import { Ledger } from "./ledger.js";
export function serve(ledger = new Ledger()) {
  return createServer((req, res) => {
    const account = new URL(req.url, "http://x").searchParams.get("account");
    res.setHeader("content-type", "application/json");
    res.end(JSON.stringify(ledger.balance(account)));
  });
}
EOF
  cat > test/money.test.js <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { add } from "../src/money.js";
test("adds same currency", () => {
  assert.deepEqual(add({ cents: 1, currency: "EUR" }, { cents: 2, currency: "EUR" }), { cents: 3, currency: "EUR" });
});
EOF
  cat > test/ledger.test.js <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { Ledger } from "../src/ledger.js";
test("balance sums an account", () => {
  const l = new Ledger();
  l.post({ account: "cash", amount: { cents: 500, currency: "EUR" } });
  l.post({ account: "cash", amount: { cents: 250, currency: "EUR" } });
  assert.equal(l.balance("cash").cents, 750);
});
EOF
  cat > CONTRIBUTING.md <<'EOF'
# Contributing

- Money is always `{ cents, currency }`; never use floating point for amounts.
- Every module exports named functions; no default exports.
- Tests use `node:test` and live in `test/`, one file per module.
- Commits follow Conventional Commits with a scope, e.g. `feat(ledger): ...`.
- No `console.log` in `src/`; `npm run lint` fails on it.
EOF
  cat > .github/PULL_REQUEST_TEMPLATE.md <<'EOF'
## Summary

## Changes

## Testing

## Checklist
- [ ] Tests added or updated
- [ ] `npm run lint` passes
EOF
  cat > README.md <<'EOF'
# ledger

A tiny double-entry ledger with an HTTP balance endpoint.

- `npm test` runs the tests.
- `npm run lint` forbids console.log in src.
EOF
  printf 'node_modules\n' > .gitignore
  git add -A && git commit -qm "chore: initial project skeleton"
  local messages=(
    "feat(money): add money type and add()" "test(money): cover add" "feat(ledger): post entries" "feat(ledger): compute balance"
    "test(ledger): balance sums an account" "feat(http): serve balances over http" "docs: describe commands in readme" "chore: add lint script"
    "fix(money): reject currency mismatch" "refactor(ledger): extract filter" "docs(contributing): money rules" "chore(ci): add pr template"
    "feat(ledger): accept EUR default" "fix(http): default account param" "test(http): smoke test placeholder" "refactor(money): rename helper"
    "docs: typo" "chore: bump version 0.2.0" "feat(ledger): entries accessor" "fix(ledger): empty balance is zero" "perf(ledger): avoid double map"
    "chore: bump version 0.3.0" "docs(contributing): named exports rule" "refactor(http): json header once" "fix(lint): exit code"
    "test(money): mismatch throws" "feat(http): content type header" "chore: bump version 0.4.0" "docs: readme polish"
  )
  local i=0
  for m in "${messages[@]}"; do
    i=$((i + 1))
    echo "$i" >> .history
    git add -A
    git commit -qm "$m"
  done
}

prompt_for() {
  case "$1" in
    recommended) echo "/flow:setup I am running this unattended, so take my answers up front: I accept the recommended set, location committed, tracker github. Accept every improvement you mark recommended, decline the rest. Do not stop to ask; explore, state the choices, generate, run the verify commands and give the step 6 report." ;;
    grilled) echo "/flow:setup I am running this unattended, so take my answers up front and do not stop to ask. I decline the one-line offer; run the grilling rounds, but answer them for me from these decisions and accept your recommendation for anything not listed: location private; tracker local; domain on; commits conventional, the user commits (no agent commits); checkpoint off; worktrees git; implementer model sonnet; drop the Checklist section from the PR template; add one custom reviewer named migrations that runs as a Claude agent on opus for files under src/ touching persistence or the http contract. Accept every improvement you mark recommended, decline the rest. Then generate, run the verify commands and give the step 6 report." ;;
    *) usage ;;
  esac
}

run_setup() {
  local mode="$1" repo="$2" out="$3"
  echo "Running /flow:setup ($mode) in $repo with every permission bypassed inside that directory."
  (cd "$repo" && env -u CLAUDECODE claude -p "$(prompt_for "$mode")" \
    --plugin-dir "$plugin" --permission-mode bypassPermissions \
    --output-format json --max-turns 300 > "$out" 2> "$out.err")
  python3 -I - "$out" <<'EOF'
import json, sys
d = json.load(open(sys.argv[1]))
print(f"turns {d.get('num_turns')}  cost ${d.get('total_cost_usd', 0):.2f}  minutes {d.get('duration_ms', 0) // 60000}  {d.get('subtype')}")
print(d.get("result", "")[:1500])
EOF
}

table_paths() {
  awk '$0 == "## What every repo gets" { inside = 1; next } inside && /^## / { exit } inside' "$references/workflow.md" \
    | grep '^| `' | awk -F'|' -v when="$1" '$4 ~ when { print $2 }' \
    | while IFS= read -r cell; do
        local first="" item
        for item in $(printf '%s' "$cell" | grep -oE '`[^`]+`' | tr -d '`'); do
          if [[ -z "$first" ]]; then first="$item"; echo "$item"; else echo "$(dirname "$first")/$item"; fi
        done
      done
}

path_present() {
  local repo="$1" p="$2"
  if [[ "$p" == */ ]]; then [[ -f "$repo/${p}SKILL.md" ]]; else [[ -f "$repo/$p" ]]; fi
}

grade_common() {
  local repo="$1" p
  while IFS= read -r p; do
    check "exists $p" path_present "$repo" "$p"
  done < <(table_paths '^ always')
  check "no {setup: span left" bash -c "! grep -rl '{setup:' '$repo/.claude/skills' '$repo/.claude/agents'"
  check "no CLAUDE_PLUGIN_ROOT" bash -c "! grep -rl 'CLAUDE_PLUGIN_ROOT' '$repo/.claude/skills' '$repo/.claude/agents'"
  check "no file at or over $size_limit bytes" bash -c "[[ -z \"\$(find -L '$repo/.claude' -type f -size +$((size_limit - 1))c)\" ]]"
  check "no em dash" bash -c "! grep -rl \$'\xe2\x80\x94' '$repo/.claude'"
  check "grilling byte-identical" diff -r "$references/verbatim/grilling" "$repo/.claude/skills/grilling"
  check "tdd byte-identical" diff -r "$references/verbatim/tdd" "$repo/.claude/skills/tdd"
  check "CONTRACT.md byte-identical" cmp -s "$references/reviewers/CONTRACT.md" "$repo/.claude/skills/review/CONTRACT.md"
  local record="$repo/.claude/flow/setup.md"
  check "setup record sections in order" bash -c "[[ \"\$(grep -E '^## ' '$record' | tr '\n' '|')\" == '## Plugin version|## Answers|## Improvements|## Reviewers|## Generated|' ]]"
  local version
  version="$(python3 -I -c "import json,sys; print(json.load(open(sys.argv[1]))['version'])" "$plugin/.claude-plugin/plugin.json")"
  check "setup record names plugin version $version" grep -q "^$version, set up " "$record"
  local skill
  for skill in flow grill spec tickets implement implement-spec retro; do
    check "$skill is user-only" bash -c "awk 'NR == 1 { next } /^---$/ { exit } { print }' '$repo/.claude/skills/$skill/SKILL.md' | grep -q '^disable-model-invocation: true'"
  done
  for skill in review fix pr research; do
    check_not "$skill is model-invoked" bash -c "awk 'NR == 1 { next } /^---$/ { exit } { print }' '$repo/.claude/skills/$skill/SKILL.md' | grep -q 'disable-model-invocation'"
  done
  check "at least one reviewer file" bash -c "ls '$repo/.claude/skills/review/reviewers/'*.md"
  local reviewer key
  for reviewer in "$repo"/.claude/skills/review/reviewers/*.md; do
    for key in model paths inputs condition runner; do
      check "$(basename "$reviewer") has $key" bash -c "awk 'NR == 1 { next } /^---$/ { exit } { print }' '$reviewer' | grep -q '^$key:'"
    done
  done
  check "implement carries the repo's test command" grep -q 'npm test' "$repo/.claude/skills/implement/SKILL.md"
  check "flow map names the loop" grep -q '/implement' "$repo/.claude/skills/flow/SKILL.md"
  check ".worktrees ignored" git -C "$repo" check-ignore -q .worktrees/x
}

grade_recommended() {
  local repo="$1" record="$repo/.claude/flow/setup.md"
  check "answers say committed" grep -q '^- location: committed' "$record"
  check "answers say github" grep -q '^- tracker: github' "$record"
  check_not "domain-modeling absent when domain is off" test -d "$repo/.claude/skills/domain-modeling"
  check "committed files show in git status" bash -c "git -C '$repo' status --porcelain | grep -q '\.claude'"
  check "tickets publish through gh" grep -q 'gh issue' "$repo/.claude/skills/tickets/SKILL.md"
  check "implement reads tickets through gh" grep -q 'gh issue' "$repo/.claude/skills/implement/SKILL.md"
  check "PR template keeps the Checklist" grep -q '^## Checklist' "$repo/.claude/skills/pr/template.md"
}

grade_grilled() {
  local repo="$1" record="$repo/.claude/flow/setup.md" exclude
  exclude="$(git -C "$repo" rev-parse --path-format=absolute --git-common-dir)/info/exclude"
  check "answers say private" grep -q '^- location: private' "$record"
  check "answers say local" grep -q '^- tracker: local' "$record"
  check "answers say domain on" grep -q '^- domain: on' "$record"
  check "answers say checkpoint off" grep -q '^- checkpoint: off' "$record"
  check "answers say implementer sonnet" grep -q 'implementer sonnet' "$record"
  check "domain-modeling byte-identical" diff -r "$references/verbatim/domain-modeling" "$repo/.claude/skills/domain-modeling"
  check "implementer agent on sonnet" grep -q '^model: sonnet' "$repo/.claude/agents/implementer.md"
  check "migrations reviewer written" test -f "$repo/.claude/skills/review/reviewers/migrations.md"
  check_not "PR template drops the Checklist" grep -q '^## Checklist' "$repo/.claude/skills/pr/template.md"
  check_not "tickets do not publish through gh" grep -q 'gh issue' "$repo/.claude/skills/tickets/SKILL.md"
  check "exclude file lists the flow directory" grep -qx '/.claude/flow' "$exclude"
  check "exclude file lists .worktrees" grep -qx '/.worktrees' "$exclude"
  check_not "nothing under .claude shows in git status" bash -c "git -C '$repo' status --porcelain | grep -q '\.claude'"
}

grade() {
  local mode="$1" repo="$2"
  [[ -d "$repo/.claude" ]] || { echo "no .claude in $repo"; exit 1; }
  grade_common "$repo"
  case "$mode" in
    recommended) grade_recommended "$repo" ;;
    grilled) grade_grilled "$repo" ;;
    *) usage ;;
  esac
  if (( failures > 0 )); then echo "$failures check(s) failed"; exit 1; fi
  echo "all passed"
}

command="${1:-}"
case "$command" in
  scaffold) [[ -n "${2:-}" ]] || usage; scaffold "$(mkdir -p "$2" && cd "$2" && pwd -P)" ;;
  grade) [[ -n "${2:-}" && -n "${3:-}" ]] || usage; prompt_for "$2" >/dev/null; grade "$2" "$(cd "$3" && pwd -P)" ;;
  run)
    [[ -n "${2:-}" ]] || usage
    prompt_for "$2" >/dev/null
    workdir_arg="${3:-$(mktemp -d)}"
    workdir="$(mkdir -p "$workdir_arg" && cd "$workdir_arg" && pwd -P)"
    repo="$workdir/$2"
    rm -rf "$repo"
    scaffold "$repo"
    run_setup "$2" "$repo" "$workdir/$2.json"
    grade "$2" "$repo"
    ;;
  *) usage ;;
esac
