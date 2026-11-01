#!/usr/bin/env bash
# Tests for scripts/generate.sh against a fixture template set and the real generator.
#   tests/generate.test.sh
set -uo pipefail

plugin="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$plugin/scripts/generate.sh"
sandbox="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$sandbox"' EXIT

failures=0
fail() { echo "FAIL [$test_name]: $*"; failures=$((failures + 1)); }
check() { "$@" || fail "expected: $*"; }
not() { ! "$@"; }

fixture="$sandbox/fixture"
mkdir -p "$fixture/skills/alpha" "$fixture/agents"
cat > "$fixture/skills/alpha/SKILL.md" <<'TPL'
---
name: alpha
---
scope is {{scope}} in {{flow_dir}}
<!-- if scope=ticket -->
ticket line
<!-- else -->
epic line
<!-- endif -->
<!-- if pacing=checkpoint|autonomous -->
pacing known
<!-- if commits=agent -->
agent commits inside
<!-- endif -->
<!-- endif -->
<!-- if stops~builder -->
builder stop
<!-- endif -->
<!-- fill: the commit convention -->
end
TPL
printf 'sibling for {{tracker}}\n' > "$fixture/skills/alpha/ref.md"
printf -- '---\nname: beta-reviewer\nmodel: opus\n---\nbeta rules\n' > "$fixture/agents/beta-reviewer.md"
printf -- '---\nname: gamma-reviewer\nmodel: opus\n---\ngamma rules\n' > "$fixture/agents/gamma-reviewer.md"
printf -- '---\nname: implementer\nmodel: {{implementer_model}}\n---\nbuild\n' > "$fixture/agents/implementer.md"

test_name="defaults compose the fixture"
out="$sandbox/defaults"
"$script" --templates "$fixture" --out "$out" --reviewers beta >/dev/null 2>"$sandbox/err" || fail "exit $? $(cat "$sandbox/err")"
skill="$out/.claude/skills/alpha/SKILL.md"
check test -f "$skill"
check grep -q '^scope is ticket in .claude/flow$' "$skill"
check grep -q '^ticket line$' "$skill"
check not grep -q 'epic line' "$skill"
check grep -q '^pacing known$' "$skill"
check grep -q '^agent commits inside$' "$skill"
check grep -q '^builder stop$' "$skill"
check grep -q '^<!-- fill: the commit convention -->$' "$skill"
check not grep -q '<!-- if' "$skill"
check not grep -q '<!-- else' "$skill"
check not grep -q '<!-- endif' "$skill"
check grep -q '^sibling for local$' "$out/.claude/skills/alpha/ref.md"
check test -f "$out/.claude/agents/beta-reviewer.md"
check test ! -e "$out/.claude/agents/gamma-reviewer.md"
check test ! -e "$out/.claude/agents/implementer.md"
for d in features research; do check test -d "$out/.claude/flow/$d"; done
check test ! -e "$out/.claude/flow/domain"
check test ! -e "$out/.claude/flow/reviews"
check grep -qx 'scope=ticket' "$out/.claude/flow/settings"
check grep -qx 'reviewers=beta' "$out/.claude/flow/settings"
check not grep -q 'flow_dir' "$out/.claude/flow/settings"

test_name="settings switch branches and agents"
out="$sandbox/epic"
"$script" --templates "$fixture" --out "$out" --scope epic --commits user --stops seams,spec --reviewers beta,gamma --implementer-model sonnet --mode committed >/dev/null 2>&1 || fail "exit $?"
skill="$out/.claude/skills/alpha/SKILL.md"
check grep -q '^scope is epic in .claude/flow$' "$skill"
check grep -q '^epic line$' "$skill"
check not grep -q 'ticket line' "$skill"
check grep -q '^pacing known$' "$skill"
check not grep -q 'agent commits inside' "$skill"
check not grep -q 'builder stop' "$skill"
check test -f "$out/.claude/agents/gamma-reviewer.md"
check grep -q '^model: sonnet$' "$out/.claude/agents/implementer.md"
check grep -qx 'scope=epic' "$out/.claude/flow/settings"
check grep -qx 'stops=seams,spec' "$out/.claude/flow/settings"
check test ! -e "$out/.claude/flow/.gitignore"

test_name="stops none keeps no stop"
out="$sandbox/nostops"
"$script" --templates "$fixture" --out "$out" --stops none --reviewers beta >/dev/null 2>&1 || fail "exit $?"
check not grep -q 'builder stop' "$out/.claude/skills/alpha/SKILL.md"

test_name="unknown setting or value is refused"
check not "$script" --templates "$fixture" --out "$sandbox/bad1" --scope huge >/dev/null 2>&1
check not "$script" --templates "$fixture" --out "$sandbox/bad2" --colour red >/dev/null 2>&1
check test ! -e "$sandbox/bad1"

