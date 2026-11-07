# amadej skills

Personal Claude Code plugin marketplace.
One plugin, `flow`: one skill that sets up a spec-first, test-first engineering loop with a multi-reviewer code review in each repo.
Install it once; in each repo `/flow:setup` explores the code, settles the workflow with you, and writes the loop into the repo as its own skills and agents, edited like code.

## Install

```
/plugin marketplace add amadejzr/ai-skills
/plugin install flow@amadej
```

Update: `/plugin marketplace update amadej`, then `/plugin update flow@amadej`.
For development, run Claude Code with `claude --plugin-dir ./plugins/flow` to load the plugin from this checkout.

## Plugins

| plugin | what |
| --- | --- |
| [flow](plugins/flow/README.md) | `/flow:setup` writes grill, spec, tickets, implement, implement-spec, review with per-repo reviewers, fix, pr, research and retro into a repo |

## Herdr

`herdr/` holds the user-owned part of the Herdr app's configuration: settings, keys, the `amadej` layout and the `ghostty` theme.
`herdr/sync.sh pull` copies them in from `~/.config/herdr-app`, `herdr/sync.sh push` copies them back out.
See [herdr/README.md](herdr/README.md).

See [CREDITS.md](CREDITS.md) for the sources this work forks.
