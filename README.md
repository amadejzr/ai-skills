# amadej skills

Personal Claude Code plugin marketplace.
One plugin, `flow`: a generator for a spec-first, test-first engineering loop with a multi-reviewer code review.
Install it once; in each repo `/flow:flow` interviews you and writes the loop into the repo as its own skills, shaped by your answers and edited like code.

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
| [flow](plugins/flow/README.md) | `/flow:flow` generates grill, spec, tickets, implement (TDD, per ticket or per epic), review with per-repo reviewers, research, pr and retro into a repo |

## Herdr

`herdr/` holds the user-owned part of the Herdr app's configuration: settings, keys, the `amadej` layout and the `ghostty` theme.
`herdr/sync.sh pull` copies them in from `~/.config/herdr-app`, `herdr/sync.sh push` copies them back out.
See [herdr/README.md](herdr/README.md).

See [CREDITS.md](CREDITS.md) for the sources this work forks.
