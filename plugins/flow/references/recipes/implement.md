# implement

Matt Pocock's implement for one ticket, with this repo's tracker, checks, commit style and checkpoint written in.
It stays pure: it builds and commits, then hands the change to review; it never applies review findings itself.

## Frontmatter

```yaml
name: implement
description: "Implement one ticket test-first, then hand it to review."
argument-hint: "<ticket>"
disable-model-invocation: true
```

Invocation mode: user-only.
The description is the one-line human description; it never changes.

## Varies by

- `tracker`: the `ticket-folder`, `fetch`, `blocker-done`, `comment` and `close` verbs come from the chosen tracker recipe under `references/trackers/`; write the repo's own way of doing each verb into the matching span, never a placeholder.
- `commits`: conventional commits by default, one commit per completed red-green cycle written by the agent, with the ticket footer from `workflow.md`'s `commits` node; with user commits, replace the commit paragraph with "Leave the work uncommitted; the user commits." and pass review the base instead of a commit range.
- `checkpoint`: on keeps the checkpoint paragraph; off deletes it.
- `domain`: on keeps the line about the glossary and ADRs with their paths; off deletes it.
- Checks: the check commands explore found (typecheck, lint, tests, build), one per line in the checks span; in a monorepo, one line per package with the paths it covers.

## Skill text

````markdown
Implement the ticket the user passes: a ticket reference, a path to a ticket folder, or the ticket text itself.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.
Fetch a ticket {setup: the tracker recipe's `fetch` verb as this repo runs it, including how to find the ticket's epic}.
Its folder is `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/` {setup: the tracker recipe's `ticket-folder` verb: the ticket itself for local, a stub naming the remote issue otherwise}; read `ticket.md`, `grill.md` when it exists, and the epic's `spec.md` before any code.
{setup: when domain is on, "Read the glossary and the ADRs that touch this area: <their paths>."; otherwise delete this line}
When a blocker of the ticket is not done ({setup: the tracker recipe's `blocker-done` verb}), say which and stop; the user decides.

Record the base before the first change: `git rev-parse HEAD`.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.
The seams are the ones the epic's Testing Decisions agreed; a seam the epic did not foresee is proposed to the user before any test is written at it, because a test at the wrong seam blesses the implementation instead of the behaviour.
Every acceptance criterion maps to at least one test, and every test goes red for the expected reason before the code that makes it green.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.
Then run every check and quote each command with the last line of its output; do not go on while any is red:

{setup: the repo's check commands, one per line in a code block, each with the paths it covers in a monorepo}

Commit your work to the current branch: one conventional commit per completed red-green cycle, `<type>(<scope>): <what changed>` in the imperative, with the ticket reference in the footer {setup: the footer form the tracker recognises, for example `Refs #12`, or the ticket folder name for local tickets}.

Before each commit, show the staged diff summary and the commit message, then stop and wait for the user's yes.

Once done, call the Skill tool with "review" since the base you recorded, passing the ticket reference and its folder.
When the review's recommendation names no must-fix finding, comment on the ticket with the review file path {setup: the tracker recipe's `comment` verb} and close it {setup: the tracker recipe's `close` verb as this repo runs it}.
Otherwise stop and leave the ticket open; the review names its file and the fix command.
````

## Sibling files

None.

## Handoffs

- Calls: `tdd` (Skill tool) for the build, `review` (Skill tool) once the work is committed.
- Names next: nothing of its own; review ends with the fix hint, and a clean review closes the ticket here.
- Called by: the user only; implement-spec does not call it, its implementer agent builds each ticket instead.
