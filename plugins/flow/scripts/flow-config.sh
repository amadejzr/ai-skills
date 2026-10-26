#!/usr/bin/env bash
# Resolve the repo's flow directory, the one place everything the flow owns for that repo lives.
#   flow-config.sh [repo-root]                  print the directory; fails when /flow:setup has not run
#   flow-config.sh --init local|git [repo-root] create it in that mode, scaffold config.md and reviewers/
#   flow-config.sh --switch local|git [repo-root] move it to the other mode
# Two modes, told apart by what <repo>/.flow is, so no setting can disagree with the filesystem:
#   git    <repo>/.flow is a real directory, committed with the repo; .flow/.gitignore keeps reviews/ out
#   local  the directory is <flow home>/<repo-key>, outside the repo; <repo>/.flow is a git-excluded symlink to it
# The local key comes from the origin remote, so every clone and worktree of a repo shares one directory;
# a repo without a remote is keyed by its path.
set -euo pipefail

action=resolve
if [[ "${1:-}" == "--init" || "${1:-}" == "--switch" ]]; then
  action="${1#--}"
  mode="${2:-}"
  if [[ "$mode" != local && "$mode" != git ]]; then
    echo "usage: flow-config.sh --$action local|git [repo-root]" >&2
    exit 2
  fi
  shift 2
fi
repo_root="$(cd "${1:-$(git rev-parse --show-toplevel)}" && pwd -P)"
plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
flow_home="${FLOW_HOME:-$HOME/.flow}"
link="$repo_root/.flow"
exclude_file="$(git -C "$repo_root" rev-parse --path-format=absolute --git-path info/exclude)"

remote="$(git -C "$repo_root" remote get-url origin 2>/dev/null || true)"
if [[ -n "$remote" ]]; then
  source="$remote"
  key="${remote#*://}"
  key="${key#*@}"
  key="${key%.git}"
  key="${key%/}"
else
  source="$repo_root"
  key="local$repo_root"
fi
key="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9.' '-')"
key="${key%-}"
local_dir="$flow_home/$key"

current_mode() {
  if [[ -d "$link" && ! -L "$link" ]]; then
    echo git
  elif [[ -d "$local_dir" ]]; then
    echo local
  else
    echo none
  fi
}

dir_for() {
  if [[ "$1" == git ]]; then echo "$link"; else echo "$local_dir"; fi
}

link_local() {
  [[ -L "$link" ]] || ln -s "$local_dir" "$link"
  mkdir -p "$(dirname "$exclude_file")"
  grep -qx '/.flow' "$exclude_file" 2>/dev/null || echo '/.flow' >> "$exclude_file"
}

unlink_local() {
  [[ -L "$link" ]] && rm "$link"
  if [[ -f "$exclude_file" ]]; then
    grep -vx '/.flow' "$exclude_file" > "$exclude_file.tmp" || true
    mv "$exclude_file.tmp" "$exclude_file"
  fi
}

ignore_reviews() {
  grep -qx 'reviews/' "$link/.gitignore" 2>/dev/null || echo 'reviews/' >> "$link/.gitignore"
}

case "$action" in
  resolve)
    if [[ "$(current_mode)" == none ]]; then
      echo "no flow directory for $repo_root; run /flow:setup" >&2
      exit 1
    fi
    ;;
  init)
    existing="$(current_mode)"
    if [[ "$existing" != none && "$existing" != "$mode" ]]; then
      echo "already set up in $existing mode; use --switch $mode to move it" >&2
      exit 1
    fi
    if [[ "$mode" == local && -e "$link" && ! -L "$link" ]]; then
      echo "$link exists and is not the flow link; move it away first" >&2
      exit 1
    fi
    dir="$(dir_for "$mode")"
    mkdir -p "$dir/reviewers"
    if [[ -f "$dir/config.md" ]]; then
      echo "exists, left untouched: $dir/config.md" >&2
    else
      sed -e "s|<repo-key>|$key|g" -e "s|<repo-source>|$source|g" \
        "$plugin_root/skills/config/config-template.md" > "$dir/config.md"
      echo "created: $dir/config.md" >&2
    fi
    if [[ "$mode" == local ]]; then link_local; else ignore_reviews; fi
    ;;
  switch)
    existing="$(current_mode)"
    if [[ "$existing" == none ]]; then
      echo "no flow directory to switch; run --init $mode" >&2
      exit 1
    fi
    if [[ "$existing" == local && "$mode" == git ]]; then
      unlink_local
      mv "$local_dir" "$link"
      ignore_reviews
      echo "moved to the repo; commit .flow to share it" >&2
    elif [[ "$existing" == git && "$mode" == local ]]; then
      if [[ -e "$local_dir" ]]; then
        echo "$local_dir already exists; move it away first" >&2
        exit 1
      fi
      mkdir -p "$flow_home"
      mv "$link" "$local_dir"
      rm -f "$local_dir/.gitignore"
      link_local
      echo "moved out of the repo; commit the removal of .flow" >&2
    fi
    ;;
esac

if [[ "$action" == resolve ]]; then
  dir_for "$(current_mode)"
else
  dir_for "$mode"
fi
