---
name: implement
<!-- if scope=ticket -->
description: "Implement a piece of work based on a spec or set of tickets."
<!-- else -->
description: "Implement the result of /spec and /tickets in code."
<!-- endif -->
disable-model-invocation: true
---

<!-- if scope=ticket -->
Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.
<!-- if gate=confirm -->
State what the ticket delivers and wait for a yes before starting.
<!-- endif -->
<!-- if gate=grill -->
Call the Skill tool with "grilling" over the ticket before starting, and write what changed back into the ticket.
<!-- endif -->

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.
<!-- if pacing=checkpoint -->
After each red → green cycle, stop, say in one line what it built, and wait for the user before the next one.
<!-- endif -->

Once done, call the Skill tool with "review" to review the work.

<!-- if commits=agent -->
Commit your work to the current branch.
<!-- else -->
Leave the work uncommitted; the user commits.
<!-- endif -->
Resolve the ticket the way the issue tracker closes work.
<!-- else -->
You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

The goal is the entire spec implemented on a single **integration branch**, with every ticket resolved the way the issue tracker closes work.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Start every subagent with a fresh context window.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** are the `implementer` agent (the Agent tool, `subagent_type` `implementer`) and should be run in the background where possible for maximum concurrency.

## Steps

1. Read the spec and tickets to understand the task graph.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in `{{flow_dir}}/research/`, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create the integration branch. If the issue tracker closes work through PRs, or the user asks for one, open a draft PR after the first merge in step 5 (a branch with no commits ahead of main can't open one), marked as closing the spec and tickets.

4. Use a fresh **implementer subagent** for each ticket, each in its own worktree on its own branch. Each implementer subagent:
   - confirms its worktree is based on the integration branch before starting, and resets onto it if not;
   - builds the ticket test-first at pre-agreed seams;
   - merges the integration branch tip into its own branch before reporting done
<!-- if gate=confirm -->
   Before dispatching one, state the ticket's title and what it delivers, and wait for a yes.
<!-- endif -->
<!-- if gate=grill -->
   Before dispatching one, call the Skill tool with "grilling" over the ticket and write what changed back into it.
<!-- endif -->

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent**.
<!-- if pacing=checkpoint -->
   After each merge, stop, say in one line what landed, and wait for the user before going on.
<!-- endif -->

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new tickets. This allows for maximum concurrency.

7. Once all tickets are complete, call the Skill tool with "review" on the integration branch. Fix all issues raised by the review in a single fresh **implementer subagent**.

8. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes work, and report the integration branch.

9. Clean up all **implementer subagent** worktrees.
<!-- endif -->

## Issue tracker

<!-- if tracker=local -->
Tickets are files: the epic is `{{flow_dir}}/features/<slug>/spec.md` and its tickets are `{{flow_dir}}/features/<slug>/issues/<NN>-<slug>.md`. A bare number means `issues/<NN>-*.md` of the feature being worked on; ask which feature when more than one has open tickets. Fetch a ticket by reading its file. Work is closed by setting its `Status:` line to `done`; a blocker is done when its file says so.
<!-- endif -->
<!-- if tracker=github -->
Tickets are GitHub issues; use `gh` from inside the clone. `gh issue view <number> --comments` fetches one; its epic is the issue it is a sub-issue of, or the `Part of #<n>` line in its body. Work is closed with `gh issue close <number>`; a blocker is done when its issue is closed.
<!-- endif -->
<!-- if tracker=gitlab -->
Tickets are GitLab issues; use `glab` from inside the clone. `glab issue view <number> --comments` fetches one; its epic is the issue its description links as the epic. Work is closed with `glab issue close <number>`; a blocker is done when its issue is closed.
<!-- endif -->
<!-- if tracker=other -->
<!-- fill: how to fetch a ticket and its epic, how to close one, and how to tell a blocker is done, naming the CLI or skill to use -->
<!-- endif -->
