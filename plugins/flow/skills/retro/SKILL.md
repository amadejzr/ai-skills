---
name: retro
description: "Retrospective on a ticket or session: turn what the reviewers missed or the agent fumbled into reviewer rules, standards, checks or navigation pointers."
disable-model-invocation: true
---

# Retro

The user has asked for a **retrospective**. You are suggesting improvements to the agent's **environment** for this repo so the next ticket runs better: the reviewer files in the flow directory's `reviewers/`, the sections of its `config.md` (standards map, standards notes, checks, navigation) and, for mechanical rules, the repo's own linter. Call the Skill tool with "flow:config" to find them. Nothing goes into the repo's docs or `CLAUDE.md`.

## Steps

1. Read the primary sources: the review files in the flow directory's `reviews/` for the ticket or branch the user names (their `## Applied`, `## Deferred`, `## Checks` and `## Declined to judge` sections), the ticket, and the session transcript when the user points at one. With nothing named, take the current session and its most recent review file.

2. Look for candidates in these categories.

- **Reviewer gaps**: a defect found late (by the user, by a later ticket, by the branch review) that a reviewer should have caught. Which reviewer? Add a rule to its file's body, widen its `paths`, raise its `model`, or write a new reviewer file. _Use when_ a must-fix surfaced outside the review that should have found it.
- **Coding standards**: a rule a reviewer that takes `standards` should enforce, remove or clarify. Classify first: a **mechanical** violation (a fixed syntactic pattern, a banned API, an import shape, a file-location rule) gets a deterministic check in the repo's own linter, a pre-commit hook or a CI job, whichever the repo already has; default to building the check over writing the rule. Reserve `## Standards notes` in the config for **judgement calls** no tool can make; a repo doc is never edited. In a monorepo, say which package the note applies to. _Use when_ a reviewer flagged the same thing twice, or missed something a rule would have named.
- **Checks**: a command in the config's `## Checks` that was missing, wrong, slow or flaky, or a repo with no guardrail (no pre-commit hook and no CI running the checks). _Use when_ a red check was found late, or a check never ran.
- **Navigation**: time lost finding the right files or a hidden dependency between files; a **navigation pointer** in the config's `## Navigation` fixes it; `flow:implement` reads it before exploring. _Use when_ exploration dominated the session.
- **Noise**: findings that were skipped as wrong or out of scope more than once from the same reviewer; a rule in its file that sends it elsewhere, or a line on what it should skip. _Use when_ `## Applied` shows repeated `skipped`.
- **No-ops**: a note, pointer or reviewer rule that never changed behaviour, or a reviewer that never found anything. _Use when_ the flow directory has grown.

3. Present the candidates in order of severity, each as the exact edit: file, the line to add or change, and the evidence (review file and finding id, or the transcript moment).

4. Apply the edits the user accepts.

## Reference

All work goes through two stages: implementation and review.
The implementation agent carries the most **context pressure**: exploration, writing code, debugging.
The review agents carry the least: they receive a change, so no exploration.
So standards are imposed by the reviewers, not the implementer, and the cheapest improvement is usually one more rule in a reviewer file or one more row in the standards map.
