---
name: upstream
description: "Check the sources the flow plugin forks from for changes, port what is worth porting, and accept the new baseline. Run every week or two."
disable-model-invocation: true
---

# Upstream

The `flow` plugin forks text from Matt Pocock's skills, superpowers and Anthropic's official plugins.
Their copies at the version last reviewed live under `plugins/flow/upstream/<source>/` next to a `SOURCE` file.
The verbatim skills under `plugins/flow/references/verbatim/` are byte-identical to their baseline files; everything else was reworded into the references and the setup skill.
This is a maintainer skill of this checkout, not a plugin skill: ported changes reach a repo when the user runs `/flow:setup` there again.

## Rules

- Never edit a file under `plugins/flow/references/verbatim/` by hand; only `--accept` moves it, together with its baseline.
- Never move the baseline before the user has answered the port list.
- Every reference you touch stays under 20,000 bytes, one sentence per line, no em dashes; nothing in `references/` becomes a template engine.
- Do not commit.

## Process

1. Run `bash plugins/flow/scripts/upstream-check.sh --diff` from the checkout root.
   It clones each source at depth 1 and prints, per baseline file, `unchanged`, `CHANGED` with the diff, or `missing upstream`, then whether each verbatim copy is identical to its baseline.
   When it prints `no upstream changes`, say so and stop.
   Done when you have the output of one full run.
2. For every changed file, find the flow files it was forked into with the fork map below, read them, and judge each hunk:
   - **Port**: a fix or a sharper rule that applies to the flow as it is. For a verbatim skill, port means accept it as is. For a recipe or reference, reword it into the flow's names (`review` and reviewer files for `code-review`, the tracker recipes for issue-tracker files, `{setup: ...}` spans where it depends on a setup answer).
   - **Skip, divergence**: the flow deliberately does it differently, as recorded in the recipe's own text, `CLAUDE.md` or `CREDITS.md`. Name the divergence.
   - **Skip, not forked**: the change touches a part the flow never took.
   A file `missing upstream` was moved or deleted: search the clone for its new home and move the baseline file, or drop it when the content is gone; for a verbatim skill, also update `verbatim_forks` in `upstream-check.sh`.
   Done when every hunk has a decision.
3. Present the decisions as one list, one line per hunk: source file, flow file, port or skip, why.
   Wait for the user's answer; they may overturn any line.
4. Apply the ported hunks to the recipes and references, and to `plugins/flow/skills/setup/` where an interview or setup rule changed.
5. Run `bash plugins/flow/scripts/upstream-check.sh --accept`: it copies every upstream file into the baseline and every baseline file of a verbatim skill into `references/verbatim/`, and records the reviewed commit.
   Then show `git diff --stat plugins/flow/references/verbatim/` so the user sees which verbatim files moved.
6. Run `bash plugins/flow/tests/references.test.sh` and `claude plugin validate .`; fix what fails.
7. Update `CREDITS.md` when a ported change came from a new author or file, and propose a version bump in `plugins/flow/.claude-plugin/plugin.json` so re-runs of setup know the recipes moved.
   Done when the test passes and the user has the list of ported and skipped hunks.

## Fork map

Flow paths are under `plugins/flow/`.

| upstream | flow |
| --- | --- |
| mattpocock-skills `skills/productivity/grilling` | `references/verbatim/grilling/` (verbatim), and the grilling discipline in `skills/setup/interview.md` |
| mattpocock-skills `skills/engineering/tdd` | `references/verbatim/tdd/` (verbatim) |
| mattpocock-skills `skills/engineering/domain-modeling` | `references/verbatim/domain-modeling/` (verbatim) |
| mattpocock-skills `skills/engineering/grill-with-docs` | `references/recipes/grill.md` (divergence: `domain` off calls grilling alone; a ticket argument writes the result back) |
| mattpocock-skills `skills/engineering/to-spec` | `references/recipes/spec.md` and its template (divergence: seams agreed first, builder check, publishing through the tracker) |
| mattpocock-skills `skills/engineering/to-tickets` | `references/recipes/tickets.md` and its template (divergence: Touches, Verify, when-then criteria) |
| mattpocock-skills `skills/engineering/implement` | `references/recipes/implement.md` |
| mattpocock-skills `skills/engineering/implement-spec` | `references/recipes/implement-spec.md` with its implementer and merger agents (divergence: merged-blocker frontier, Touches-disjoint parallelism, three-round cap, checkpoint) |
| mattpocock-skills `skills/engineering/code-review` | `references/recipes/review.md`, `references/recipes/fix.md`, the smell baseline in `references/reviewers/catalogue/standards.md` (divergence: one reviewer file per axis, findings written to a file, fixes in fix) |
| mattpocock-skills `skills/engineering/pr` | `references/recipes/pr.md` |
| mattpocock-skills `skills/engineering/research` | `references/recipes/research.md` (divergence: notes in the epic folder, sources per repo) |
| mattpocock-skills `skills/engineering/retro` | `references/recipes/retro.md` |
| mattpocock-skills `skills/engineering/setup-matt-pocock-skills` | `skills/setup/`, `references/trackers/` (from its issue-tracker files), the `domain` node of `references/workflow.md` |
| mattpocock-skills `skills/productivity/writing-for-agents` | `references/principles.md` |
| superpowers `skills/brainstorming` | the builder check in `references/recipes/spec.md` |
| superpowers `skills/subagent-driven-development`, `requesting-code-review`, `receiving-code-review`, `verification-before-completion`, `test-driven-development`, `writing-plans` | `references/principles.md`, `references/recipes/implement-spec.md`, `references/recipes/fix.md`; mostly watched for ideas |
| feature-dev `agents/code-reviewer.md` | the generic reviewer agent and reviewer file shape in `references/reviewers/README.md`, the confidence scale in `references/reviewers/CONTRACT.md` |
| feature-dev `commands/feature-dev.md`, `agents/code-architect.md`, `agents/code-explorer.md` | not forked; watched for ideas |

Anthropic's security-review prompt (anthropics/claude-code-security-review) and the pr-review-toolkit agents are not baselined; check them by hand when the security or tests reviewer in `references/reviewers/catalogue/` needs a refresh.
