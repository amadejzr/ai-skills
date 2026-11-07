# tickets

## Frontmatter

```yaml
name: tickets
description: Break the epic into tracer-bullet tickets and publish them.
argument-hint: "[epic]"
disable-model-invocation: true
```

Invocation mode: user-only.
The description is the one-line human description; it never changes.

## Varies by

- `domain`: on makes the vocabulary sentence name where the glossary and ADRs live; off makes it "Ticket titles and descriptions should use the vocabulary of the spec and the code."
- `tracker`: the fetch sentence names the tracker recipe's `fetch` verb; the publish step names the tracker recipe's `ticket-folder` verb (for local, the ticket itself; otherwise a stub naming the remote issue), its `publish-ticket` verb with how it carries the blocking edges and the parent link, and its `mark-ready` verb; it also says which template lines the tracker carries natively and drops (a remote parent link replaces the Spec line, a label replaces the Status line).
- `templates`: `template.md` is the ticket template the user chose; the default is the text under Sibling files, and a change keeps the Blocked by, Touches, Verify and Acceptance criteria sections, since implement, implement-spec and review read them.

## Skill text

````markdown
# Tickets

Break the epic (the spec from spec), a plan, or the conversation into a set of **tickets**: tracer-bullet vertical slices, each declaring the tickets that **block** it.
Each ticket is sized for one implement run in a fresh context window.

## Process

### 1. Gather context

Work from whatever is already in the conversation context.
If the user passes a reference (an epic slug, a spec path, an issue number or URL) as an argument, read `.claude/flow/<epic-slug>/spec.md`, or fetch it with {setup: the tracker recipe's `fetch` verb}, and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.
{setup: when domain is on, "Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching; both live in <their location>."; when off, "Ticket titles and descriptions should use the vocabulary of the spec and the code."}

Look for opportunities to prefactor the code to make the implementation easier.
"Make the change easy, then make the easy change."

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

Give each ticket its **Touches**: the areas it changes, at the grain of a directory, module or glob.
Two tickets whose Touches overlap never run in parallel, so when two tickets would create or rename the same thing, either pin the name in both or add a blocking edge between them.

Give each ticket its **Verify**: the command or test that proves the ticket works, runnable as written.

Write each acceptance criterion as **when-then**: "When <a trigger the user or a test can cause>, then <an outcome they can observe>."

**Wide refactors are the exception to vertical slicing.**
A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green.
Don't force it into a tracer bullet; sequence it as **expand-contract**.
First expand: add the new form beside the old so nothing breaks.
Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists.
Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch.
When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket; green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list.
For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **Touches**: the areas it changes
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct: does each ticket only depend on tickets that genuinely gate it?
- Do any two tickets that could run in parallel touch the same area?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.

### 5. Publish the tickets

Every ticket's body is [template.md](template.md) filled in: every section the template has, in its order, and no other.
Number the tickets from `01` in dependency order (blockers first), and publish them in that order, so each ticket's blocking edges can name real identifiers.

For each ticket:

1. Create its folder, `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/`, and write `ticket.md` into it following {setup: the tracker recipe's `ticket-folder` verb: for local, the filled template; otherwise a stub naming the remote issue, written once the issue exists}.
2. {setup: the tracker recipe's `publish-ticket` verb, naming how it sets the parent link to the epic and the blocking edges, and which template lines it drops because the tracker carries them natively}.
3. {setup: the tracker recipe's `mark-ready` verb}.

One ticket per folder, never a single combined file.
Leave the epic open and its body unchanged.

Avoid specific file paths or code snippets in a ticket body: they go stale fast.
Touches names areas, not single files, unless the ticket is about one file.
Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype.
Trim to the decision-rich parts, not a working demo, just the important bits.
````

## Sibling files

### template.md

{setup: the ticket template the user chose; the default is the text below, unchanged}

````markdown
# <NN>: <Ticket title>

## Spec

The epic this ticket belongs to.

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective, not a layer-by-layer implementation list.

## Blocked by

The tickets that gate this one, or "None (can start immediately)".

## Touches

The areas this ticket changes: directories, modules or globs.

## Verify

The command or test that proves this ticket works, runnable as written.

## Status

ready-for-agent

## Acceptance criteria

- [ ] When <trigger>, then <observable outcome>.
- [ ] When <trigger>, then <observable outcome>.
````

## Handoffs

Calls no skill.
Names no next step.
