# 06: Repo housekeeping, structural test and docs

## What to build

Delete `plugins/flow/generator/`, `plugins/flow/scripts/generate.sh`, `plugins/flow/tests/generate.test.sh` and `plugins/flow/skills/flow/`.
Write `plugins/flow/tests/references.test.sh`: every SKILL.md, recipe and reference under 20000 bytes; every file under `references/verbatim/` byte-identical to its file under `plugins/flow/upstream/mattpocock-skills/`; every recipe, tracker and runner named in `references/workflow.md` exists; `bash -n` on every runner; `claude plugin validate plugins/flow` clean when the CLI is present.
Create `.claude/skills/upstream/SKILL.md` in this checkout (not in the plugin) holding the porting judgement: run `scripts/upstream-check.sh`, read the diffs, port into `references/verbatim/` and the recipes, accept the baseline with `--accept`; update the fork map inside `upstream-check.sh` if it names the old generator paths.
Update `plugins/flow/.claude-plugin/plugin.json` (version 0.3.0, description for the new shape), `.claude-plugin/marketplace.json`, `plugins/flow/README.md`, the repo `README.md`, `CLAUDE.md` and `CREDITS.md` (add Anthropic's security-review prompt and the pr-review-toolkit reviewer shapes; superpowers for the builder check and the 20,000-byte rule; keep licences).
Write the manual end-to-end checklist as `plugins/flow/tests/E2E.md`.

## Blocked by

01, 02, 03, 04, 05.

## Touches

`plugins/flow/tests/**`, `plugins/flow/.claude-plugin/**`, `plugins/flow/README.md`, `plugins/flow/scripts/upstream-check.sh`, `.claude/skills/upstream/**`, `README.md`, `CLAUDE.md`, `CREDITS.md`, `.claude-plugin/marketplace.json`, deletions listed above.

## Verify

`bash plugins/flow/tests/references.test.sh` passes; `claude plugin validate .` passes; `git status` shows the deletions and no leftover generator path in any doc (`grep -rn generator/ --include=*.md . | grep -v upstream/` is empty).

## Status

ready-for-agent

## Acceptance criteria

- [ ] When the structural test runs on the finished tree, then it passes, and it fails when a verbatim file is edited or a reference exceeds 20,000 bytes.
- [ ] When the docs are read, then they describe only the one-skill, references, agent-composed design.
- [ ] When `/upstream` is typed in this checkout, then the porting skill exists as a project skill and the plugin still ships one skill.
