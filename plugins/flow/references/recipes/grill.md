# grill

## Frontmatter

```yaml
name: grill
description: A relentless interview to sharpen a plan, a design or a ticket.
argument-hint: "[ticket]"
disable-model-invocation: true
```

Invocation mode: user-only.
The description is the one-line human description; it never changes.

## Varies by

- `domain`: off makes the first line "Call the Skill tool with grilling."; on makes it Matt Pocock's "Call the Skill tool twice, for grilling and domain-modeling." followed by one sentence naming where the glossary and ADRs live (the repo root in committed mode, `.claude/flow/domain/` otherwise, or the location the user chose) and telling domain-modeling to write there.
- `tracker`: the fetch step names the tracker recipe's `fetch` verb; the folder step names the tracker recipe's `ticket-folder` verb (for local, the reference is the ticket folder itself; otherwise the folder whose `ticket.md` stub names the remote issue); the write-back step names the tracker recipe's `comment` verb, including how it edits the ticket's own text (for local, an edit to `ticket.md` itself).

## Skill text

````markdown
{setup: when domain is off, "Call the Skill tool with grilling."; when on, "Call the Skill tool twice, for grilling and domain-modeling." and one sentence naming where the glossary and ADRs live, which domain-modeling writes to}

## With a ticket

When the user passes a ticket reference, grill the ticket instead of a fresh idea.

1. Fetch the ticket, its comments and its epic with {setup: the tracker recipe's `fetch` verb}.
   Read the epic's `spec.md` and anything already in the ticket folder: an earlier `grill.md` and the reviews.
2. Find the ticket folder, `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/`, by {setup: the tracker recipe's `ticket-folder` verb}.
   When it does not exist yet, create it the way that rule says.
3. Start the design tree from what the ticket leaves open: the seams, the acceptance criteria, the Touches line, the Verify line, and every word a builder would have to guess at.
4. When the frontier is empty and the user confirms the shared understanding, write `grill.md` into the ticket folder: each decision on one line with its reason, then every change the ticket needs.
5. Write the ticket changes back {setup: the tracker recipe's `comment` verb, including how it edits the ticket's own text: for local, an edit to the ticket folder's `ticket.md`}.
   Changed acceptance criteria, Touches and Verify lines go into the ticket itself; everything else stays in `grill.md`.
````

## Sibling files

None.

## Handoffs

Calls grilling, and domain-modeling when `domain` is on, with the Skill tool.
Names no next step.
