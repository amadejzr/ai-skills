---
name: setup
description: "Set up this repo's spec-first, test-first flow as its own skills and agents under .claude/. Run once per repo, again to change anything."
disable-model-invocation: true
---

# Setup

Explore the repo, propose improvements, settle the workflow decisions with the user, then write the repo's own flow: project skills, agents, reviewer files and a setup record.
You compose every file yourself from the plugin's references; there is no template engine and nothing reads a config at run time.

## Rules that hold at every step

- Never commit, push or open anything remote; leave every change in the working tree for the user.
- Facts are yours to find, decisions are the user's; never ask what a read or a command can answer, never decide what the user has not accepted.
- Every generated file comes from a recipe, the reviewer references or a verbatim file under `${CLAUDE_PLUGIN_ROOT}/references/`, obeys `${CLAUDE_PLUGIN_ROOT}/references/principles.md`, stays under 20,000 bytes, and contains no `{setup:` span and no `${CLAUDE_PLUGIN_ROOT}`.
- Verbatim files are copied byte for byte with `cp`, never retyped.
- When a permission denial stops a copy or a write, stop and tell the user what to approve; never retype a verbatim file and never stage files outside the target to get around it.
- On a re-run you never regenerate a file from scratch: you edit it in place, show a diff per file, and the user's own edits win unless they accept otherwise.
- Do not write any file until the user has accepted the recommended set or the grilling has reached an empty frontier and they confirm it.

## References

All plugin references live under `${CLAUDE_PLUGIN_ROOT}/references/`:

- `workflow.md`: the design tree, one node per decision, and the table of every generated path and its source; read it in step 1.
- `principles.md`: the rules every generated file obeys; read it before step 5.
- `improvements.md`: the checklist of improvements; read it in step 3.
- `recipes/<skill>.md`: one per generated skill: flow, grill, spec, tickets, implement, implement-spec, review, fix, pr, research, retro.
- `reviewers/README.md`: the reviewer file shape, the generic reviewer agent, how review dispatches, and the add-a-reviewer round.
- `reviewers/CONTRACT.md`: the reviewer contract, copied into the repo.
- `reviewers/catalogue/<name>.md` and `reviewers/catalogue/stacks/<stack>.md`: reviewers to adapt.
- `trackers/local.md`, `github.md`, `gitlab.md`, `other.md`: how each tracker publishes, fetches, closes and reads review comments.
- `runners/README.md` and `runners/<cli>.sh`: external reviewer runners, copied into the repo when used.
- `verbatim/grilling/`, `verbatim/tdd/`, `verbatim/domain-modeling/`: copied byte for byte.

Step material lives next to this file; read each at the step that names it, and read it again if your context was compacted since.

## Process

### 1. Explore

Read [explore.md](./explore.md) and do what it says.
Also read `${CLAUDE_PLUGIN_ROOT}/references/workflow.md` now.
Done when every item in explore.md has a finding or an explicit "not found", and you know whether this is a first run, a re-run, or a run over an earlier design.

### 2. Re-run or earlier design

When explore found a setup record (`.claude/flow/setup.md`) or the files of the generator or 0.2.2 designs, read [rerun.md](./rerun.md) now.
It turns what exists into the recommendation for steps 3 and 4, and replaces step 5's writing with edits in place.

### 3. Summarise, propose improvements, offer the recommended set

Read [interview.md](./interview.md), sections "Summary", "Improvements" and "The one-line offer", and send one message that:

1. Summarises what explore found in a few lines: stack and risk surface, remote and tracker signals, commit style, checks, standards docs, PR template, domain docs, monorepo shape, CLIs and skills found, and any earlier flow.
2. Lists each applicable improvement from `${CLAUDE_PLUGIN_ROOT}/references/improvements.md` with its evidence and cost effect, numbered, each marked recommended or not.
3. Offers the recommended set in one line.

When the user takes the offer, state the significant choices one line each and go to step 5.
Done when the user has answered the offer and every improvement is accepted or declined.

### 4. Grill in rounds

Read [interview.md](./interview.md), section "Grilling", and run the rounds over the nodes of `workflow.md`.
Each round asks the whole frontier, each question with your recommended answer from the node's Recommend rule and what explore found.
Read the section again before every round.
For custom reviewers, read `${CLAUDE_PLUGIN_ROOT}/references/reviewers/README.md` and run its add-a-reviewer round.
Done when the frontier is empty, nothing is left assumed, and the user confirms the shared understanding.

### 5. Generate

Read [generate.md](./generate.md) and `${CLAUDE_PLUGIN_ROOT}/references/principles.md`, then write every file from the answers.
On a re-run, follow rerun.md's "Edits in place" instead of writing fresh files.
Done when every path in the "What every repo gets" table of `workflow.md` that applies exists, the checks in generate.md's "Verify" section pass, the location mode is applied and `.claude/flow/setup.md` is written.

### 6. Report

Tell the user, briefly:

- every generated path, grouped as skills, agents, reviewers, runners and the flow directory;
- the location mode and what it means for them (ready to commit, excluded, or linked from the external directory);
- the improvements applied and the ones left for them;
- the loop in one line: `/grill` an idea, `/spec`, `/tickets`, `/implement` or `/implement-spec`, review and `/fix`, `/pr`, `/retro` on request; `/flow` tells them where they are;
- that every file is theirs to edit, and that `/flow:setup` again changes any decision with a diff per file;
- for an earlier design, the specs, tickets and reviews they still need to move by hand into the per-ticket folders.
