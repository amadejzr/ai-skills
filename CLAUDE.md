# Repo conventions

This repo is a Claude Code plugin marketplace named `amadej`.
Each plugin lives in `plugins/<name>/` with `.claude-plugin/plugin.json`, `README.md`, `skills/<skill>/SKILL.md`, optional `agents/*.md`, `scripts/` and `hooks/`.
The catalog is `.claude-plugin/marketplace.json`.

Run `claude plugin validate .` after touching any manifest, skill or agent.

The `flow` plugin is a generator.
It ships two skills, `flow` and `upstream`, both user-invoked (`disable-model-invocation: true`).
Everything a repo runs (grill, spec, tickets, implement, review, research, pr, retro, the reviewer and implementer agents) is a template under `plugins/flow/generator/` that `scripts/generate.sh` composes into the repo's `.claude/` from the interview's settings.
`generator/README.md` is the contract: the settings, their values and the directives (`<!-- if key=value -->`, `{{key}}`, `<!-- fill: ... -->`).
Generated files are the repo's own and are never read back by the plugin; behaviour a user might want to differ between repos is a setting or a fill marker in a template, never a constant.
Generated skills call each other by bare name and link sibling files relatively; only plugin skills use `flow:` names and `${CLAUDE_PLUGIN_ROOT}`.

Every skill is either user-invoked (`disable-model-invocation: true`, one-line human description) or model-invoked (description carries the trigger branches).

Run `plugins/flow/tests/generate.test.sh` after touching `generate.sh` or any template; its last case composes the real templates and fails on any directive left unresolved.
Templates must render cleanly for every value of every setting they branch on.

Forked material keeps its attribution in `CREDITS.md`.
`plugins/flow/upstream/` is the baseline of forked upstream files; only `/flow:upstream` (via `scripts/upstream-check.sh --accept`) moves it.
