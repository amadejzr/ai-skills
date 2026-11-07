# Flow setup: one skill, references, agent-composed per-repo flow

## Problem Statement

The `flow` plugin's single entry point does too much and does it rigidly.
It interviews in two fixed rounds, then a bash template engine composes directive-laden templates from flags, and the agent fills markers afterwards.
Every behaviour a repo might want has to be a flag and an `<!-- if -->` branch, so the generator grows with every idea and still cannot express a tracker, a location, a reviewer runner or a model it did not foresee.
The per-repo result cannot easily be a Svelte standards reviewer on one directory, a codex reviewer on another, tickets in Jira with a local spec, or skills kept outside the repository entirely.
Review findings are applied inside the review itself, so there is no way to hand findings from a colleague or another tool to the same fixing process.
Findings, grill notes and tickets are scattered rather than kept together per ticket.

## Solution

The plugin ships exactly one user-invoked skill, `/flow:setup`, and a tree of reference files.
Setup explores the repo, proposes cost and flow improvements, offers a recommended set in one line, and otherwise grills the user in rounds over a workflow design tree.
Then the agent itself writes every generated file for that repo from the recipes, the reviewer catalogue, the tracker recipes and the answers.
There is no template engine and no runtime config.
What a repo gets is its own spec-first, test-first loop as project skills and agents: grill, spec, tickets, implement, implement-spec, review, fix, pr, research, retro, a map, and one agent per reviewer.
Everything about a ticket lives in one folder: the ticket, its grill notes and its numbered reviews with fix outcomes.
Every file is the repo's own afterwards, edited like code, and a re-run of setup diffs per file.

## User Stories

