---
name: tickets
description: "Break the epic (spec) or the current conversation into tracer-bullet tickets in this repo's ticket template, with blocking edges, published to the tracker as children of the epic."
disable-model-invocation: true
---

# Tickets

Break the epic (the spec from `/spec`), a plan, or the conversation into a set of **tickets**: tracer-bullet vertical slices, each declaring the tickets that **block** it.
Each ticket is sized for one `/implement` run in a fresh context window.

## Process

### 1. Gather context

Work from whatever is already in the conversation context.
If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.
Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges**: the other tickets that must complete before it can start.
A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green.
Don't force it into a tracer bullet; sequence it as **expand–contract**.
First expand: add the new form beside the old so nothing breaks.
Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists.
Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch.
When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket; green is promised only there.

<!-- if stops~tickets -->
### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct: does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.
<!-- else -->
### 4. State the breakdown

Present the breakdown as a numbered list, each ticket with its title, its blockers and the end-to-end behaviour it delivers, then publish without waiting.
<!-- endif -->

### 5. Publish the tickets to the tracker

Every ticket's body is [template.md](template.md) filled in: every section the template has, in its order, and no other.
Publish in dependency order (blockers first), so each ticket's blocking edges can name real identifiers.
<!-- if tracker=local -->
Write one file per ticket under `{{flow_dir}}/features/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`.
The template's blocked-by line names the numbers and titles it depends on; its spec line names the epic's path; its status line starts at `ready-for-agent`.
One ticket per file, never a single combined file.
<!-- endif -->
<!-- if tracker=github -->
One issue per ticket: `gh issue create --title "..." --body "..."` with a heredoc for the body, and `--parent <epic>` so it is a sub-issue of the epic (older `gh`: `gh issue edit <epic> --add-sub-issue <child>`, or `Part of #<epic>` at the top of the body when sub-issues are unavailable).
Drop the template's spec line when the parent link carries it.
Keep the template's blocked-by line, naming the blocking issue numbers.
Label each issue `ready-for-agent` in place of the status line.
<!-- endif -->
<!-- if tracker=gitlab -->
One issue per ticket: `glab issue create --title "..." --description "..."` with a heredoc for the description, and `Part of #<epic>` at the top of the description as the parent link.
Drop the template's spec line when the parent link carries it.
Keep the template's blocked-by line, naming the blocking issue numbers.
Label each issue `ready-for-agent` in place of the status line.
<!-- endif -->
<!-- if tracker=other -->
<!-- fill: how to publish one ticket as a child of the epic on this repo's tracker, how to express a blocking edge, and how to mark it ready-for-agent -->
<!-- endif -->

Leave the epic open and its body unchanged.

Avoid specific file paths or code snippets in a ticket: they go stale fast.
Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype.
Trim to the decision-rich parts, not a working demo, just the important bits.

