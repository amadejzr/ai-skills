# Tracker: local

Epics and tickets for this repo live as markdown files in the flow directory.

## Conventions

- One feature per directory: `<dir>/features/<feature-slug>/`
- The epic is `<dir>/features/<feature-slug>/spec.md`
- Tickets are one file each at `<dir>/features/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never one combined file
- State is a `Status:` line near the top of each ticket: `ready-for-agent`, `in-review`, `done`
- Comments append at the bottom of the file under `## Comments`

## When a skill says "publish to the issue tracker"

Create the file under `<dir>/features/<feature-slug>/`, creating directories as needed.

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path.
A bare number means `issues/<NN>-*.md` of the feature being worked on; ask which feature when more than one has open tickets.

## When a skill says "close the ticket"

Set `Status: done` and append the criteria met and the review file path under `## Comments`.