1. As a developer starting on a repo, I want to run one command, `/flow:setup`, so that the whole engineering loop is installed for that repo without learning the plugin's internals.
2. As a developer, I want setup to explore the repo first (remote, commit style, stack, standards docs, checks, monorepo signals, existing flow files), so that it never asks me what it could read.
3. As a developer, I want setup to summarise what it found and propose improvements (missing guardrails, cheaper models for mechanical roles, unwired checks, bloated instruction files), so that each setup also makes the repo cheaper and safer to work in.
4. As a developer in a hurry, I want to accept the recommended set in one line, so that setup takes a minute when the defaults fit.
5. As a developer who cares, I want setup to grill me in rounds with a recommended answer per question, worded so that "yes" accepts it, so that every decision is mine without being tedious.
6. As a developer, I want to choose where the generated files live: committed in the repo, private through the git exclude file, or in an external directory linked in, so that I can use the flow on repos I do not own.
7. As a developer, I want to describe how this repo tracks work in my own words, with worked recipes for local files, GitHub and GitLab, so that any tracker or hybrid (spec local, tickets remote) works without the plugin knowing it.
8. As a developer, I want to decide whether grill keeps a glossary and ADRs, so that domain language is kept where the repo wants it.
9. As a developer, I want setup to detect my commit style and default to conventional commits, so that agent commits read like a senior engineer's.
10. As a developer, I want to choose whether implement stops before every commit, so that I can read each diff or let it run.
11. As a developer, I want to choose the worktree engine for implement-spec, plain git worktrees by default or Herdr panes, so that parallel agents run the way my machine is set up.
12. As a developer, I want setup to propose reviewers from the repo's stack and risk surface and let me add my own, each with its paths, condition, inputs, model and runner, so that review is specific to this repo.
13. As a developer, I want a reviewer to be runnable on an external CLI (codex, opencode, gemini, headless claude) through a script shipped into the repo, so that a different model family can review my code.
14. As a developer, I want to set a model per role (implementer, merger, explorer, verifier, builder check, research, each reviewer), so that cost matches the job.
15. As a developer, I want setup to leave a prose record of my answers, the improvements I accepted and the generated paths, so that a re-run knows what to recommend and what to diff.
16. As a developer re-running setup, I want a diff per generated file where my edits win by default, so that improvements arrive without losing my changes.
17. As a developer with an idea or a ticket, I want `/grill` to interview me relentlessly over a design tree and, when I pass a ticket, write the result back into the ticket, so that implementation starts from a shared understanding.
18. As a developer, I want `/spec` to turn the grilled conversation into an epic in the repo's template, seams agreed first, builder-checked, approved, and published to the tracker, so that the epic is complete before tickets exist.
19. As a developer, I want `/tickets` to break the epic into tracer-bullet tickets with blocking edges, a Touches line, a Verify line and when-then acceptance criteria, published as children of the epic, so that each ticket can be built in a fresh context and scheduled safely in parallel.
20. As a developer, I want `/implement <ticket>` to do exactly what Matt Pocock's implement does: fetch the ticket, build test-first at agreed seams, run checks, commit, then call review, so that implement stays pure and predictable.
21. As a developer, I want `/implement-spec <epic>` to run the whole epic through fresh implementer agents in worktrees from the frontier, with a merger landing each one, so that I can let an epic run on its own.
22. As a developer, I want implement-spec to count a blocker as done when its branch has merged into the integration branch, so that the frontier does not depend on tracker state.
23. As a developer, I want implement-spec to run two tickets in parallel only when their Touches do not overlap, so that agents do not collide on shared files.
24. As a developer, I want the final review-fix loop in implement-spec capped at three rounds, after which it reports every open finding and stops, so that it never runs for hours.
25. As a developer, I want implement-spec to pause after each merge when checkpoint is on, so that I can read what landed.
26. As a developer, I want `/review` to pick reviewers by their paths and conditions, say which it chose and why, and run them in fresh contexts in parallel, so that a one-line fix does not pay for a full review.
27. As a developer, I want to name the reviewers to run, so that I can run just the security reviewer on a branch.
28. As a developer, I want to review a range since a ref, the staged change, the working tree, or the whole codebase, so that review fits where I am.
29. As a developer, I want each must-fix finding verified by a fresh agent before it reaches me, so that I never act on a wrong must-fix.
30. As a developer, I want review to write its findings, each with an id, severity, confidence, file and fix, into the ticket's folder as a numbered review with a recommendation of which to fix, and then stop, so that findings are a file I can read, share and act on later.
31. As a developer, I want `/fix <ticket>` to apply the recommendation from the latest review, or the ids I name, or all, so that fixing is one command.
32. As a developer, I want `/fix` to accept pasted findings, a review file path, or a PR reference whose review comments it fetches, normalising them into the same review shape, so that a colleague's review goes through the same door.
33. As a developer, I want fix to work like implement: pure, in the current context, test-first where behaviour changes, one conventional commit per finding or group, checkpoint when on, so that fixes are as careful as features.
34. As a developer, I want fix to re-run only the reviewers whose findings it touched, on the fix commits alone, run the checks, mark each finding fixed or declined in the review file, and close the ticket when no must-fix remains, so that the loop closes itself.
35. As a developer, I want the whole-branch review before a PR to read every declined finding under the epic's tickets, so that nothing deferred is forgotten.
36. As a developer, I want `/pr` to write the PR body from the epic, tickets, evidence and reviews, merged with the repo's own PR template, so that PRs are consistent.
37. As a developer, I want `/research` to run background agents over the sources this repo trusts first and leave a cited note in the epic's folder, so that specs and tickets point at facts.
38. As a developer, I want `/retro` on request to turn what slipped into a check, a standards line, a reviewer rule or a navigation pointer, and review to end with a one-line retro candidate when it noticed one, so that the environment improves without an automatic step after every ticket.
39. As a developer, I want a tiny `/flow` map skill in the repo that names the step I am at and the next command, so that I never have to remember the loop.
40. As a developer, I want the security reviewer to carry the categories, exclusions and false-positive filter of Anthropic's public security-review prompt reworded for this stack, so that it reviews any range as well as the built-in does on the merge-base.
41. As a developer in a monorepo, I want one flow at the root with reviewers scoped by paths and per-package check commands, so that I do not maintain several flows.
42. As the plugin maintainer, I want every skill and reference under 20,000 bytes with step material in reference files, so that compaction never truncates a rule.
43. As the plugin maintainer, I want the verbatim upstream skills checked byte for byte against their baseline, so that ports are deliberate.
44. As the plugin maintainer, I want structural tests and a documented manual end-to-end run before each release, so that an agent-composed generator stays trustworthy.
45. As the plugin maintainer, I want the generator, its script and its tests removed and the docs rewritten, so that the repo describes only what exists.

## Implementation Decisions