test_name="check lists remaining fills"
out="$sandbox/defaults"
"$script" --check "$out" >"$sandbox/check.out" 2>&1; status=$?
check test "$status" -ne 0
check grep -q 'skills/alpha/SKILL.md' "$sandbox/check.out"
check grep -q 'the commit convention' "$sandbox/check.out"
sed -i '' 's/<!-- fill: the commit convention -->/one commit per ticket/' "$out/.claude/skills/alpha/SKILL.md"
check "$script" --check "$out" >/dev/null 2>&1

test_name="exclude and include manage the repo's exclude file"
repo="$sandbox/repo"
git init -q "$repo"
"$script" --templates "$fixture" --out "$repo" --reviewers beta >/dev/null 2>&1 || fail "exit $?"
"$script" --exclude "$repo" >/dev/null 2>&1 || fail "exclude exit $?"
exclude_file="$(git -C "$repo" rev-parse --path-format=absolute --git-path info/exclude)"
check grep -qx '/.claude/skills/alpha/' "$exclude_file"
check grep -qx '/.claude/agents/beta-reviewer.md' "$exclude_file"
check grep -qx '/.claude/flow/' "$exclude_file"
check test -z "$(git -C "$repo" status --porcelain --untracked-files=all)"
"$script" --exclude "$repo" >/dev/null 2>&1
check test "$(grep -cx '/.claude/flow/' "$exclude_file")" -eq 1
"$script" --include "$repo" >/dev/null 2>&1 || fail "include exit $?"
check not grep -q '/.claude/' "$exclude_file"
check test -n "$(git -C "$repo" status --porcelain --untracked-files=all)"

test_name="real templates compose with every directive resolved"
out="$sandbox/real"
"$script" --out "$out" --reviewers spec,correctness,security,standards,tests --scope epic >/dev/null 2>"$sandbox/err" || fail "exit $? $(cat "$sandbox/err")"
for s in grill grilling spec tickets implement tdd review research pr retro; do check test -f "$out/.claude/skills/$s/SKILL.md"; done
check test ! -e "$out/.claude/skills/domain-modeling"
for a in spec correctness security standards tests; do check test -f "$out/.claude/agents/$a-reviewer.md"; done
check test -f "$out/.claude/agents/implementer.md"
check test -z "$(grep -rlE '<!-- (if|else|endif)' "$out/.claude" || true)"
check test -z "$(grep -rl '{{' "$out/.claude" || true)"
check grep -q 'Skill tool' "$out/.claude/skills/grill/SKILL.md"
check not grep -q 'domain-modeling' "$out/.claude/skills/grill/SKILL.md"

test_name="grilling and domain-modeling are the upstream skills verbatim"
upstream="$plugin/upstream/mattpocock-skills/skills"
check diff -q "$upstream/productivity/grilling/SKILL.md" "$out/.claude/skills/grilling/SKILL.md"
for f in SKILL.md tests.md mocking.md; do check diff -q "$upstream/engineering/tdd/$f" "$out/.claude/skills/tdd/$f"; done
check not grep -q 'Commit your work' "$sandbox/epic/.claude/skills/alpha/SKILL.md"
out="$sandbox/domain"
"$script" --out "$out" --domain on >/dev/null 2>"$sandbox/err" || fail "exit $? $(cat "$sandbox/err")"
for f in SKILL.md GLOSSARY-FORMAT.md ADR-FORMAT.md; do check diff -q "$upstream/engineering/domain-modeling/$f" "$out/.claude/skills/domain-modeling/$f"; done
check grep -q '"grilling" and "domain-modeling"' "$out/.claude/skills/grill/SKILL.md"
check not "$script" --out "$sandbox/bad3" --domain single >/dev/null 2>&1
check not "$script" --out "$sandbox/bad4" --selection chat >/dev/null 2>&1

test_name="implement is the upstream text with the settings baked in"
out="$sandbox/ticketimpl"
"$script" --out "$out" --commits user --gate confirm --pacing autonomous >/dev/null 2>&1 || fail "exit $?"
impl="$out/.claude/skills/implement/SKILL.md"
check grep -q '^Call the Skill tool with "tdd" where possible, at pre-agreed seams.$' "$impl"
check grep -q '^Leave the work uncommitted; the user commits.$' "$impl"
check not grep -q 'Commit your work' "$impl"
check grep -q 'wait for a yes' "$impl"
check not grep -q 'red → green cycle' "$impl"
check not grep -q 'integration branch' "$impl"
check grep -q 'integration branch' "$sandbox/real/.claude/skills/implement/SKILL.md"
check grep -q '^Commit your work to the current branch.$' "$sandbox/domain/.claude/skills/implement/SKILL.md"

if (( failures )); then
  echo "$failures failed"
  exit 1
fi
echo "all passed"
