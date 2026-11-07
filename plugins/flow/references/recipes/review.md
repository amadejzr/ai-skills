# review

Multi-reviewer review of one change, written to a numbered review file in the ticket's folder.
It selects reviewers by their files, runs each in a fresh context, verifies every must-fix finding with a fresh agent, writes the file, and stops: it applies nothing.
Matt Pocock's code-review is the starting point; his separate axes become reviewer files, and the caller applying fixes becomes the fix skill.

## Frontmatter

```yaml
name: review
description: 'Use when the user wants a branch, a PR, staged or working-tree changes, or the whole codebase reviewed, asks to "review since X" or to run named reviewers, or when implement, implement-spec or fix hands a change to review.'
argument-hint: "[since <ref> | staged | working | codebase] [reviewer ...]"
```

Invocation mode: model-invoked and typed by the user; no `disable-model-invocation`.
The description says only when to use the skill.

## Varies by

- `reviewers`: setup writes one file per reviewer under `.claude/skills/review/reviewers/<name>.md` from `references/reviewers/catalogue/` and the user's own, with frontmatter `model`, `paths`, `inputs`, `condition`, `runner`.
  The skill text never lists them; it reads the directory.
- Runners: for every reviewer whose `runner` is `codex`, `opencode`, `gemini` or `claude`, setup copies `references/runners/<cli>.sh` to `.claude/skills/review/runners/<cli>.sh`; with every reviewer on `runner: agent` the runners paragraph in step 5 is deleted.
- The contract: setup copies `references/reviewers/CONTRACT.md` to `.claude/skills/review/CONTRACT.md` unchanged.
- `tracker`: the `ticket-folder` and `fetch` verbs from the chosen tracker recipe under `references/trackers/` go into step 2.
- `domain`: on fills the `domain` input line with the glossary and ADR paths; off deletes that line.
- `models`: the `verifier` model goes into step 6.
- Inputs: the input names are `ticket`, `standards` and `domain` (see `references/reviewers/README.md`); setup fills the `standards` line with this repo's standards docs mapped to the paths each governs.

## Skill text

````markdown
Multi-reviewer review of one change.
Each reviewer is one file in [reviewers/](reviewers/): its frontmatter says its `model`, `paths`, `inputs`, `condition` and `runner`, and its body is its whole instruction.
Every reviewer returns findings in the shape of [CONTRACT.md](CONTRACT.md).
Review writes one numbered review file and stops. It applies nothing, it never edits code, and it never commits, because the user chooses what gets fixed and a reviewer that also fixes stops judging its own work.

## Process

### 1. Pin the range

Take the mode the user or the caller named; otherwise pick by state and say which you picked.

| mode | argument | change | default when |
| --- | --- | --- | --- |
| since | `since <ref>` | `git diff <ref>`: committed and uncommitted work since `<ref>` | a caller passes a base |
| staged | `staged` | `git diff --cached` | never |
| working | `working` | `git diff HEAD` | the tree is dirty |
| codebase | `codebase` | every tracked file (`git ls-files`); there is no diff, the files in scope are the change | never |

With no argument and a clean tree, ask for the ref.
In since and working mode, untracked files are part of the change: list them with `git ls-files --others --exclude-standard`.
Confirm the ref resolves (`git rev-parse`) and the change is non-empty before dispatching anything.
Capture the diff command, the commit list (`git log <ref>..HEAD --oneline`, or "uncommitted") and the changed file list, untracked files marked `(new)`.

### 2. Find the ticket and the epic

In this order: the ticket or epic the user or caller passed; ticket references in the commit messages or the branch name; a ticket folder `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/` whose name matches the branch.
Fetch a ticket {setup: the tracker recipe's `fetch` verb as this repo runs it, including how to find the ticket's epic, and its `ticket-folder` verb}.

The review file goes into the ticket's folder; for a whole-branch review of an epic, into `.claude/flow/<epic-slug>/`; in codebase mode, into `.claude/flow/codebase/`.
When nothing is found, ask which ticket or epic this change belongs to.
Its number `NN` is one more than the highest `review-NN.md` already in that folder, two digits, starting at `01`.

### 3. Select the reviewers

When the user or caller named reviewers (`/review since main security spec`), run exactly those; a name with no file in `reviewers/` is an error, so list the files there are and ask.
Otherwise read the frontmatter of every file in `reviewers/` and select a reviewer when at least one changed file matches its `paths` and its `condition` holds for this change.
Print one line per reviewer before dispatching: `selected` or `skipped`, and why (the matching files and the condition, or what did not match).
A one-line change does not pay for reviewers whose paths and conditions it does not meet.

### 4. Resolve the inputs

For each selected reviewer, the changed files that match its `paths` are its scope.
Resolve each name in its `inputs` to paths, never pasted text:

