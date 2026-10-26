---
name: flow
description: "Map of the flow skills and the order to run them. Read when unsure which flow skill comes next."
disable-model-invocation: true
---

# Flow

One repo, one setup, then the same loop per feature.
Everything the flow owns for a repo lives in its flow directory, `.flow`: local (outside the repo, linked in) or committed with the repo; `flow:config` resolves it.

| step | skill | what it leaves behind |
| --- | --- | --- |
| once per repo | `/flow:setup` | the flow directory: `config.md` and the reviewer files you define; nothing runs without it |
| any time | `/flow:add-reviewer` | one reviewer file in `reviewers/`, new or changed |
| 1 | `/flow:grill` | shared understanding; glossary terms and ADRs in the flow directory's `domain/` when `Domain docs` is on, otherwise carried by the spec |
| 2 | `/flow:spec` | the epic on the tracker, builder-checked and approved |
| 3 | `/flow:tickets` | tracer-bullet tickets with blocking edges, children of the epic |
| 4, per ticket | `/flow:implement <ticket>` | tests and code at agreed seams, checks green, uncommitted, then hands to review |
| 5, per ticket | `flow:review` (called by implement; by hand: `/flow:review since <ref> \| <fixed-point> \| staged \| working [reviewer ...]`) | the review file in the flow directory's `reviews/`, chosen fixes applied and re-reviewed, checks quoted, ticket `done` |
| 6, per epic | `/flow:review <merge-base>` | the whole-branch review after the last ticket; reads `## Deferred` from the ticket reviews |
| when a PR is opened | `flow:pr` | the PR body |
| after a ticket or branch, when something slipped | `/flow:retro` | edits to reviewer files, standards notes, checks or navigation pointers |
| every week or two | `/flow:upstream` | ported upstream improvements, baseline in `upstream/` moved forward |

Keep steps 1 to 3 in one context window.
Start every `/flow:implement` in a fresh one (`/clear`).
For a bug, reproduce it end to end first, then write the ticket and run `/flow:implement` on it.

Model-invoked helpers the steps call on their own: `flow:config`, `flow:grilling`, `flow:domain-modeling`, `flow:tdd`, `flow:review`, `flow:pr`.
Reviewers are the files in the flow directory's `reviewers/`, one per reviewer; add one with `/flow:add-reviewer` or by writing the file. Review runs them all unless you name some.

Name the current step and the command to run next, then stop.
