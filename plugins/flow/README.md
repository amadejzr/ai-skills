# flow

A generator for a repo's engineering flow, forked from Matt Pocock's skills, superpowers and feature-dev.
Install the plugin once.
In each repo, `/flow:flow` explores the code, interviews you about how you want to work there, and writes the flow into the repo as its own skills and agents.
From then on those files are the behaviour: edit them like code, nothing reads a config at run time.

```
/flow:flow                      once per repo: interview, then generate; again to change anything, with a diff per file
```

What a repo gets:

```
<repo>/.claude/
  skills/
    grill/        Matt Pocock's grill-with-docs: calls grilling, and domain-modeling when domain is on
    grilling/     Matt Pocock's grilling, unchanged
    domain-modeling/   Matt Pocock's domain-modeling with its format files, unchanged; only when domain is on
    spec/         the epic, in template.md, builder-checked when you said so
    tickets/      tracer-bullet tickets, in template.md, with blocking edges
    implement/    Matt Pocock's implement (ticket scope) or implement-spec (epic scope) with your settings baked in
    tdd/          Matt Pocock's tdd with tests.md and mocking.md, unchanged
    review/       Matt Pocock's code-review with one parallel reviewer agent per row of its reviewer table
    research/     background agents over the sources you trust, one cited note
    pr/           the PR body, in template.md
    retro/        turns what slipped into reviewer rules, checks, pointers or workflow edits
  agents/
    spec-reviewer.md  correctness-reviewer.md  ...   one per reviewer, each with its own model
    implementer.md                                   when scope is epic
  flow/
    features/   research/                              specs, tickets and research notes
    settings    generated                             what the last /flow:flow run used and wrote
```

Commands in a repo: `/grill`, `/spec`, `/tickets`, `/implement <ticket> | <epic>`, `/review <fixed-point>`, `/retro`.
`review`, `research` and `pr` are reached by the steps and by Claude on its own; by hand, `/review since <ref> [spec-reviewer security-reviewer ...]` runs the named agents only.

## What the interview decides

| setting | values | what it changes |
| --- | --- | --- |
| `mode` | `private`, `committed` | generated paths go into `.git/info/exclude`, or the repo commits them |
| `scope` | `ticket`, `epic` | one implement run covers one ticket here, or every ticket of the epic from the frontier, each in a fresh implementer agent |
| `pacing` | `checkpoint`, `autonomous` | implement stops after every red → green cycle so you read the code, or runs through |
| `commits` | `agent`, `user` | who commits in ticket scope; epic scope always commits on its integration branch |
| `gate` | `none`, `confirm`, `grill` | before a ticket starts: nothing, a yes from you, or a grilling of the ticket |
| `stops` | any of `seams`, `spec`, `builder`, `tickets`; `none` | which planning steps wait for you |
| `tracker` | `local`, `github`, `gitlab`, `other` | where epics and tickets live |
| `domain` | `off`, `on` | whether grill also runs domain-modeling, keeping `GLOSSARY.md` and `docs/adr/` in the repo as Matt Pocock's skill does |
| `reviewers` | `spec`, `correctness`, `security`, `standards`, `tests`, plus your own | one agent file each, rules adapted to the repo |
| models | `opus`, `sonnet`, `haiku`, `fable` | the implementer, the builder check, research; reviewers in their own frontmatter |

Prose the interview fills in: each reviewer's rules and paths, the research sources, the PR template merged with the repo's own, and the tracker lines when the tracker is `other`.

## Install

```
/plugin marketplace add amadejzr/ai-skills
/plugin install flow@amadej
```

Update with `/plugin marketplace update amadej` then `/plugin update flow@amadej`, or switch auto-update on for the `amadej` marketplace under `/plugin`.
For development, `claude --plugin-dir ./plugins/flow` loads this checkout.
Generated repos are untouched by plugin updates; run `/flow:flow` again in a repo to pull improvements in, file by file.

## Inside the plugin

```
skills/flow/        the generator: explore, interview (grilling.md), generate, diff on re-run
skills/upstream/    port changes from the forked sources
generator/          the templates generate.sh composes: skills/<name>/, agents/; README.md is the contract
scripts/generate.sh compose, --check for unfilled markers, --exclude / --include for git
tests/              generate.test.sh
upstream/           the forked files at the version last reviewed
```

Templates are Markdown with HTML-comment directives (`<!-- if scope=epic -->`, `{{flow_dir}}`, `<!-- fill: ... -->`); `generator/README.md` has the full list.
