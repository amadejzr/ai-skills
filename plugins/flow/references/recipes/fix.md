# fix

Applies the findings of one review the way implement builds a ticket: pure, in the current context, test-first where behaviour changes, one commit per finding or group.
Every source of findings goes through the same door: a review file the review skill wrote, a PR's review comments, or pasted text, each normalised into the review file shape first.
It re-runs only the reviewers whose findings it fixed, on the fix commits alone, and closes the ticket when no must-fix remains.

## Frontmatter

```yaml
name: fix
description: "Use when the user wants the findings of a review fixed: the latest review of a ticket, a review file, a PR or MR's review comments, or review notes pasted into the chat; also when implement-spec hands its final review to an implementer."
argument-hint: "[ticket | review file | PR] [ids | all]"
```

Invocation mode: model-invoked and typed by the user; no `disable-model-invocation`.
The description says only when to use the skill.

## Varies by

- `tracker`: the `ticket-folder`, `fetch`, `fetch-review-comments`, `comment` and `close` verbs come from the chosen tracker recipe under `references/trackers/`; write the repo's own way of doing each verb into its span.
  A tracker with no `fetch-review-comments` deletes the PR row in step 1.
- `commits`: conventional commits by default, one per finding or group of findings with one root cause, written by the agent, with the ticket footer from `workflow.md`'s `commits` node; with user commits, replace the commit paragraph with "Leave the fixes uncommitted; the user commits." and mark findings `fixed, uncommitted`.
- `checkpoint`: on keeps the pause before each commit; off deletes it.
- Checks: the repo's check commands, one per line, as in implement.
- The review file shape and the contract are the review skill's siblings, `.claude/skills/review/REVIEW-FORMAT.md` and `.claude/skills/review/CONTRACT.md` (copied from `references/reviewers/CONTRACT.md`); fix links them, never copies them.
- Runners: the re-review goes through review, so a raising reviewer on `runner: codex`, `opencode`, `gemini` or `claude` runs through `.claude/skills/review/runners/<cli>.sh` (copied from `references/runners/<cli>.sh`) and one on `runner: agent` through the `reviewer` agent; fix never calls a runner itself.

## Skill text

````markdown
Fix the findings of one review.
Fix works in the current context, like implement: it never dispatches an implementer, and it never applies a finding nobody selected.
Findings come in the shape of [../review/REVIEW-FORMAT.md](../review/REVIEW-FORMAT.md), graded by [../review/CONTRACT.md](../review/CONTRACT.md).

## Process

### 1. Resolve the findings

| argument | source |
| --- | --- |
| a ticket reference or ticket folder | the highest-numbered `review-NN.md` in its folder `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/` |
| a path to a `review-NN.md` | that file |
| a PR or MR reference | its review comments, fetched {setup: the tracker recipe's `fetch-review-comments` verb as this repo runs it} |
| pasted text | the findings in the user's message |
| nothing | the ticket of the current branch, found as review finds it; ask when there is none |

A PR's comments and pasted text are normalised before anything is fixed.
Find the ticket they belong to (the PR's branch, body or linked issue; for pasted text, ask when it is not clear) and write them as a new `review-NN.md` in its folder, numbered after the highest one there, in the review file shape:

- `Source:` names the PR or who the text came from; `Range:` is the PR's diff or the current branch's.
- Each finding gets the id `<reviewer>-<n>`, the reviewer being the commenter's handle or the name the user gives, `rule: none` unless it cites a standard, and its severity and confidence graded by the contract after you have read the code it points at.
- A comment that is a question, praise or no finding at all is left out and listed under `## Declined to judge` with why.
- The `## Recommendation` names every must-fix.

Show the path of the new file before going on.

### 2. Select

Take the ids the user named, `all` for every open finding, or by default the ids in the file's `## Recommendation`.
Only findings with `status: open` can be selected; name any that are not and skip them.
Treat the set as a contract: those ids and no others.

Before touching code, check each selected finding against the code: restate it, confirm it holds, and find why the code is the way it is.
A finding that does not hold is not fixed: mark it `declined: <reason>` and name it in the report, so the user can insist with `/fix <ids>`.

Fetch the ticket {setup: the tracker recipe's `fetch` verb as this repo runs it, and its `ticket-folder` verb} and read its folder and epic, so fixes stay inside the ticket's scope.
Record the base: `git rev-parse HEAD`.

### 3. Fix

Order: must-fix first, then simple fixes, then complex ones.
A fix that changes behaviour starts with a failing test: call the Skill tool with "tdd" at the seam the epic agreed.
Run the touched test files after each fix and typechecking regularly.

Commit each finding, or each group with one root cause, as one conventional commit: `fix(<scope>): <what changed>`, with the finding ids and the ticket reference in the footer {setup: the footer form the tracker recognises}.

Before each commit, show the staged diff summary and the commit message, then stop and wait for the user's yes.

Mark each fixed finding `status: fixed in <commit>` in the review file as you go.

### 4. Re-review the fix commits

Call the Skill tool with "review" since the base you recorded, naming only the reviewers that raised a fixed finding, and passing the ticket and the fixed ids.
That review covers the fix commits alone and writes the next `review-NN.md`.
When no fixed finding came from a file in `.claude/skills/review/reviewers/` (PR comments, pasted text), name no reviewers and let review select by paths and condition.
Its new must-fix findings stay open there for the next `/fix`; do not loop, because review never converges and each round costs a full set of reviewers.

### 5. Prove the checks

Run every check and quote each command with the last line of its output; red is reported as red, never summarised as passing:

{setup: the repo's check commands, one per line in a code block, each with the paths it covers in a monorepo}

Append the `## Fix <YYYY-MM-DD HH:MM>` section to the review file you fixed from, with the selection, the re-review path and the checks.

### 6. Close

When the checks are green and neither the fixed review file nor the re-review has an open confirmed must-fix, comment on the ticket with the review file paths {setup: the tracker recipe's `comment` verb} and close it {setup: the tracker recipe's `close` verb as this repo runs it}.
Otherwise comment on the ticket with the review file paths and the findings still open, and leave it open.
A whole-branch review of an epic or a codebase review has no ticket to close.

Finish with one line per selected id (fixed with its commit, or declined with the reason), the check results, and the paths of both review files.
````

## Sibling files

None; fix links the review skill's `REVIEW-FORMAT.md` and `CONTRACT.md`.

## Handoffs

- Calls: `tdd` (Skill tool) for a fix that changes behaviour, `review` (Skill tool) for the re-review of the fix commits.
- Names next: `/fix <ticket>` again when the re-review left must-fix findings open, otherwise nothing.
- Called by: the user, and implement-spec's implementer agent for the final review-fix rounds.
