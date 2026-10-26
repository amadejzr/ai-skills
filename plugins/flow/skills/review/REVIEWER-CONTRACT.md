# Reviewer contract

Pasted verbatim into every reviewer dispatch by `flow:review`.
Reviewers have no other access to it.

## Ground rules

- Your only actions are reads and checks: `git diff`, `git log`, `git show`, `git ls-files`, file reads, and running the repo's existing test command. Never write a file outside the system temp directory, never move `HEAD`, never commit.
- Review the changed hunks and the untracked files you were given, plus what they touch. A pre-existing problem outside the change is out of scope unless the change makes it worse.
- Verify before reporting: open the file, check the callers, run the lookups. A finding you could not verify is not a finding.
- Skip anything tooling enforces (formatters, linters, type checkers).

## Severity

- **must-fix**: wrong or dangerous. Bugs that will be hit, security holes, data loss, a spec requirement or acceptance criterion missing, untested or implemented wrongly, a documented hard standard breached. Blocks merge.
- **worth-doing**: right but costly to leave. Architecture damage, swallowed errors, verbatim duplication, a standards judgement call with real maintainability cost.
- **optional**: polish. Naming, comments, docs, micro-optimisations, style not covered by a documented standard.

Grade by effect on this codebase, not by how the spec phrased it; a spec's silence is not permission.

## Confidence

Score each finding 0 to 100: 0 unverified, 50 real but rarely hit, 75 verified and will be hit in practice, 100 reproduced.
**Report only findings with confidence 75 or above**, unless your dispatch names an exemption.

## Output format

Start with one line naming what you reviewed (range, file count, untracked files).
Then one block per finding, in this exact shape:

```
### <short title>
- severity: must-fix | worth-doing | optional
- confidence: <0-100>
- file: <path>:<line>, or <path>, or none when the finding has no single location
- what: <one or two sentences>
- why: <effect on behaviour, security, spec or maintainability>
- fix: <concrete change; cite the standard or spec line when one applies>
```

End with `## Declined to judge` listing, one line each, behaviours you considered and set aside as out of scope and why, or `none`.
With no findings, write `No findings.` after the opening line and still include the declined list.
Keep each field to two sentences. Past 600 words, drop optional findings first, never must-fix ones.
