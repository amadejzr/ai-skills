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
   - **Port**: a fix or a sharper rule that applies to the flow as it is. Apply it to the flow file, adapted to the flow's names (`flow:` namespaces, `review` for `code-review`, the chat selection, the local statuses).
   - **Skip, divergence**: the flow deliberately does it differently (recorded in the repo's `CLAUDE.md`, `CREDITS.md`, or the skill's own text). Say which divergence.
   - **Skip, not forked**: the change touches a part the flow never took.
   A file `missing upstream` was moved or deleted: search the clone for its new home and update the baseline path, or drop it from the baseline when the content is gone.
3. Present the decisions as one list, one line per hunk: source file, flow file, port or skip, why. Wait for the user's answer; they may overturn any line.
4. Apply the ported hunks. Run `claude plugin validate plugins/flow`.
5. Run `"${CLAUDE_PLUGIN_ROOT}/scripts/upstream-check.sh" --accept` so the baseline moves to the reviewed commit.
6. Update `CREDITS.md` when a ported change came from a new author or file.

## Fork map

| upstream | flow |
| --- | --- |
| mattpocock-skills `skills/productivity/grilling` | `skills/grilling` |
| mattpocock-skills `skills/engineering/domain-modeling` | `skills/domain-modeling` |
| mattpocock-skills `skills/engineering/tdd` | `skills/tdd` |
| mattpocock-skills `skills/engineering/to-spec` | `skills/spec` |
| mattpocock-skills `skills/engineering/to-tickets` | `skills/tickets` |
| mattpocock-skills `skills/engineering/implement` | `skills/implement` |
| mattpocock-skills `skills/engineering/code-review` | `skills/review` |
| mattpocock-skills `skills/engineering/grill-with-docs` | `skills/grill` |
| mattpocock-skills `skills/engineering/pr` | `skills/pr` |
| mattpocock-skills `skills/engineering/retro` | `skills/retro` |
| mattpocock-skills `skills/engineering/setup-matt-pocock-skills` | `skills/setup`, `skills/config` and its tracker files (divergence: everything lives in the flow directory, local or committed) |
| mattpocock-skills `skills/productivity/writing-for-agents` | the writing standard for every skill here (not forked as a skill) |
| superpowers `skills/brainstorming` | `skills/grill` (opener), `skills/spec` (builder check, approval gate) |
| superpowers `skills/requesting-code-review`, `receiving-code-review` | `REVIEWER-CONTRACT.md` severities, `skills/review` steps 8 and 9 |
| superpowers `skills/subagent-driven-development` | `skills/review` re-review, `## Deferred`, branch review |
| superpowers `skills/test-driven-development`, `verification-before-completion` | `skills/tdd` (red for the right reason), `skills/implement` step 6, `skills/review` step 10, `setup/checks.md` |
| superpowers `skills/writing-plans` | not forked; watched for ideas |
| feature-dev `agents/code-reviewer.md` | `REVIEWER-CONTRACT.md` confidence scale, `agents/reviewer.md` shape |
| feature-dev `commands/feature-dev.md`, `agents/code-architect.md`, `agents/code-explorer.md` | not forked; watched for ideas |