### Plugin surface

- The plugin ships one user-invoked skill, `setup` (`/flow:setup`), with `disable-model-invocation: true`.
- Upstream porting becomes a maintainer script in this repo, run from the checkout, no longer a plugin skill. The upstream baselines directory stays.
- The plugin ships no agents; reviewers, the implementer and the merger are generated into each repo.
- `plugin.json` carries a pinned `version` bumped per release.
- The opencode installer from the previous design is dropped; the generated files are Claude Code project files.
- Upstream porting: the fetch-and-diff script stays under the plugin's scripts, and the judgement step (read the diffs, port what is worth porting, accept the baseline) becomes a project skill in this checkout's own `.claude/skills/`, so the plugin still ships one skill. Ported changes reach repos when setup is re-run. (My call.)

### Invocation modes of the generated skills

- Typed by the user only (`disable-model-invocation: true`): flow, grill, spec, tickets, implement, implement-spec, retro.
- Model-invoked and also typed by the user (no flag, trigger-rich description): review, fix, pr, research. This keeps Matt Pocock's rule that a user-only skill never calls another user-only skill: implement and implement-spec call review, implement-spec's final fix runs through an implementer calling fix, and fix calls review for its re-review. (My call.)

### References tree

The plugin's `references/` directory is what setup reads; nothing in it is executed at run time in a repo.

- `workflow.md`: the design tree setup grills from. Each node is a decision with its options, its default, its recommendation rule and which generated files it shapes.
- `principles.md`: the rules every generated file obeys: under 20,000 bytes per skill with step material in reference files; every dispatched agent starts with a fresh context window; communication through context pointers, never pasted summaries; descriptions say only when to use, never the process; a user-invoked skill never calls another user-invoked skill; dependencies written as "Call the Skill tool with X"; standards are enforced at review, not at implementation; no comments, no narrative.
- `improvements.md`: the checklist setup proposes from after exploring: missing guardrails, unwired checks, instruction-file bloat, model cost per role, token-expensive tooling.
- `verbatim/`: grilling, tdd (with tests and mocking references), domain-modeling (with its format files), copied byte for byte.
- `recipes/<skill>.md`: one per generated skill: its purpose, what varies by setup answers, the template it carries, and the handoffs. Skills: flow, grill, spec, tickets, implement, implement-spec, review, fix, pr, research, retro.
- `reviewers/`: the reviewer contract (severity, confidence, output shape, declined-to-judge), the reviewer file shape, the generic reviewer agent, and the catalogue: spec, correctness, security, tests, standards, and stack reviewers setup adapts by language and framework.
- `trackers/`: recipes for local, github, gitlab, and the shape any other tracker is described in: publish epic, publish ticket under it with blocking edges, fetch, mark ready, close, tell when a blocker is done, fetch PR or MR review comments.
- `runners/`: the scripts for codex, opencode, gemini and headless claude, copied into the repo's review skill, plus the dispatch shape for a Claude agent through the Agent tool.

### Setup process

1. Explore: existing setup record, remote, commit style from history, stack and risk surface, standards docs, check commands, PR template, domain docs, monorepo signals, tracker skills available in the session.
2. Summarise and propose improvements from `improvements.md`, each with its cost effect; the user accepts or declines each.
3. Offer the recommended set in one line; on acceptance, state the significant choices one line each and generate.
4. Otherwise grill in rounds from `workflow.md` with the grilling discipline: the frontier each round, a recommendation per question worded so "yes" accepts it, facts found by sub-agents, decisions by the user.
5. Generate: write every file from the recipes and the answers; copy verbatim files and runner scripts; create the flow directory; write the setup record; apply the location mode.
6. Report the generated paths, the loop in one line, and that `/grill` starts it.

Re-run: the setup record is the recommendation, the questions are what to change, and the result is a diff per generated file; the user's edits win by default.
Because composition is not deterministic, a re-run never regenerates a file from scratch: it reads the existing file, the recipe and the changed answers, and proposes edits only where an answer or a recipe changed, shown as a diff the user accepts per file. No pristine copies are kept; the setup record names the plugin version it was generated with so the re-run knows which recipes moved. (My call.)

