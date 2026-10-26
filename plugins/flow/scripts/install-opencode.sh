#!/usr/bin/env bash
# Generate the OpenCode form of this plugin.
#   install-opencode.sh            write into ${XDG_CONFIG_HOME:-$HOME/.config}/opencode
#   install-opencode.sh <dir>      write into <dir> instead
# Rerun after editing the plugin: everything named flow-* under skills/, agents/ and commands/ is regenerated.
# The skill text is written once, for Claude Code; this script rewrites the two host-specific forms:
#   flow:<name>            -> flow-<name>      OpenCode has no plugin namespace, so the prefix is part of the name
#   ${CLAUDE_PLUGIN_ROOT}  -> this plugin's absolute path
set -euo pipefail

plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"

rewrite() {
  PLUGIN_ROOT="$plugin_root" perl -pe 's/flow:(?=[a-z])/flow-/g; s/\$\{CLAUDE_PLUGIN_ROOT\}/$ENV{PLUGIN_ROOT}/g'
}

frontmatter_value() {
  sed -n "s/^$2: //p" "$1" | head -1
}

body_after_frontmatter() {
  awk 'printing { print; next } /^---$/ { if (++fences == 2) printing = 1 }' "$1"
}

# Model-invoked skills that users also type by hand, as /flow:review since <ref>; they get a command like the user-invoked ones.
typed_by_hand=" review "

mkdir -p "$target/skills" "$target/agents" "$target/commands"
rm -rf "$target"/skills/flow-* "$target"/agents/flow-*.md "$target"/commands/flow-*.md

skills=0 commands=0 agents=0
for skill_dir in "$plugin_root"/skills/*/; do
  name="$(basename "$skill_dir")"
  out="$target/skills/flow-$name"
  while IFS= read -r file; do
    rel="${file#"$skill_dir"}"
    mkdir -p "$out/$(dirname "$rel")"
    if [[ "$file" == *.md ]]; then
      rewrite < "$file" | awk -v n="flow-$name" 'NR == 1 { fm = 1 } fm && /^name: / { $0 = "name: " n } NR > 1 && /^---$/ { fm = 0 } { print }' > "$out/$rel"
    else
      cp "$file" "$out/$rel"
    fi
  done < <(find "$skill_dir" -type f | sort)
  skills=$((skills + 1))

  if grep -q '^disable-model-invocation: true' "$skill_dir/SKILL.md" || [[ "$typed_by_hand" == *" $name "* ]]; then
    {
      echo '---'
      grep -m1 '^description:' "$skill_dir/SKILL.md" | rewrite
      echo '---'
      echo "Load the skill \`flow-$name\` with the skill tool and follow it exactly."
      echo 'The user'"'"'s arguments: $ARGUMENTS'
    } > "$target/commands/flow-$name.md"
    commands=$((commands + 1))
  fi
done

for agent_file in "$plugin_root"/agents/*.md; do
  name="$(basename "$agent_file" .md)"
  color="$(frontmatter_value "$agent_file" color)"
  {
    echo '---'
    grep -m1 '^description:' "$agent_file"
    echo 'mode: subagent'
    [[ -n "$color" ]] && echo "color: $color"
    echo '---'
    body_after_frontmatter "$agent_file" | rewrite
  } > "$target/agents/flow-$name.md"
  agents=$((agents + 1))
done

echo "opencode: $skills skills, $commands commands, $agents agents written under $target"
