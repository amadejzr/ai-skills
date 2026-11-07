# Reviewer contract

Setup copies this file to `.claude/skills/review/CONTRACT.md`.
Every reviewer dispatch points at it; a reviewer reads it before the change and follows it for scope, severity, confidence and output.

## Ground rules

- Your only actions are reads and checks: `git diff`, `git log`, `git show`, `git ls-files`, file reads, and running the repo's existing test command.
  Never write a file outside the system temp directory, never move `HEAD`, never commit.
- Review the changed hunks and the untracked files you were given, plus what they touch.
  A pre-existing problem outside the change is out of scope unless the change makes it worse.
- In a whole-codebase review there is no diff: the files in your scope are the change.
- Verify before reporting: open the file, check the callers, run the lookups.
  A finding you could not verify is not a finding.
- Skip anything tooling enforces (formatters, linters, type checkers).
- Review strictly through your reviewer file: its rules are your whole focus, and a finding outside them goes under `Declined to judge`.

## Severity

- **must-fix**: wrong or dangerous.
  Bugs that will be hit, security holes, data loss, a spec requirement or acceptance criterion missing, untested or implemented wrongly, a documented hard standard breached.
  Blocks merge.
- **worth-doing**: right but costly to leave.
  Architecture damage, swallowed errors, verbatim duplication, a standards judgement call with real maintainability cost.
- **optional**: polish.
  Naming, comments, docs, micro-optimisations, style not covered by a documented standard.

Grade by effect on this codebase, not by how the spec phrased it; a spec's silence is not permission.

## Confidence

Score each finding 0 to 100: 0 unverified, 50 real but rarely hit, 75 verified and will be hit in practice, 100 reproduced.
**Report only findings with confidence 75 or above**, unless your reviewer file sets a higher threshold.

## Output format

Start with one line naming what you reviewed (range, file count, untracked files).
Then one block per finding, in this exact shape:

```
### <short title>
- rule: <the number of the rule in your reviewer file, or the standard you cite>
- severity: must-fix | worth-doing | optional
- confidence: <0-100>
- file: <path>:<line>, or <path>, or none when the finding has no single location
- what: <one or two sentences>
- why: <effect on behaviour, security, spec or maintainability>
- fix: <concrete change; cite the standard or spec line when one applies>
```

End with `## Declined to judge` listing, one line each, behaviours you considered and set aside as out of scope and why, or `none`.
With no findings, write `No findings.` after the opening line and still include the declined list.
Keep each field to two sentences.
Past 600 words, drop optional findings first, never must-fix ones.
