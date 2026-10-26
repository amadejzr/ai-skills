---
name: implement
description: "Implement one ticket test-first and hand it to review."
disable-model-invocation: true
---

# Implement

Implement the ticket the user passes: a ticket reference, a path to a local ticket file, or the ticket text itself.

## Process

1. **Fresh context.** If this conversation already holds grill, spec or ticket work, tell the user to `/clear` and rerun; the ticket is the whole brief.
2. **Fetch the ticket.** Call the Skill tool with "flow:config", then fetch the ticket as its tracker rules say and state its title.
   If the reference is ambiguous, ask.
   Read the parent spec (epic) the ticket names, the config's `## Navigation` pointers, and the glossary and ADRs that exist for the area you are touching.
   When a blocker of this ticket is not `done`, say so and stop; the user decides whether to proceed.
3. **Clean tree.** If `git status --porcelain` is not empty, stop and ask the user to commit or stash the previous work first: review must see this ticket's change alone.
   Record the base: `git rev-parse HEAD`.
   Set the ticket `Status: in-review` (local) or move it to in progress (tracker).
4. **Seams**: take the seams the spec's Testing Decisions agreed as confirmed. When the ticket needs a seam the spec did not foresee, propose it at the highest point you can and confirm with the user before writing any test.
5. **Build** by calling the Skill tool with "flow:tdd", passing the seams from step 4 as already confirmed.
   Every acceptance criterion maps to at least one test at an agreed seam, and every test goes red for the expected reason before the code that makes it green.
   Run typechecking regularly and single test files regularly.
6. **Prove it.** Run every command in the config's `## Checks` and quote each with the last line of its output. Do not go on while any is red.
   Tick the acceptance criteria on the ticket as each one is proven by a passing test: update the checkboxes on a local ticket file, or comment with the criteria met on a tracker.
7. **Review**: call the Skill tool with "flow:review" in `since` mode with the base from step 3, passing the ticket and epic references. Review and then `flow:fix` take over from here: findings, selection, fixes, re-review, checks, and closing the ticket.

Leave the work uncommitted. The user commits after review, or asks for a commit.
