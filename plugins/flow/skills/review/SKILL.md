---
name: review
description: "Multi-reviewer code review of a change (since a base ref, a committed range, staged, or the whole working tree) using the reviewer files, models and coding standards in the repo's flow directory. Runs every reviewer or the ones named, writes the review to the flow directory, then hands it to flow:fix, which lets the user pick the findings to apply, applies them, re-reviews the fixes, runs the repo checks and closes the ticket. Use when the user wants to review a branch, a PR, work-in-progress changes, asks to \"review since X\", or when flow:implement finishes a ticket."
---

# Review

Run every configured reviewer in parallel over one change, merge their findings into three tiers, write the review file, and hand it to `flow:fix` to choose, apply and prove.

Call the Skill tool with "flow:config": it resolves the flow directory with its reviewer files, and `config.md` with the standards map and notes, domain docs and the tracker rules for fetching tickets.
With no flow directory or no file in `reviewers/`, stop and suggest `/flow:setup`; nothing runs on defaults.
Nothing is read from the repo except the code under review and the repo's own docs the config points at, and nothing is written there; fixes are `flow:fix`'s job.

## Process

### 1. Pick the reviewers and pin the change

Every file in `reviewers/` runs, unless the user or the calling skill names reviewers after the mode (`/flow:review since main security spec`): then exactly those. A named reviewer with no file is an error; list the files there are and ask.

Four modes. Take the one the user or the calling skill named; otherwise pick by state and say which you picked:

| mode | argument | diff command | default when |
| --- | --- | --- | --- |
| since | `since <ref>` | `git diff <ref>` (two-dot: committed and uncommitted work since `<ref>`) | `flow:implement` hands off |
| range | `<fixed-point>` (a commit, branch, tag, `main`, `HEAD~3`) | `git diff <fixed-point>...HEAD` (three-dot: against the merge-base, committed work only) | never: ask for the fixed point when the tree is clean |
| staged | `staged` | `git diff --cached` | never |
| working | `working` | `git diff HEAD` | the working tree is dirty |

In every mode except `range`, untracked files are part of the change: list them with `git ls-files --others --exclude-standard` and hand them to reviewers to read in full.
Confirm the ref resolves (`git rev-parse`) and the change is non-empty (diff or untracked files) before dispatching anything.
Capture the commit list (`git log <ref>..HEAD --oneline`, or "uncommitted") and the **changed file list**: the union of `git diff --name-only` for the mode and the untracked files, each untracked one marked `(new)`.

### 2. Identify the spec

Only when a picked reviewer takes `spec` in its `inputs`. In this order:

1. The ticket and its parent spec (epic) passed by the user or by `flow:implement`. Fetch both from the issue tracker.
2. Ticket references in the commit messages or the branch name, fetched from the issue tracker, plus the parent spec they name.
3. A spec or ticket under the flow directory's `features/`, or a file under the repo's `docs/` or `specs/`, whose name matches the branch or feature.
4. Ask the user. If there is none, every reviewer taking `spec` is skipped and listed as `skipped: <name> (no spec)`.

### 3. Build each reviewer's scope

For each picked reviewer file, read its frontmatter and body:

- Filter the changed file list by its `paths` globs; `[]` means every file. A reviewer with no matching files is **skipped** and listed as such in the review file.
- `standards` in `inputs`: resolve the standards map. For every changed file in scope, the docs of the first matching row. Drop docs that do not exist and list them in the review header; a file left with no docs is marked `no documented standards`. Pass the `## Standards notes` section with the map.
- `domain-docs` in `inputs`: the paths of the glossary and ADRs that exist, in the flow directory's `domain/` and the repo's own committed ones.
- `spec` in `inputs`: the ticket text and the epic text (or their paths) from step 2.

### 4. Dispatch all reviewers in parallel

Issue every subagent call (the Agent tool in Claude Code, the Task tool in OpenCode) in one message, in the foreground.
Every reviewer runs as the agent `flow:reviewer`; what it reviews for comes only from its file.
Pass the file's `model` where the host takes a per-call model (Claude Code); elsewhere the dispatching agent's model applies.
Each prompt contains, in this order:

1. The diff command, the untracked files to read in full, the commit list, and the reviewer's scoped file list.
2. The full text of [REVIEWER-CONTRACT.md](./REVIEWER-CONTRACT.md), pasted verbatim: the reviewer has no other access to it.
3. The reviewer file's body, verbatim, under `## Your instructions`.
4. The reviewer-specific inputs from step 3.
5. The brief: "Review this change and report in the contract's output format."

Reviewers only read; nothing is changed here.

### 5. Merge

- Parse every finding block. Assign ids `F1`, `F2`, ... in the order must-fix, worth-doing, optional, and within a tier by confidence descending.
- Two findings with the same root cause in the same hunk are one finding: keep the higher severity, join the reviewer names with `+`.
- Re-grade by effect, sparingly, and visibly: when a reviewer graded a nit as must-fix or a real bug as optional, move it and record the move under the finding's heading as `- regraded: must-fix→optional: <reason>`, for `flow:fix` to show. Never downgrade a must-fix you have not verified yourself. Otherwise keep each reviewer's tier.
- Keep every reviewer's `Declined to judge` list.

### 6. Write the review file

Path: `<flow dir>/reviews/<YYYY-MM-DD-HHMM>-<slug>.md` where the flow dir comes from `flow:config` and the slug is the ticket id or the branch name.
Create the directory if needed.

```markdown
# Review: <slug>

- Change: `<diff command>` plus <n> untracked files
- Commits: <list or "uncommitted">
- Spec: <ticket and epic references, or "none">
- Reviewers: <name (model)>, ... ; skipped: <name (reason)>, ...
- Standards docs missing: <paths or "none">
- Ready to merge: yes | with fixes | no

## Must fix

### F1 <title>  (<reviewer>, confidence <n>)
- file: <path>:<line>
- what: ...
- why: ...
- fix: ...

## Worth doing

...

## Optional

...

## Declined to judge

- <reviewer>: ...

## Reviewer summaries

- <reviewer>: <one line: finding count and the worst finding>
```

`Ready to merge` is `no` with any must-fix, `with fixes` with only worth-doing, `yes` otherwise.

### 7. Hand over to fix

Call the Skill tool with "flow:fix", passing the review file path.
It lists the findings with the recommendation, applies exactly the ones the user picks, re-reviews the fixes, runs the checks and closes the ticket.

## Why tiers from reviewers, and a separate fix

Reviewers grade effect; they see the whole change through one lens each and should not be overruled wholesale.
The review file is the durable record, so applying it is a separate step: `flow:fix` takes this file, a pull request's comments or a review someone pasted, and treats them the same way.
