# Repo conventions

This repo is a Claude Code plugin marketplace named `amadej`.
Each plugin lives in `plugins/<name>/` with `.claude-plugin/plugin.json`, `README.md`, `skills/<skill>/SKILL.md`, optional `agents/*.md`, `scripts/` and `hooks/`.
The catalog is `.claude-plugin/marketplace.json`.

Run `claude plugin validate .` after touching any manifest, skill or agent.

The `flow` plugin ships exactly one skill, `setup` (`/flow:setup`, `disable-model-invocation: true`), and no agents.
Do not add a second plugin skill; maintainer tooling such as `/upstream` is a project skill in this checkout's `.claude/skills/`.
Setup composes every file a repo gets by itself from `plugins/flow/references/`: recipes, the reviewer catalogue, tracker recipes, runner scripts and verbatim skills.
Nothing in `references/` is a template engine: no directives, no template variables, no script that renders it; the only placeholder is a `{setup: <what goes here>}` span in a recipe, which the composing agent fills.
`references/workflow.md` is the design tree and the table of every generated path; recipes, setup, the setup record and the structural test use its decision names exactly.
Generated files are the repo's own and are never read back by the plugin; generated skills call each other by bare name and link sibling files relatively; only the plugin skill uses `${CLAUDE_PLUGIN_ROOT}`.

Every SKILL.md, recipe and reference stays under 20,000 bytes, because compaction truncates a re-attached skill at that size; move step material into a sibling file read at that step.
Files under `plugins/flow/references/verbatim/` are byte-identical to their baselines under `plugins/flow/upstream/mattpocock-skills/`; never edit them, port through `/upstream`.

Every skill is either user-invoked (`disable-model-invocation: true`, one-line human description) or model-invoked (description says only when to use it, never its process).

Run `bash plugins/flow/tests/references.test.sh` after touching anything under `plugins/flow/`; it checks sizes, verbatim bytes, that every recipe, tracker and runner named in `workflow.md` exists, the runner scripts' syntax and `claude plugin validate`.
Before a release, bump `version` in `plugins/flow/.claude-plugin/plugin.json`, run `bash plugins/flow/tests/e2e.sh run recommended` and `run grilled` (each about nine dollars, with permissions bypassed inside a throwaway repo), and walk the manual part of `plugins/flow/tests/E2E.md`.
`claude plugin eval` cannot run setup: non-interactive sessions refuse writes under `.claude/` and `git` fails inside its sandbox on macOS.

Forked material keeps its attribution in `CREDITS.md`.
`plugins/flow/upstream/` is the baseline of forked upstream files; only `/upstream` (via `plugins/flow/scripts/upstream-check.sh --accept`) moves it and the verbatim copies.
