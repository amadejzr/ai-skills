---
name: fix
description: "Implement the fixes from a code review: a review file written by flow:review, the review comments on a pull request, or a review someone pasted. Records the review in the flow directory, lists the findings with a recommendation, applies exactly the ones the user picks after verifying each, re-reviews the fixes, runs the repo checks and closes the ticket. Use when flow:review has written its review file, when the user wants to act on review feedback (\"fix the review\", \"address the PR comments\", \"apply F1 and F3\"), or when someone else has reviewed the code."
---

# Fix

Take one review, from any source, and turn the findings the user picks into verified, tested fixes with green checks and a written record.

Call the Skill tool with "flow:config": it resolves the flow directory with its `reviews/` and reviewer files, and `config.md` with the selection mode, checks and the tracker rules for closing tickets.
With no flow directory, stop and suggest `/flow:setup`.

## Process

### 1. Load the review

The review comes from one of three sources, the one the user or the calling skill named:

- **A review file** in the flow directory's `reviews/`: a path, or the newest file there whose slug matches the branch when none is named. Its findings already carry ids, tiers and reviewers. `flow:review` hands over this way.
- **A pull request**: `gh pr view <n> --json number,title,url,reviews` for the review bodies and `gh api repos/{owner}/{repo}/pulls/<n>/comments` for the line comments. Take the comments on threads that are not resolved and not outdated.
- **Text**: a review the user pasted or a file they point at, written by a person or another tool.

A pull request or text becomes a new review file before anything else, so every review has the same durable record.
Path: `<flow dir>/reviews/<YYYY-MM-DD-HHMM>-<slug>.md`, the slug being the PR number (`pr-<n>`), the ticket id or the branch name.
Split the review into one finding per distinct request, numbered `F1`, `F2`, ... in the order the reviewer wrote them, and write:

```markdown
# Review: <slug>

- Source: <PR url | "pasted" | the file path>, by <reviewer as the review names them, or "unknown">
- Change: <the branch and base, or the PR's>
- Spec: <ticket and epic references found in the PR, branch or review, or "none">

## Findings

### F1 <title>
- file: <path>:<line>, or "general"
- what: <the request, in the reviewer's words>

## Original review

<the review text exactly as received, with each PR line comment's path and line>
```

The `## Original review` section keeps the reviewer's own words next to your reading of them, so a misread request can be traced.

### 2. Let the user choose

Print the findings in chat as a compact list, one line each, grouped by tier when the review file has tiers, with any `regraded` line shown as `F3 must-fix→optional: <reason>`:

```
Must fix
  F1  Stored XSS in the HTML page          src/server.js:15      correctness
  F2  Reused ids after delete              src/todo-store.js:15  correctness+security
Worth doing
  F7  No tests for error paths             test/todo-store.test.js  correctness
```

Then end your turn with the review file path and one question, worded so "yes" accepts the recommendation.

- A review from `flow:review` with must-fix findings: "Recommended: apply all must-fix (F1 to F6). Reply **yes**, `+F7` to add, `-F2` to drop, a list of ids, `all`, or `none`."
- A review from `flow:review` with none: "No must-fix findings. Recommended: `none`. Reply **yes**, a list of ids, or `all`."
- A review from a pull request or text: "Recommended: all (F1 to F5); each is verified before it is applied. Reply **yes**, `-F2` to drop, a list of ids, or `none`."

**Reply grammar**: `yes` is the recommended set; `all` is every finding; `none` applies nothing; a list of ids is exactly those ids; `+F7` adds to and `-F2` removes from the recommended set. Ids are case-insensitive, separated by spaces or commas. Anything else is a question: answer it and ask again.

When the config says `Selection: dialog` and the host has AskUserQuestion (Claude Code), ask with it instead: pack findings four per `multiSelect` question and up to four questions per call, headers `Must fix`, `Worth doing`, `Optional` (or `Findings` for an untiered review), label `F<n> <short claim>`, description `<file>:<line> <summary>`, every recommended option marked "(Recommended)". A lone finding becomes a yes/no question. The automatic Other row takes free text.

When the user already named the ids (`apply F1 and F3`), that is the answer; do not ask again.
Nothing is applied until the answer arrives.

### 3. Verify, then apply the selection

Resolve the answer to a set of ids with the reply grammar. Treat the set as a contract: those ids and no others.

Before touching code, verify each selected finding: restate it, confirm it holds in this codebase as it is now, confirm the fix breaks nothing, find the reason the current code is the way it is.
A review file from an earlier day may point at lines that have since moved or changed; find the code the finding is about, not the line number.
If verification overturns a selected finding, a request is unclear, or you cannot verify it, list those ids with your reasoning and ask before applying anything; the user may insist.
For a review by a person, that list with its reasoning is the user's reply to the reviewer: technical reasons, no agreement for its own sake.

Snapshot the tree first: `SNAP=$(git stash create || git rev-parse HEAD)`.
Order: must-fix first, then simple fixes, then complex ones.
A fix that changes behaviour gets a failing test first; call the Skill tool with "flow:tdd".
Run the touched test files after each fix.

### 4. Re-review the fixes

Only for a review whose findings name reviewer files that exist in `reviewers/`; a person re-reviews their own comments.
One scoped round. Dispatch only the reviewers whose findings were applied, each as the agent `flow:reviewer` with its file's `model`, over `git diff $SNAP`, with the applied ids and the reviewer file's body as its instructions under `## Your instructions`.
The prompt says the round is read-only: reads, `git diff`, `git log`, `git show` and the repo's test command; never write a file outside the system temp directory, move `HEAD` or commit.
Each answers, per id, `ADDRESSED` or `NOT ADDRESSED` with one line, and lists new breakage in the fix diff only.
Fix anything `NOT ADDRESSED` or newly broken once; residuals go into the review file, not into another round.

### 5. Prove the checks and close

On every path, including `none`: run every command in the config's `## Checks` and quote each command with the last line of its output. Red output is reported as red, never summarised as passing.

Append to the review file:

```markdown
## Applied <YYYY-MM-DD HH:MM>

- F1: fixed. <one line>  (re-review: ADDRESSED)
- F4: skipped. <reason>

## Deferred

- F7 ...  (not selected)

## Checks

- `npm test`: 12 passed
```

When the review names a ticket and the checks are green, close the ticket as the tracker rules say, with the criteria met and the review file path.
Finish with the per-id outcomes, the check results, and the review file path.
Changes stay uncommitted; the user commits or asks for a commit. Nothing is posted to the pull request unless the user asks.

## Why the user picks and every pick is verified

Reviewers grade effect, but the user owns scope: a worth-doing finding may be out of scope for this ticket, and only they know.
Verifying each pick before applying it catches the findings that are wrong for this codebase, from an agent or a person, before they become code.
The review file is the durable record: a fix can run in a later session than the review, `## Deferred` feeds the branch review after the last ticket, and `/flow:retro` reads `## Applied`.
