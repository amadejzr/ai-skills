#!/usr/bin/env bash
# Tests for scripts/flow-config.sh against throwaway git repos and a throwaway flow home.
#   tests/flow-config.test.sh
set -uo pipefail

script="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/flow-config.sh"
sandbox="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$sandbox"' EXIT
export FLOW_HOME="$sandbox/flow-home"

failures=0
fail() { echo "FAIL [$test_name]: $*"; failures=$((failures + 1)); }
check() { "$@" || fail "expected: $*"; }

new_repo() {
  local repo="$sandbox/$1"
  git init -q "$repo"
  git -C "$repo" remote add origin "git@example.com:team/$1.git"
  git -C "$repo" commit -q --allow-empty -m init
  echo "$repo"
}

excluded() { grep -qx '/.flow' "$(git -C "$1" rev-parse --path-format=absolute --git-path info/exclude)"; }
not() { ! "$@"; }

test_name="no setup resolves to nothing"
repo="$(new_repo no-setup)"
out="$("$script" "$repo" 2>"$sandbox/err")"; status=$?
check test "$status" -ne 0
check test -z "$out"
check grep -q '/flow:setup' "$sandbox/err"
check test ! -e "$FLOW_HOME"
check test ! -e "$repo/.flow"

test_name="init local"
repo="$(new_repo local-repo)"
dir="$FLOW_HOME/example.com-team-local-repo"
out="$("$script" --init local "$repo" 2>/dev/null)"
check test "$out" = "$dir"
check test -f "$dir/config.md"
check test -d "$dir/reviewers"
check test -L "$repo/.flow"
check test "$(readlink "$repo/.flow")" = "$dir"
check excluded "$repo"
check test -z "$(git -C "$repo" status --porcelain)"
check test "$("$script" "$repo" 2>/dev/null)" = "$dir"

test_name="init local is idempotent"
echo "edited" >> "$dir/config.md"
"$script" --init local "$repo" >/dev/null 2>&1
check grep -q edited "$dir/config.md"
check test "$(grep -cx '/.flow' "$(git -C "$repo" rev-parse --path-format=absolute --git-path info/exclude)")" -eq 1

test_name="local resolves from a worktree without the link"
git -C "$repo" worktree add -q "$sandbox/local-worktree" 2>/dev/null
check test ! -e "$sandbox/local-worktree/.flow"
check test "$("$script" "$sandbox/local-worktree" 2>/dev/null)" = "$dir"

test_name="init git refuses when local exists"
"$script" --init git "$repo" >/dev/null 2>"$sandbox/err"; status=$?
check test "$status" -ne 0
check grep -q -- '--switch' "$sandbox/err"
check test -L "$repo/.flow"

test_name="init git"
repo="$(new_repo git-repo)"
out="$("$script" --init git "$repo" 2>/dev/null)"
check test "$out" = "$repo/.flow"
check test -d "$repo/.flow"
check not test -L "$repo/.flow"
check test -f "$repo/.flow/config.md"
check test -d "$repo/.flow/reviewers"
check grep -qx 'reviews/' "$repo/.flow/.gitignore"
check test ! -e "$FLOW_HOME/example.com-team-git-repo"
check not excluded "$repo"
mkdir -p "$repo/.flow/reviews" && touch "$repo/.flow/reviews/run.md"
check test -z "$(git -C "$repo" status --porcelain --untracked-files=all | grep reviews/)"
check test -n "$(git -C "$repo" status --porcelain --untracked-files=all | grep '.flow/config.md')"
check test "$("$script" "$repo" 2>/dev/null)" = "$repo/.flow"

test_name="switch local to git"
repo="$sandbox/local-repo"
dir="$FLOW_HOME/example.com-team-local-repo"
touch "$dir/reviewers/security.md"
out="$("$script" --switch git "$repo" 2>/dev/null)"
check test "$out" = "$repo/.flow"
check not test -L "$repo/.flow"
check test -f "$repo/.flow/reviewers/security.md"
check grep -q edited "$repo/.flow/config.md"
check grep -qx 'reviews/' "$repo/.flow/.gitignore"
check test ! -e "$dir"
check not excluded "$repo"

test_name="switch git to local"
out="$("$script" --switch local "$repo" 2>/dev/null)"
check test "$out" = "$dir"
check test -f "$dir/reviewers/security.md"
check test ! -e "$dir/.gitignore"
check test -L "$repo/.flow"
check excluded "$repo"

test_name="switch to the current mode is a no-op"
out="$("$script" --switch local "$repo" 2>/dev/null)"
check test "$out" = "$dir"
check test -f "$dir/reviewers/security.md"

test_name="repo without a remote is keyed by its path"
repo="$sandbox/no-remote"
git init -q "$repo"
out="$("$script" --init local "$repo" 2>/dev/null)"
check test "$(dirname "$out")" = "$FLOW_HOME"
check test -L "$repo/.flow"

if (( failures )); then
  echo "$failures failed"
  exit 1
fi
echo "all passed"
