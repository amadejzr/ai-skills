---
name: config
description: "Resolve this repo's flow directory, the one place everything the flow owns for the repo lives: config.md (tracker, domain docs, standards map and notes, checks, navigation), one file per reviewer, local tickets, domain docs and review files. Called by the other flow skills before they read or write anything; use when asked where the flow keeps its config, reviewers, tickets or reviews for a repo."
---

# Config

Everything the flow owns for a repo lives in one directory, the flow directory, and nowhere else:

```
<flow dir>/
  config.md              the choices for this repo
  reviewers/<name>.md    one file per reviewer: the whole reviewer
  features/<slug>/       local tracker: spec.md and issues/<NN>-<slug>.md
  domain/                glossary and ADRs, when Domain docs is on
  reviews/               one file per review run
```

The repo's own docs (`CONTRIBUTING.md`, `CLAUDE.md`, a committed `GLOSSARY.md` or `docs/adr/`, ...) belong to the repo: the flow reads them where they are and never edits or copies them.
Flow material anywhere else (`.claude/`, `docs/agents/`, `.scratch/`) is not read; `/flow:setup` moves it in.

## Two modes

The user picks one per repo in `/flow:setup`; what `<repo>/.flow` is tells them apart:

- **local**: the directory is `${FLOW_HOME:-$HOME/.flow}/<repo-key>`, outside the repo, keyed by the origin remote so every clone and worktree shares it. `<repo>/.flow` is a symlink to it, listed in `.git/info/exclude`.
- **git**: the directory is `<repo>/.flow` itself, committed with the repo. `.flow/.gitignore` keeps `reviews/` out of git.

## Resolve

Run `"${CLAUDE_PLUGIN_ROOT}/scripts/flow-config.sh"` from inside the repo; it prints the flow directory.
When it fails there is no flow directory: say so, suggest `/flow:setup`, and stop. The flow has no built-in defaults and does not run without it.
Never create the directory or `config.md` yourself; only `/flow:setup` does.

## config.md

- **Tracker**: `github`, `gitlab`, `local` or `other`. Read the matching rules: [tracker-github.md](./tracker-github.md), [tracker-gitlab.md](./tracker-gitlab.md), [tracker-local.md](./tracker-local.md). For `other`, the `## Tracker notes` paragraph is the rule; it must say how to publish, fetch and close.
- **Domain docs**: `off`, `single` or `multi`. `off`: the flow writes no glossary or ADRs; terms and decisions stay in the conversation and the spec. `single`: `domain/GLOSSARY.md` and `domain/adr/` in the flow directory. `multi`: `domain/GLOSSARY-MAP.md` pointing at `domain/<context>/GLOSSARY.md` and `domain/<context>/adr/`. In every mode, read the flow directory's domain docs and the repo's own committed glossary and ADRs before exploring, use their vocabulary, and flag a contradiction with an ADR instead of silently overriding it. Missing files are not worth a mention.
- **Selection**: `chat` or `dialog`; how `flow:fix` asks which findings to apply. `dialog` needs AskUserQuestion (Claude Code); elsewhere it falls back to `chat`.
- **Standards map**: per changed file, the docs of the first matching row go to every reviewer that takes `standards`. The docs are the repo's own files. A missing doc is dropped and listed in the review header.
- **Standards notes**: the user's own rules for this repo, passed with the mapped docs and treated as documented standards.
- **Checks**: the commands `flow:implement` and `flow:fix` run and quote.
- **Navigation**: pointers `flow:implement` reads before exploring; `flow:retro` adds to them.

## Reviewers

Each file in `reviewers/` is one reviewer, written by the user for this repo; the file name without `.md` is its name in finding ids.
The files present are exactly the reviewers that exist: nothing is built in.

```markdown
---
model: opus
paths: ["**/src/main/**/*.java", "**/db/migration/**"]
inputs: [standards]
---

<the reviewer's instructions: what it looks at, how, its numbered rules, what it skips>
```

- `model`: `opus`, `sonnet`, `haiku` or `fable`, applied per dispatch in Claude Code. OpenCode cannot set a model per dispatch, so there every reviewer runs on the dispatching agent's model.
- `paths`: globs relative to the repo root; `[]` means the whole change. A reviewer matching no changed file is skipped.
- `inputs`: what `flow:review` passes besides the change, any of `spec` (the ticket and its epic; the reviewer is skipped when there is none), `standards` (the mapped docs and the standards notes), `domain-docs` (the glossary and ADR paths).
- The body is pasted verbatim as the reviewer's instructions. The reviewer contract, which fixes severities, confidence and output shape, is added by `flow:review` and is not part of the file.

Report the flow directory, its mode, the reviewer names and the resolved choices in one line, then carry on with the calling skill.
