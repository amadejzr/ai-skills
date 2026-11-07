# Tracker: local

Epics and tickets live as markdown files in the flow directory, `.claude/flow/`, and nowhere else.
Setup writes the text of each verb below into the tracker span of the skill that needs it, with this repo's paths filled in; a generated skill never links this file.

## Layout

- One epic per folder: `.claude/flow/<epic-slug>/`.
- The epic is `.claude/flow/<epic-slug>/spec.md`.
- One folder per ticket: `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/`, numbered from `01` in publish order.
- The ticket is `ticket.md` in its folder, the ticket template filled in.
- State is the ticket's `## Status` section: `ready-for-agent`, `in-progress`, `in-review`, `done`.
- Blocking edges are the ticket's `## Blocked by` section: one line per blocker naming its folder (`02-auth-session`), or `None (can start immediately).`
- The epic link is the folder the ticket sits in; the template's spec line is dropped.
- Comments append under a `## Comments` heading at the bottom of the file, each starting with the date and who wrote it.

## ticket-folder

The ticket folder holds the ticket itself: `ticket.md` is the ticket, and `grill.md` and `review-NN.md` sit next to it.

## publish-epic

Write the approved spec to `.claude/flow/<epic-slug>/spec.md`, creating the folder; the file is the epic, so nothing else is recorded at its top.
The epic slug is a short kebab-case name for the epic; when the folder already exists, ask before reusing it.

## publish-ticket

Publish in dependency order, blockers first, so every edge names a folder that exists.
For each ticket, create `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/` with the next free number and write the filled template to `ticket.md` in it.
Its `## Blocked by` section names each blocker's folder, one per line.
Never write several tickets into one file.

## fetch

A ticket reference is a folder path, a `ticket.md` path, or `<NN>` (the ticket folder starting with that number under the epic being worked on; ask which epic when more than one has tickets not `done`).
Read `ticket.md` in full, including `## Comments`, then read the epic: `spec.md` in the parent folder.
Read `grill.md` and the latest `review-NN.md` in the ticket folder when they exist.

## mark-ready

Set the `## Status` section to `ready-for-agent`.
A new ticket starts there, so publish-ticket already did it.

## comment

Append under `## Comments` at the bottom of `ticket.md` (or `spec.md` for the epic), creating the heading when missing: `- <YYYY-MM-DD> <author>: <text>`, with longer text as an indented block under the line.
To change the ticket itself, as grill does with what it settled, edit its sections in place and add a comment saying what changed.

## close

Append a comment listing the acceptance criteria met and the review file path, then set `## Status` to `done`.

## blocker-done

A blocker is done when its `ticket.md` says `done` under `## Status`.
A ticket is ready to start when every folder in its `## Blocked by` section is done.
Implement-spec ignores this and counts a blocker as done only when its branch has merged into the integration branch.

## fetch-review-comments

A local tracker has no PR of its own; review comments come from wherever the repo opens PRs.
When the remote is GitHub, use the fetch-review-comments verb of `github.md`; when it is GitLab, the one of `gitlab.md`; otherwise the user pastes the comments and fix normalises them into a review file in the ticket folder.