Explore also recognises the files of the two earlier designs (a generator settings file with its generated list, or a 0.2.2 flow directory with its config, reviewers and tickets), reports them, and reuses their answers as the recommendation; moving their specs, tickets and reviews into the per-ticket folders is a manual step the user does afterwards.

### Decisions setup collects

- Location: `committed` (under `.claude/` in git), `private` (`.claude/` paths listed in the git exclude file), `external` (files in a directory the user names, each skill directory, agent file and the whole flow directory linked into `.claude/` with the links excluded; project skill entries may be symlinks).
- Worktrees in `private` and `external` modes: the generated files are not in git, so implement-spec links the main checkout's `.claude` into every worktree it creates, and implementers read and write the ticket folders of the main checkout through that link. In `committed` mode the worktree carries them. (My call.)
- Tracker: described in prose; shipped recipes for local, GitHub (native blocked-by edges and sub-issues) and GitLab; hybrids allowed.
- Domain docs: off or on; when on, glossary and ADRs at the repo root in committed mode, in the flow directory otherwise, and the grill skill tells domain-modeling where.
- Commit style: detected, default conventional commits, one commit per completed red-green cycle, written by the agent; user-commits optional.
- Checkpoint: on or off; implement and fix stop before each commit, implement-spec pauses after each merge.
- Worktree engine: git worktrees under an ignored directory by default, Herdr panes on request. With Herdr, the implement-spec recipe hands worker dispatch to the user's own `orchestrate` skill instead of describing Herdr's interface; setup checks that the skill exists before offering the engine. (My call.)
- Reviewers: the proposed set and the user's own, each with model, paths, condition, inputs and runner.
- Models per role: implementer and reviewers `opus`, merger and explorer `sonnet`, verification and mechanical work `haiku`, builder check `opus`, research `opus`; any reviewer may be an external CLI.
- Research sources the repo trusts first.
- Templates: spec, ticket and PR shapes, merged with the repo's own PR template.

### Generated layout per repo

- `.claude/skills/<name>/` for flow, grill, grilling, domain-modeling (when on), spec, tickets, implement, implement-spec, tdd, review, fix, pr, research, retro.
- `.claude/skills/review/reviewers/<name>.md` per reviewer; `.claude/agents/reviewer.md` (one generic read-only reviewer agent), `implementer.md` and `merger.md`.
- `.claude/flow/setup.md`: the setup record.
- `.claude/flow/<epic-slug>/spec.md`, research notes, and `review-NN.md` for whole-branch reviews.
- `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/ticket.md` (the ticket when local, a stub naming the remote issue otherwise), `grill.md` when grilled, `review-NN.md` numbered per review with fix outcomes written back.
- `.claude/flow/codebase/review-NN.md` for whole-codebase reviews.
- The review skill carries the runner scripts and the reviewer contract as its reference files.

### Generated skills

- `flow`: names the current step and the next command, then stops.
- `grill`: calls grilling and, when domain docs are on, domain-modeling; with a ticket argument it fetches the ticket, grills it, and writes the result back the tracker's way and into the ticket folder.
- `spec`: Matt Pocock's to-spec with seams agreed first, the builder check, approval, and publishing through the tracker recipe.
- `tickets`: Matt Pocock's to-tickets; each ticket adds Touches (areas changed), Verify (the command or test that proves it) and when-then acceptance criteria; published in dependency order with blocking edges.
- `implement`: Matt Pocock's implement: fetch the ticket, tdd at agreed seams, checks, commit per cycle (checkpoint when on), then call review; a clean review closes the ticket.
- `implement-spec`: Matt Pocock's implement-spec with four changes: the frontier counts a blocker done when its branch has merged into the integration branch; tickets run in parallel only when their Touches do not overlap; the final review-fix loop is capped at three rounds then reports and stops; checkpoint pauses after each merge. Worktrees are created by the orchestrator from the integration branch; a fresh implementer per ticket, a merger per landing, one fresh implementer running fix for the final findings.
- `review`: resolve the range (since a ref, staged, working tree, codebase); find the ticket and epic; select reviewers by paths and conditions and say why, or take the named set; dispatch each fresh and in parallel (Claude agents through the Agent tool, external runners through their scripts) with the diff, the contract, its file and its inputs; verify each must-fix finding with a fresh agent; write the numbered review into the ticket folder with ids, severity, confidence, file, fix and a recommendation; end with the path, the `/fix` hint and a one-line retro candidate when one was noticed. Applies nothing.
- `fix`: resolve the findings (latest review of the ticket, a review file, a PR whose comments it fetches, or pasted text normalised into a new review file under the ticket); select the recommendation, the named ids or all; work like implement on each; re-run the raising reviewers on the fix commits; run checks; mark each finding fixed with its commit or declined with a reason; close the ticket when no must-fix remains.
- `pr`: the PR body from epic, tickets, evidence and reviews, in the merged template.
- `research`: background agents over trusted sources, a cited note in the epic folder.
- `retro`: Matt Pocock's retro over the generated files: mechanical mistakes become checks, judgement calls become standards or reviewer rules, navigation becomes pointers.

