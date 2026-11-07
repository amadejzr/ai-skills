# flow

## Frontmatter

```yaml
name: flow
description: Map of this repo's flow and the command to run next.
disable-model-invocation: true
```

Invocation mode: user-only.
The description is the one-line human description; it never changes.

## Varies by

- `domain`: on adds the glossary and ADRs to what step 1 leaves behind, with their location; off leaves the row as written without them.
- `tracker`: the ticket-status sentence names the tracker recipe's `fetch` verb, and the step 2 and 3 rows name where the tracker recipe's `publish-epic` and `publish-ticket` verbs put the epic and the tickets (for local, only the files under `.claude/flow`).
- `worktrees`: the implement-spec row names git worktrees under the ignored worktree directory, or Herdr panes driven by the user's `orchestrate` skill.
- `checkpoint`: on adds the sentence that implement and fix stop before every commit and implement-spec pauses after every merge; off drops it.
- `commits`: user commits changes the implement row to say the work is left uncommitted for the user; agent commits keep "commits per green cycle".
- `reviewers`: the review row names the reviewers by name, comma separated, as the set review selects from.

## Skill text

````markdown
# Flow

One setup, then the same loop per epic.
Everything the flow writes lives under `.claude/flow`: one folder per epic, and inside it one folder per ticket.

| step | command | what it leaves behind |
| --- | --- | --- |
| 1 | `/grill` or `/grill <ticket>` | a shared understanding{setup: when domain is on, ", glossary terms and ADRs in <their location>"}; with a ticket, `grill.md` in its ticket folder |
| 2 | `/spec` | `.claude/flow/<epic-slug>/spec.md`, seams agreed, builder-checked and approved; {setup: where the tracker recipe's `publish-epic` verb puts the epic} |
| 3 | `/tickets` | tracer-bullet tickets with blocking edges, Touches, Verify and when-then criteria, one folder each at `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/`; {setup: where the tracker recipe's `publish-ticket` verb puts the tickets} |
| 4, per ticket | `/implement <ticket>` | tests and code at agreed seams, checks green, {setup: "a commit per green cycle" or "the work left uncommitted for you"}, then a review |
| 4, whole epic | `/implement-spec <epic>` | every ticket built by a fresh implementer in {setup: "a git worktree" or "a Herdr pane through your orchestrate skill"} and merged into the integration branch |
| 5 | `/review [since <ref> \| staged \| working \| codebase] [reviewer ...]` | `review-NN.md` in the ticket folder, the epic folder for a whole branch, or `.claude/flow/codebase/`; reviewers: {setup: the reviewer names}; applies nothing |
| 6 | `/fix <ticket> [ids \| all]` | the recommended findings fixed, re-reviewed, each marked fixed or declined in the review file, the ticket closed when no must-fix remains |
| 7, per epic | `/review since <merge-base>`, then `/fix`, then `/pr` | the whole-branch review, which reads every declined finding under the epic's tickets, then the PR body |
| any time | `/research <question>` | a cited note at `.claude/flow/<epic-slug>/research-<date>-<slug>.md` |
| when something slipped | `/retro` | edits to reviewer files, standards, checks or navigation pointers |
| to change the flow | `/flow:setup` | a diff per generated file; your edits win |

Keep steps 1 to 3 in one context window.
Start every `/implement` in a fresh one (`/clear`).
For a bug, reproduce it end to end first, then write the ticket and run `/implement` on it.
{setup: when checkpoint is on, "Implement and fix stop before every commit; implement-spec pauses after every merge."; otherwise nothing}

## Where you are

Read `.claude/flow` for the work in hand, newest epic folder first.
A ticket's status comes from {setup: the tracker recipe's `fetch` verb}.

- No epic folder for this work: step 1.
- A `spec.md` and no ticket folders: step 3.
- A ticket not closed with no review since its last commit: step 4 for that ticket.
- A latest `review-NN.md` with an open must-fix: step 6 for that ticket.
- Every ticket closed: step 7.

Name the current step and the command to run next, then stop.
````

## Sibling files

None.

## Handoffs

Calls no skill.
Names the next command, which is the whole job of this skill; it runs nothing.
