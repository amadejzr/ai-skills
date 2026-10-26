# Flow config: <repo-key>

Read by the flow skills through `flow:config`. Edit by hand at any time; `/flow:setup` rebuilds it on request.
The reviewers are not here: each one is a file in `reviewers/` next to this one.

- Repo: <repo-source>
- Tracker: local
- Domain docs: off
- Selection: chat

## Tracker notes

Only for `Tracker: other`: one paragraph on how to publish an epic, publish a ticket, fetch a ticket and close it, naming the skill or CLI to use.

## Standards map

Which of the repo's own docs apply to which paths. Most specific row first, the catch-all last. The flow reads these docs and never edits them.

| paths | standards |
| --- | --- |
| ** | |

## Standards notes

Your rules for this repo, passed with the mapped docs to every reviewer that takes `standards`. Judgement calls only; mechanical rules belong in the repo's linter.

- none yet

## Checks

| check | command | notes |
| --- | --- | --- |
| test | `npm test` | |
| typecheck | `npm run typecheck` | |
| lint | `npm run lint` | |
| build | `npm run build` | omit when the repo has no build |

## Navigation

Pointers for the implementer: where things live, hidden couplings, files to read first. Filled by `/flow:retro`.

- none yet
