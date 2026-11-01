---
name: upstream
description: "Check the three source plugins this flow forks from for changes, port what is worth porting, and accept the new baseline. Run every week or two."
disable-model-invocation: true
---

# Upstream

The flow forks files from Matt Pocock's skills, superpowers and feature-dev.
Their copies at the version last reviewed live under `upstream/<source>/` next to a `SOURCE` file.
This skill finds what changed upstream since then and decides, file by file, what to port.

## Process

1. Run `"${CLAUDE_PLUGIN_ROOT}/scripts/upstream-check.sh" --diff`. It clones each source at depth 1 and prints, per tracked file, `unchanged`, `CHANGED` with the diff, or `missing upstream`.
   When it prints `no upstream changes`, say so and stop.
2. For every changed file, read the diff and find the flow file it was forked into with the map below. Judge each hunk:
   - **Port**: a fix or a sharper rule that applies to the flow as it is. Apply it to the flow file, adapted to the flow's names (`review` for `code-review`, the reviewer table, the local tracker).
   - **Skip, divergence**: the flow deliberately does it differently (recorded in the repo's `CLAUDE.md`, `CREDITS.md`, or the skill's own text). Say which divergence.
   - **Skip, not forked**: the change touches a part the flow never took.
   A file `missing upstream` was moved or deleted: search the clone for its new home and update the baseline path, or drop it from the baseline when the content is gone.
3. Present the decisions as one list, one line per hunk: source file, flow file, port or skip, why. Wait for the user's answer; they may overturn any line.
4. Apply the ported hunks. Run `claude plugin validate plugins/flow` and `plugins/flow/tests/generate.test.sh`.
5. Run `"${CLAUDE_PLUGIN_ROOT}/scripts/upstream-check.sh" --accept` so the baseline moves to the reviewed commit.
6. Update `CREDITS.md` when a ported change came from a new author or file.

## Fork map

Flow paths are under `generator/` unless they start with `skills/`.

| upstream | flow |
| --- | --- |
| mattpocock-skills `skills/productivity/grilling` | `skills/flow/grilling.md`, `skills/grilling/SKILL.md` (verbatim) |
| mattpocock-skills `skills/engineering/domain-modeling` | `skills/domain-modeling/` (verbatim) |
| mattpocock-skills `skills/engineering/tdd` | `skills/tdd/` (verbatim) |
| mattpocock-skills `skills/engineering/to-spec` | `skills/spec/SKILL.md`, `template.md` |
| mattpocock-skills `skills/engineering/to-tickets` | `skills/tickets/SKILL.md`, `template.md` |
| mattpocock-skills `skills/engineering/implement` | `skills/implement/SKILL.md` (ticket scope; divergence: gate, pacing, commits and tracker lines from the settings) |
| mattpocock-skills `skills/engineering/implement-spec` | `skills/implement/SKILL.md` (epic scope), `agents/implementer.md` |
| mattpocock-skills `skills/engineering/research` | `skills/research/SKILL.md` (divergence: notes go to `.claude/flow/research/`, sources and agent count per repo) |
| mattpocock-skills `skills/engineering/code-review` | `skills/review/SKILL.md` (divergence: one sub-agent per row of the reviewer table instead of two fixed axes), and the smell baseline in `agents/standards-reviewer.md` |
| mattpocock-skills `skills/engineering/grill-with-docs` | `skills/grill/SKILL.md` (a `domain=off` branch calls grilling alone) |
| mattpocock-skills `skills/engineering/pr` | `skills/pr/SKILL.md`, `template.md` |
| mattpocock-skills `skills/engineering/retro` | `skills/retro/SKILL.md` (divergence: no writing-for-agents call; the generated flow listed under Files) |
| mattpocock-skills `skills/engineering/setup-matt-pocock-skills` | `skills/flow/SKILL.md` (the plugin's generator; divergence: it generates the skills into the repo instead of writing a config) and the tracker blocks inside the templates |
| mattpocock-skills `skills/productivity/writing-for-agents` | the writing standard for every skill and template here (not forked as a skill) |
| superpowers `skills/brainstorming` | `skills/spec/SKILL.md` (builder check, approval stop) |
| superpowers `skills/writing-plans` | not forked; watched for ideas |
| feature-dev `agents/code-reviewer.md` | the reviewer agents' shape in `agents/` |
| feature-dev `commands/feature-dev.md`, `agents/code-architect.md`, `agents/code-explorer.md` | not forked; watched for ideas |
