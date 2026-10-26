# amadej skills

Personal Claude Code plugin marketplace.
One plugin, `flow`: a spec-first, test-first engineering loop with a multi-reviewer code review configured per repo from one file kept outside the repo.

## Install

```
/plugin marketplace add /Users/amadejj/Developer/skills
/plugin install flow@amadej
```

Update after editing: `/plugin marketplace update amadej`, then `/plugin update flow@amadej`.
For development, run Claude Code with `claude --plugin-dir ./plugins/flow` to hot-reload the plugin from this checkout.

OpenCode: run `plugins/flow/scripts/install-opencode.sh` once, and again after editing; it generates `flow-*` skills, commands and agents under `~/.config/opencode/`.
Both hosts read the same per-repo config, tickets and reviews under `~/.flow`; `repos/` in this checkout is a gitignored symlink to it, so the data is visible next to the plugin.

## Plugins

| plugin | what |
| --- | --- |
| [flow](plugins/flow/README.md) | grill, spec, tickets, implement (TDD), review with configurable reviewers, fix, pr, retro, upstream check |

See [CREDITS.md](CREDITS.md) for the sources this work forks.
