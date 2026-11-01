---
name: flow
description: "Interview, then generate this repo's engineering flow as its own skills and agents under .claude/: grill, spec, tickets, implement, review, research, pr, retro and one agent per reviewer. Run once per repo, again to change anything."
disable-model-invocation: true
---

# Flow

Generate the repo's engineering loop as files it owns: `.claude/skills/{grill,grilling,spec,tickets,implement,tdd,review,research,pr,retro}/` (plus `domain-modeling` when domain is on), `.claude/agents/<name>-reviewer.md`, and `.claude/flow/` for specs, tickets and research notes.
Projects differ, and so does how the user wants to work on each; this interview is where they say it, and the generated files carry it.
Nothing reads a config afterwards: the skills are the behaviour, edited like code.

The settings, their values and the templates are described in `${CLAUDE_PLUGIN_ROOT}/generator/README.md`; read it once.

## 1. Explore

Read what is there; assume nothing:

- `.claude/flow/settings` and `.claude/flow/generated`: a previous run; this one is a re-run, and the result is a diff per file, never a silent overwrite.
- `git remote -v`: GitHub, GitLab, something else, or no remote. `git log --oneline -30`: the commit style in use.
- Monorepo signals: `pnpm-workspace.yaml`, a `workspaces` field, `packages/*` or `apps/*` with their own `src/`, `go.work`, a Cargo workspace, a `.sln` with several projects.
- Domain docs: a `GLOSSARY.md`, `GLOSSARY-MAP.md` or `docs/adr/` in the repo suggests `domain=on`.
- Standards docs: `CODING_STANDARDS.md`, `CONTRIBUTING.md` or the like; they argue for the `standards` reviewer.
- A PR template: `.github/PULL_REQUEST_TEMPLATE.md` or `.gitlab/merge_request_templates/`.
- The stack and its risk surface: a web server, a mobile app, a CLI, a library; user input, auth, payments, a database. They decide which reviewers to recommend.
- A tracker skill (for example `jira`) available in this session, which shapes the `other` tracker answer.

## 2. Interview

Summarise what you found in a few lines.
Open with one line: if they would rather skip the questions, say so and you generate the recommended set for this repo; state the significant choices in one line each when they take it.
Otherwise read [grilling.md](./grilling.md) and run the rounds below, every question with your recommended answer, worded so "yes" accepts the round.
On a re-run, the previous settings are the recommendation and the questions are what to change.

**Round 1**

1. **Private or committed.** `private` adds the generated paths to `.git/info/exclude`, so nothing touches the team's repo; a fresh clone or worktree needs `/flow:flow` again. `committed` leaves them for the repo to commit. Recommend `private`.
2. **How you want to work here.** Ask it the way an engineer thinks: read and understand the code as it is built, or let it run and judge the result? Then the settings that follow, each named: `scope` (one ticket per run, or the whole epic from the frontier in fresh implementer agents), `pacing` (stop at the end of every section so they read it, or run through), `commits` (the agent commits, or they do), `gate` (what happens before a ticket: nothing, a yes, or a grilling of the ticket), `stops` (which of seams, spec, builder check and ticket breakdown wait for them). Recommend `ticket`, `checkpoint`, `agent`, `none`, all four stops for a repo they maintain; `epic`, `autonomous`, `agent`, `none`, `spec` only when they will mostly let it run; `gate=grill` when they want to shape each ticket before code. Epic scope always commits, on its integration branch.
3. **Tracker.** `local` always, unless they ask: specs and tickets as files under `.claude/flow/features/`. `github`, `gitlab`, or `other` with one paragraph on how to publish, fetch and close.
4. **Domain docs.** `on` when they want grill to keep a `GLOSSARY.md` and ADRs in the repo as it goes (Matt Pocock's domain-modeling, which lands in the working tree even in private mode); recommend `on` when such files already exist, else `off`.

**Round 2**

5. **Reviewers.** `spec` always. From the stack and risk surface, recommend which of `correctness`, `security`, `standards`, `tests` to install, each adapted: paths narrowed to where it applies, rules reworded for the language and frameworks found, rules that cannot apply removed. Ask for custom reviewers: name, what it looks at, its rules, what it skips, paths, inputs, model.
6. **Templates.** Spec, ticket and PR shapes; which sections to add, drop or rename. When the repo has its own PR template, merge its sections into the PR template and keep Evidence and Merge Danger.
7. **Research.** The sources this repo trusts first: folders or files on this machine, URLs, repos; `none` otherwise. How many research agents split a question, and on which model.
8. **Models.** The implementer (`epic` scope) and the builder check (`builder` stop), each `opus` unless the user says otherwise.

The interview is done when both rounds are answered and nothing is left assumed.

## 3. Generate

First run: `"${CLAUDE_PLUGIN_ROOT}/scripts/generate.sh" --out <repo root> --<setting> <value> ...` with every setting from the interview.

Re-run: generate into an empty scratch directory with the same flags, then for every path in `.claude/flow/generated` show `diff -u` of the repo's file against the fresh one and ask per file: keep yours, take the fresh one, or merge; the user's edits win by default. Copy only what they accept.

Then fill every `<!-- fill: ... -->` marker in the generated files with the Edit tool from the interview's answers, each marker's text saying exactly what goes there.
Custom reviewers: write `.claude/agents/<name>-reviewer.md` in the shape of a shipped one and add its row to the reviewer table in `.claude/skills/review/SKILL.md`.
`"${CLAUDE_PLUGIN_ROOT}/scripts/generate.sh" --check <repo root>` must print `no fill markers remain` before you go on.
`private`: `"${CLAUDE_PLUGIN_ROOT}/scripts/generate.sh" --exclude <repo root>`. `committed`: `--include`, and tell the user `.claude/` is ready to commit.
Never commit.

## 4. Done

List the generated paths and the workflow in one line (scope, pacing, commits, gate, stops).
Tell the user every file is theirs to edit by hand, that `/flow:flow` again changes settings with a diff per file, and that the flow starts with `/grill`.
