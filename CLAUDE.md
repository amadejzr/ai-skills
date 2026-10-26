# Repo conventions

This repo is a Claude Code plugin marketplace named `amadej`.
Each plugin lives in `plugins/<name>/` with `.claude-plugin/plugin.json`, `README.md`, `skills/<skill>/SKILL.md`, optional `agents/*.md`, `scripts/` and `hooks/`.
The catalog is `.claude-plugin/marketplace.json`.

Run `claude plugin validate .` after touching any manifest, skill or agent.

Every skill is either user-invoked (`disable-model-invocation: true`, one-line human description) or model-invoked (description carries the trigger branches).
Only model-invoked skills can be called from other skills, always by their namespaced name: `Call the Skill tool with "flow:<name>"`. Bare names can resolve to another installed plugin's copy.
Sibling files are linked relatively from inside the skill folder; cross-skill material is reached by calling the owning skill.

Forked material keeps its attribution in `CREDITS.md`.
When a skill is added, renamed or removed, update `plugins/flow/README.md` and the `flow` router skill.

`plugins/flow/upstream/` is the baseline of forked upstream files; only `/flow:upstream` (via `scripts/upstream-check.sh --accept`) moves it.

Everything the flow owns for a target repo (config, reviewer files, local tickets, domain docs, reviews) lives in that repo's flow directory and nowhere else, resolved by `scripts/flow-config.sh` through the `flow:config` skill: local mode keeps it under the flow home (`~/.flow`) with a git-excluded `.flow` symlink in the repo, git mode commits it as `<repo>/.flow`.
The plugin also runs in OpenCode: `scripts/install-opencode.sh` generates `flow-*` skills, commands and agents from the same files, rewriting `flow:<name>` to `flow-<name>` and `${CLAUDE_PLUGIN_ROOT}` to the plugin path. So skill text always names skills and agents as `flow:<name>`, reaches scripts through `${CLAUDE_PLUGIN_ROOT}`, and names nothing host-specific without saying which host. Reviewers are files in the flow directory, run by the one generic `reviewer` agent; the plugin ships no reviewer prompts.
Outside the flow directory a skill writes only code and tests into the repo it works on; the repo's own docs are read, never edited. Run `plugins/flow/tests/flow-config.test.sh` after touching `flow-config.sh`.
