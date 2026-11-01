# Generator templates

`/flow:flow` grills the user, then `scripts/generate.sh` composes these templates into a project's `.claude/` and the agent fills what is repo-specific.
The generated files are the project's own from then on; nothing here is read at run time.

## Layout

```
generator/
  skills/<name>/SKILL.md        one generated skill per folder, siblings copied with it
  skills/<name>/*.md            reference and templates the skill reads by relative link
  skills/domain-modeling/       copied when `domain=on`
  skills/grilling/, skills/tdd/ Matt Pocock's skills, byte for byte; `/flow:upstream` moves them
  agents/<name>-reviewer.md     one reviewer, copied when <name> is in `reviewers`
  agents/implementer.md         copied when `scope=epic`
```

Output: `<out>/.claude/skills/<name>/`, `<out>/.claude/agents/<name>.md`, `<out>/.claude/flow/{features,research}/`.

## Settings

Every setting is a `--key value` flag of `generate.sh`; the defaults are the recommended set.

| key | values | default |
| --- | --- | --- |
| `mode` | `private`, `committed` | `private` |
| `scope` | `ticket`, `epic` | `ticket` |
| `pacing` | `checkpoint`, `autonomous` | `checkpoint` |
| `commits` | `agent`, `user` | `agent` |
| `gate` | `none`, `confirm`, `grill` | `none` |
| `stops` | comma list of `seams`, `spec`, `builder`, `tickets`, or `none` | `seams,spec,builder,tickets` |
| `tracker` | `local`, `github`, `gitlab`, `other` | `local` |
| `domain` | `off`, `on` | `off` |
| `reviewers` | comma list of agent names without `-reviewer` | `spec,correctness` |
| `implementer_model` | `opus`, `sonnet`, `haiku`, `fable` | `opus` |
| `builder_model` | same | `opus` |
| `research_model` | same | `opus` |
| `research_agents` | a number | `1` |

`flow_dir` is always `.claude/flow`.

## Directives

Templates are Markdown with HTML-comment directives, so they stay readable as they are.

- `<!-- if key=value -->` … `<!-- else -->` … `<!-- endif -->`: `value` may list alternatives as `a|b`. Blocks nest.
- `<!-- if key~item -->`: true when `item` is in the comma list `key` holds.
- `{{key}}`: replaced by the setting's value; `{{flow_dir}}` by `.claude/flow`.
- `<!-- fill: what goes here -->`: left in the output for the agent to replace with repo-specific text. `generate.sh --check <project>` lists every one still present and fails while any remains.

A directive line produces no output line of its own.
