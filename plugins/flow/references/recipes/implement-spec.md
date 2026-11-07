# implement-spec

Matt Pocock's implement-spec with four changes his notes ask for: the frontier counts a blocker done only when its branch has merged into the integration branch, tickets run in parallel only when their Touches do not overlap, the final review-fix loop stops after three rounds, and checkpoint pauses after each merge.
The orchestrator creates every worktree itself from the integration branch, so no implementer starts from the default branch.

## Frontmatter

```yaml
name: implement-spec
description: "Implement a whole epic through fresh implementer agents, one worktree per ticket."
argument-hint: "<epic>"
disable-model-invocation: true
```

Invocation mode: user-only.
The description is the one-line human description; it never changes.

## Varies by

- `tracker`: the `ticket-folder`, `fetch` and `close` verbs come from the chosen tracker recipe under `references/trackers/`, with `blocker-done` only as the fallback for a blocker finished before this run; write the repo's own way of doing each verb into its span.
  The tracker never decides the frontier.
- `worktrees`: `git` keeps the git dispatch paragraph in step 4 and deletes the herdr one; `herdr` keeps the herdr paragraph, which hands dispatch to the user's `orchestrate` skill, and deletes the git one.
  Setup offers herdr only when that skill exists.
- `location`: `committed` deletes the link step in step 4, since each worktree carries `.claude`; `private` and `external` keep it, linking the main checkout's `.claude` (or, when parts of `.claude` are tracked, each generated path from `.claude/flow/setup.md`) into every worktree so implementers read and write the main checkout's ticket folders.
- `checkpoint`: on keeps the pause after each merge in step 5; off deletes it.
- `commits`: agents always commit on their own branches, since merges need commits; the commit style (conventional by default), the ticket footer and the merge message from `workflow.md`'s `commits` node go into the implementer and merger texts.
  With user commits, step 8 leaves the integration branch for the user to push and does not open or ready a PR.
- `models`: `implementer` and `merger` go into the agent files' `model:` lines; `explorer` into step 2.
- Checks: the repo's check commands go into the merger text.
- Remote: when the repo opens PRs or MRs, the draft PR sentence in step 3 names this repo's draft command from the remote fact; with no PR host, it is deleted.
- The worktree directory: `.worktrees/` by default; setup adds it to `.gitignore` in committed mode or to the git exclude file otherwise, so `git check-ignore` passes.

## Skill text