### Reviewers

- A reviewer is one file under the review skill's `reviewers/` directory with frontmatter `model`, `paths`, `inputs`, `condition`, `runner`; the body is the reviewer's focus, numbered rules and skips, reworded for the repo. The file name without `.md` is the reviewer's name in finding ids.
- Claude reviewers run through one generic read-only `reviewer` agent in the repo's agents directory, dispatched per reviewer with the model from its file, the contract, its body and its inputs; external reviewers run through their runner script, where `model` is the CLI's own model name. (Decided after the builder check.)
- The contract fixes severities must-fix, worth-doing, optional; confidence 0 to 100 with a reporting threshold; the finding block shape; the declined-to-judge list.
- The security reviewer carries the categories, hard exclusions, trust assumptions and the per-finding false-positive filter of Anthropic's public security-review prompt; the review skill names the built-in `/security-review` as the one-shot merge-base alternative.
- External runners receive the diff as a file, the reviewer file and the contract, run read-only, and return the same markdown contract.

### Repository changes

- Delete the generator directory, its script and its test.
- Rewrite the plugin README and the repo CLAUDE.md for the new shape; update credits for the new sources (Anthropic security-review prompt, pr-review-toolkit reviewer shapes, superpowers size rule).
- Add the structural test script.

## Testing Decisions

A good test checks external behaviour at a seam the user can observe, not how a file is written.
For a plugin made of markdown and a few scripts, the observable behaviour is the shape of the shipped tree and what setup produces on a real repo.

Agreed seams:

1. The structural test script over the plugin tree (the one automated seam). It checks: every skill, recipe and reference under 20,000 bytes; every file under `verbatim/` byte-identical to its upstream baseline; every recipe, tracker and runner named in `workflow.md` exists; every runner script passes a shell syntax check; `claude plugin validate` is clean. It catches a truncated or drifted reference and a broken manifest. It misses whether setup composes good skills.
2. A documented manual end-to-end run of `/flow:setup` on a sample repo before each release, with a checklist: the recommended-set path, the grilled path, each location mode, a re-run diff, one review with an external runner, one fix from pasted findings. It catches what the structural test misses. It is not automated.

Modules tested: the references tree and the plugin manifest by seam 1; setup, review and fix by seam 2.
Prior art: the existing generator test script in this repo, which runs the real templates and fails on any unresolved directive; its sandbox and `fail`/`check` helpers are the shape to keep.

## Out of Scope

- A deterministic outer loop for unattended work (ralph-style); implement-spec runs inside one session.
- Hooks that enforce a step (a review after every commit); the loop is driven by skills the user runs.
- Nested flows per package in a monorepo.
- Support for agents other than Claude Code reading the generated skills.
- Automatic retro after every ticket.
- A native `isolation: worktree` implementer; it branches from the default branch, not the integration branch.
- Changing the verbatim upstream skills.

## Further Notes

- The research behind the design, with sources, is published next to this spec as the epic's research note (`research-2026-11-03.md`); `principles.md`, the reviewer catalogue and the runner scripts are written from it.
- Matt Pocock's documented implement-spec problems (no stop rule, tracker-based frontier, name collisions in parallel tickets) are the reason for the four implement-spec changes.
- The superpowers 20,000-byte rule comes from compaction truncating re-attached skills at that size; Claude Code never re-reads a skill body on later turns, so the critical rules go at the top of each skill.
- The installed 0.2.2 plugin's reviewer contract and add-reviewer round are the starting text for the reviewer references.
