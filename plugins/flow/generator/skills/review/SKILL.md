---
name: review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along this repo's reviewer axes, one reviewer agent each. Runs every reviewer in a parallel sub-agent and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Multi-axis review of the diff between `HEAD` and a fixed point the user supplies.
Each axis is one reviewer agent in `.claude/agents/`, with its own rules and model; the table below says which files it looks at and what it needs besides the diff.

Every reviewer runs as a **parallel sub-agent** so they don't pollute each other's context, then this skill aggregates their findings. Start every sub-agent with a fresh context window.

## Reviewers

| reviewer | paths | inputs |
| --- | --- | --- |
<!-- if reviewers~spec -->
| spec-reviewer | `**` | spec |
<!-- endif -->
<!-- if reviewers~correctness -->
| correctness-reviewer | `**` | none |
<!-- endif -->
<!-- if reviewers~security -->
| security-reviewer | `**` | none |
<!-- endif -->
<!-- if reviewers~standards -->
| standards-reviewer | `**` | standards |
<!-- endif -->
<!-- if reviewers~tests -->
| tests-reviewer | `**` | spec |
<!-- endif -->

`paths` are globs relative to the repo root; a reviewer whose paths match no changed file is skipped. To add a reviewer, add a row here and an agent file in `.claude/agents/`; to remove one, remove both.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched from the issue tracker below.
2. A path the user passed as an argument.
3. A spec file under `{{flow_dir}}/features/`, `docs/` or `specs/` matching the branch name or feature.

If nothing is found, ask the user where the spec is. If they say there isn't one, the reviewers that take `spec` will skip and report "no spec available".
<!-- if reviewers~standards -->

### 3. Identify the standards sources

Search the repo for every file that documents how code should be written. When `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it must be on the list. The smell baseline that applies even when a repo documents nothing lives in the standards reviewer's own agent file.
<!-- endif -->

### 4. Spawn every reviewer in parallel

Issue all the sub-agent calls together, in the foreground (the Agent tool, `subagent_type` set to the reviewer's name), and aggregate the reports they return.

Each reviewer's prompt should include:

- The full diff command and commit list, and the changed files that match its `paths`.
- Its `inputs`: for `spec`, the path or fetched contents of the spec; for `standards`, the list of standards-source files you found.
- The brief: "Report, per file/hunk where relevant, every finding your rules name: quote the hunk and cite the rule, standard or spec line it breaks. Distinguish hard violations from judgement calls. Skip anything tooling enforces. Under 400 words."

If the spec is missing, skip the reviewers that take `spec` and note this in the final report.

### 5. Aggregate

Present each report under a `## <reviewer>` heading, verbatim or lightly cleaned. Do not merge or rerank findings across reviewers, because the axes are deliberately separate (see **Why separate axes**).

End with a one-line summary: total findings per reviewer, and the worst issue within each (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why separate axes

A change can pass one axis and fail another:

- Code that follows every standard but implements the wrong thing → standards pass, spec fail.
- Code that does exactly what the issue asked but breaks the project's conventions → spec pass, standards fail.

Reporting them separately stops one axis from masking another.

## Issue tracker

<!-- if tracker=local -->
The epic is `{{flow_dir}}/features/<slug>/spec.md` and its tickets are `{{flow_dir}}/features/<slug>/issues/<NN>-<slug>.md`; fetch one by reading its file.
<!-- endif -->
<!-- if tracker=github -->
GitHub issues, via `gh` from inside the clone: `gh issue view <number> --comments`.
<!-- endif -->
<!-- if tracker=gitlab -->
GitLab issues, via `glab` from inside the clone: `glab issue view <number> --comments`.
<!-- endif -->
<!-- if tracker=other -->
<!-- fill: how to fetch a ticket and its epic on this repo's tracker, naming the CLI or skill to use -->
<!-- endif -->