````markdown
You have been provided an epic. The epic should have tickets associated with it, describing how to implement it.
The epic lives in `.claude/flow/<epic-slug>/spec.md` and each ticket in `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/`; fetch them {setup: the tracker recipe's `fetch` verb as this repo runs it, for the epic and each ticket, and its `ticket-folder` verb}.

The goal is the entire epic implemented on a single **integration branch**, with every ticket resolved the way the issue tracker closes work.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

A ticket is on the frontier when every ticket it is blocked by has its branch merged into the integration branch: `git merge-base --is-ancestor <blocker-branch> <integration-branch>` succeeds.
The tracker's state never counts for a blocker built in this run.
A blocker with no branch in this run was finished before it: it counts as done only when {setup: the tracker recipe's `blocker-done` verb} says so and its commits are already on the integration branch's base; otherwise ask the user rather than guess.

Two frontier tickets run in parallel only when their Touches lines do not overlap.
Paths overlap when they are equal, when one is a directory or glob containing the other, or when you cannot tell; the higher-numbered ticket then waits until the other has merged.

Start every subagent with a fresh context window.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the epic, tickets, research notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** are the `implementer` agent and should be run in the background where possible for maximum concurrency.
**Merger subagents** are the `merger` agent and run one at a time, in the foreground.

## Steps

1. Read the epic and tickets to understand the task graph, and the Touches line of each ticket.

2. (optional) Use an **exploration subagent** (the Agent tool, model `{setup: the explorer model}`) to conduct any exploration required by the tickets - relevant codebase files or external documentation. It saves its notes as `.claude/flow/<epic-slug>/research-<YYYY-MM-DD>-<slug>.md`, accessible by all future subagents, and pins the names (types, files, functions) that more than one ticket will create, so parallel tickets do not invent the same name twice. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create the integration branch `<epic-slug>` from the current branch and record its base: `git rev-parse HEAD`. {setup: when this repo opens PRs, "If the user asks for one, or the tracker closes work through PRs, open a draft PR after the first merge in step 5 (a branch with no commits ahead of the base can't open one), marked as closing the epic and tickets: <how this repo opens a draft PR>."; otherwise delete this sentence}

4. For each frontier ticket that may run now, create its worktree yourself from the integration branch tip:

   ```sh
   git worktree add .worktrees/<NN>-<ticket-slug> -b <epic-slug>-<NN>-<ticket-slug> <epic-slug>
   ```

   {setup: for private or external location, the link step, for example "Link the generated files into it: `ln -s \"$(git rev-parse --show-toplevel)/.claude\" .worktrees/<NN>-<ticket-slug>/.claude`."; for committed, delete this line}

   Dispatch one fresh **implementer subagent** per worktree with the Agent tool, `subagent_type` `implementer`, in the background, with pointers only: the worktree path, its branch, the integration branch, the ticket folder, the epic, and the research notes.

   {setup: for worktrees herdr, replace the dispatch paragraph above with: "Call the Skill tool with orchestrate to run one worker per worktree you created, each in that worktree, with `.claude/agents/implementer.md` as its brief and the same pointers. Do not let it create its own worktrees."}

5. Once an **implementer subagent** reports done, merge its branch into the integration branch with a **merger subagent** (the Agent tool, `subagent_type` `merger`, in the foreground, one at a time), with pointers to the branch, the integration branch, the ticket folder and the implementer's report.
   When the merger reports a conflict it could not resolve or a red check, stop and show the user.
   After each merge, stop, say in one line what landed, and wait for the user before going on.

6. If this changes the **frontier** of available tickets, or frees a ticket that waited on overlapping Touches, kick off more **implementer subagents** on the new tickets. This allows for maximum concurrency.

7. Once all tickets are merged, call the Skill tool with "review" since the integration branch's base, on the integration branch, passing the epic. It writes `.claude/flow/<epic-slug>/review-NN.md` and reads every declined finding under the epic's ticket folders.
   While that review's recommendation names a finding, run a round: dispatch one fresh **implementer subagent** in the main checkout on the integration branch, whose brief is to call the Skill tool with "fix" on that review file. Fix re-reviews its own commits and writes the next review file; read its recommendation for the next round.
   Stop after three rounds, because review never converges and a fourth round has cost more than a person reading the open findings. When findings are still open then, report every open finding (id, severity, file and the review file it is in) and stop; do not run a fourth round and do not close the tickets.

8. If a draft PR exists, mark it ready for review. Otherwise, close each ticket {setup: the tracker recipe's `close` verb as this repo runs it}, and report the integration branch.

9. Clean up every worktree you created (`git worktree remove .worktrees/<NN>-<ticket-slug>`) and its merged branch.
````

## Sibling files

These are not under the skill's folder: setup writes them as `.claude/agents/implementer.md` and `.claude/agents/merger.md`.

### .claude/agents/implementer.md

````markdown
---
name: implementer
description: Implements one ticket of an epic in the worktree it is given, test-first at agreed seams, or fixes the findings of a review file it is given. Dispatched by implement-spec with context pointers.
model: {setup: the implementer model}
tools: Read, Edit, Write, Grep, Glob, Bash, Skill, Agent
---

You implement one ticket of an epic in the worktree and on the branch the dispatch names, or you fix one review's findings when the dispatch names a review file.
The epic, the ticket folder and the research notes come as context pointers; read them before any code.

For a ticket:

1. Confirm the worktree's branch is based on the integration branch tip (`git merge-base --is-ancestor <integration-branch> HEAD`), and reset onto it if not.
2. Read `ticket.md`, `grill.md` when it exists, the epic's `spec.md` and the research notes the dispatch names.
3. Call the Skill tool with "tdd" to build the ticket at the seams the epic agreed. Do not invent a seam the epic did not agree; report it as a blocker instead.
4. Run typechecking regularly, single test files regularly, and the full test suite once at the end.
5. Commit on your branch: one conventional commit per completed red-green cycle, `<type>(<scope>): <what changed>`, {setup: the ticket footer form this repo uses}.
6. Merge the integration branch tip into your branch before reporting done, and run the full suite again after the merge.
7. Report in under 200 words: the tests you added and what they prove, the acceptance criteria met, and anything left unfinished and why.

For a review file: call the Skill tool with "fix" on it, in the main checkout on the integration branch, and report what fix reported.

Never touch a file outside the ticket's Touches without saying so in the report.
````

### .claude/agents/merger.md

````markdown
---
name: merger
description: Merges one ticket branch into the integration branch and proves the checks. Dispatched by implement-spec after an implementer reports done.
model: {setup: the merger model}
tools: Read, Edit, Grep, Glob, Bash
---

You merge one ticket branch into the integration branch in the main checkout; the dispatch names both branches, the ticket folder and the implementer's report.

1. Check out the integration branch and confirm the tree is clean.
2. Merge the ticket branch with `git merge --no-ff <ticket-branch> -m "{setup: the merge message form, for example 'merge: <NN> <ticket title>'}"`.
3. On a conflict, resolve it only when the ticket and the epic make the right side clear; otherwise abort the merge (`git merge --abort`) and report the conflicting files.
4. Run every check and quote each command with the last line of its output:

{setup: the repo's check commands, one per line in a code block}

5. When a check is red, report it with its output and leave the merge commit in place; do not fix code.
6. Report in under 100 words: the merge commit, the check results, and any conflict you resolved and how.
````

## Handoffs

- Calls: `review` (Skill tool) for the whole-branch review; the `implementer` and `merger` agents (Agent tool); `orchestrate` (Skill tool) only when the worktree engine is herdr.
  Its implementer calls `tdd` for a ticket and `fix` for a review file.
- Names next: nothing; it ends with the integration branch or the open findings after the third round.
- Called by: the user only.