- `ticket`: the ticket folder's `ticket.md` and `grill.md`, and the epic's `spec.md`; for a whole-branch review, the epic's `spec.md` and every ticket folder under it.
- `standards`: {setup: this repo's standards documents, each with the paths it governs}; pass only the ones that govern a file in the reviewer's scope.
- `domain`: {setup: when domain is on, the glossary and ADR paths; otherwise delete this line}.

A reviewer whose input does not exist is skipped and listed with the reason.
For a whole-branch review of an epic, every reviewer also gets the paths of the `review-NN.md` files under the epic's ticket folders that hold a `declined` finding, so nothing deferred is forgotten.

### 5. Dispatch every reviewer in parallel

Issue every dispatch in one message, each in a fresh context, and wait for all of them.

A reviewer with `runner: codex`, `opencode`, `gemini` or `claude` runs through its script in `runners/`.
Write the change to a temporary diff file first (untracked files appended with `git diff --no-index /dev/null <file>`; in codebase mode, the scoped files against the empty tree, `git diff 4b825dc642cb6eb9a060e54bf8d69288fbee4904 HEAD -- <files>`), then run it in the background with Bash:

```sh
bash .claude/skills/review/runners/<runner>.sh <diff-file> .claude/skills/review/reviewers/<name>.md .claude/skills/review/CONTRACT.md <output-file> [input-file...]
```

The first four arguments are fixed; after them come the reviewer's resolved input paths from step 4, one file per argument (a folder such as a ticket folder or the ADR directory expanded to the markdown files in it), and for a whole-branch review the declined review files.
The script runs the CLI read-only with the reviewer file's `model` and writes the report to `<output-file>`; a non-zero exit is reported as `failed: <name> (<message>)`, never as a clean review, and the other reviewers still count.

A reviewer with `runner: agent` runs through the Agent tool with `subagent_type` `reviewer` and `model` set to the file's `model`.
Its prompt holds pointers, in this order:

1. The range and its diff command (none in codebase mode), the commit list, the untracked files to read in full, and the reviewer's scoped files.
2. The contract path: `.claude/skills/review/CONTRACT.md`.
3. Its reviewer file path: `.claude/skills/review/reviewers/<name>.md`.
4. Its resolved inputs from step 4.
5. The brief: "Review this change through your reviewer file and report in the contract's output format."

### 6. Merge, write, verify

Parse every finding block, keeping its `rule` line, and every `## Declined to judge` list.
Give each the id `<reviewer>-<n>`, numbered per reviewer in its report's order.
Two findings with the same root cause in the same hunk are one: keep the higher severity, and record the other id as `also`.
Keep each reviewer's severity; never upgrade or downgrade a must-fix you have not verified, because a reviewer wrong about a must-fix is exactly what the verifier is there to catch, and your reading of the diff is no fresher than its.

Write `review-NN.md` in the shape of [REVIEW-FORMAT.md](REVIEW-FORMAT.md), with every must-fix marked `verified: pending`.

Then verify each must-fix finding with its own fresh agent, all in parallel: the Agent tool, `subagent_type` `general-purpose`, model `{setup: the verifier model}`, with the review file path, the finding id and the diff command, and the brief: "Read only; change nothing. Confirm or refute this finding against the code: does it hold in this codebase, is the cited line right, would the fix work? Answer `confirmed` or `refuted` with one line of evidence."
A confirmed finding becomes `verified: confirmed`; a refuted one moves to `## Refuted` with the evidence, and no longer counts.

Write the `## Recommendation`: every confirmed must-fix, plus the worth-doing findings that are cheap and inside the ticket's scope, each id named, with one line of why; or `Fix: none.`

### 7. Report and stop

Print the findings as a compact list, one line each, grouped by severity: id, title, file, confidence.
End with exactly:

- the review file path;
- the fix hint: `/fix <ticket>` applies the recommendation, `/fix <ticket> <ids>` or `/fix <ticket> all` a different set;
- one line `Retro candidate: <what slipped and what would have caught it>` when a finding shows something a check, a standards line, a reviewer rule or a navigation pointer would have caught; otherwise no line.

Do not apply, stage or commit anything.

For a one-shot security pass on the merge-base alone, the built-in `/security-review` is the alternative to the security reviewer here.
````

## Sibling files

`CONTRACT.md` is copied from `references/reviewers/CONTRACT.md` unchanged, `reviewers/<name>.md` are written from the catalogue, and `runners/<cli>.sh` are copied from `references/runners/<cli>.sh`.
The skill also carries the review file shape, which fix writes too:

### REVIEW-FORMAT.md

````markdown
# Review file format

A review file is `review-NN.md` in a ticket folder, an epic folder or `.claude/flow/codebase/`.
The review skill writes it; the fix skill writes one from pasted findings or PR comments, and appends its outcomes to it.

```markdown
# Review NN: <ticket title, epic slug or "codebase">

- Range: `<diff command>` plus <n> untracked files
- Commits: <commit list or "uncommitted">
- Ticket: <reference and folder, or "none">
- Epic: <path to spec.md, or "none">
- Source: review | PR <reference> comments | pasted from <who>
- Reviewers: <name> (<model or runner/model>), ...; skipped: <name> (<reason>), ...

## Must fix

### <reviewer>-<n> <short title>
- rule: <the reviewer's rule number or the standard cited>
- severity: must-fix
- confidence: <0-100>
- file: <path>:<line>, or <path>, or none
- what: <one or two sentences>
- why: <effect on behaviour, security, spec or maintainability>
- fix: <concrete change>
- verified: pending | confirmed | not run
- also: <other ids with the same root cause, or omit>
- status: open

## Worth doing

<same block, severity worth-doing, no verified line>

## Optional

<same block, severity optional, no verified line>

## Refuted

- <id> <title>: <the verifier's evidence>

## Declined to judge

- <reviewer>: <what it set aside and why>

## Recommendation

Fix: <ids>. <one line why>.
```

`status` is one of `open`, `fixed in <commit>`, `fixed, uncommitted`, or `declined: <reason>`.
Fix rewrites only `status` lines and appends one section per run:

```markdown
## Fix <YYYY-MM-DD HH:MM>

- Selected: <ids>
- Re-review: <path to the review file the re-review wrote, or "none">
- Checks: `<command>`: <last line of its output>
```

An empty section reads `none`; no section is removed.
````

## Handoffs

- Calls: the `reviewer` agent (Agent tool) per Claude reviewer, `runners/<cli>.sh` (Bash) per external reviewer, one `general-purpose` verifier agent per must-fix finding.
- Names next: `/fix <ticket>` with the review file path, and `/retro` through the retro candidate line when there is one.
- Called by: the user, implement after a ticket is committed, implement-spec for the whole-branch review, and fix for its re-review.
