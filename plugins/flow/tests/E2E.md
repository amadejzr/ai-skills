# End-to-end run

Run this before each release, after `bash plugins/flow/tests/references.test.sh` passes.
The structural test proves the shape of the references; this run proves that setup composes good skills from them and that the generated loop works.

## Automated part

`tests/e2e.sh` builds a sample TypeScript repo (thirty conventional commits, a GitHub remote, a `CONTRIBUTING.md` standard, a PR template, test and lint commands), runs `/flow:setup` headless on it with the answers given up front, and grades the result: every always-path from the "What every repo gets" table, the verify commands of generate.md, the setup record's sections and plugin version, the invocation flags of every skill, the reviewer frontmatter, and the mode-specific answers.

```bash
bash plugins/flow/tests/e2e.sh run recommended   # the one-line offer taken: committed, github
bash plugins/flow/tests/e2e.sh run grilled       # the offer declined: private, local, domain on, user commits, checkpoint off, sonnet implementer, Checklist dropped, a custom reviewer
```

Each run costs about nine dollars, 140 turns and twenty minutes, and runs setup with every permission bypassed inside the throwaway directory, which is why it is a script you run on purpose and not a test that runs on every change.
Read the step 6 report it prints as well as the grades: the grades prove the shape, the report shows whether explore and the improvements made sense.
`e2e.sh grade <mode> <repo>` grades a repo you ran setup on by hand.

`claude plugin eval` cannot carry this suite: non-interactive sessions refuse writes under `.claude/` and `.git/`, and `git` does not run inside the eval sandbox on macOS.

## Manual part

Tick every box below, and fix any file that looks off, however small, before releasing.
The recommended-set and grilled paths are covered by the script above when its grades pass and its reports read well; walk them by hand only after a change to interview.md or explore.md.

## Preparation

- [ ] Bump `version` in `plugins/flow/.claude-plugin/plugin.json`.
- [ ] Make a sample repo: a small TypeScript or Python project with a test command, a lint command, a GitHub-style remote, about thirty commits in one convention, a `CONTRIBUTING.md` that states a coding standard, and a `.github/PULL_REQUEST_TEMPLATE.md`.
- [ ] Copy the sample repo three times, one per location mode, so each run starts clean.
- [ ] Start each run with `claude --plugin-dir <this checkout>/plugins/flow` from the sample repo's root.

## Recommended-set path

- [ ] `/flow:setup` explores without asking anything a read could answer, and its summary names the stack, risk surface, remote, commit style, checks, the standards doc, the PR template and the CLIs found.
- [ ] Every improvement it proposes has evidence and a cost effect, and is marked recommended or not.
- [ ] Accepting the one-line offer states the significant choices one line each, then writes files without another question.
- [ ] Every path in the "What every repo gets" table of `references/workflow.md` that applies exists, and `.claude/flow/setup.md` has the five sections in the order the build contract gives.
- [ ] The commands in the "Verify" section of `skills/setup/generate.md` print nothing.
- [ ] Each generated SKILL.md reads like a finished skill: no `{setup:` span, no `${CLAUDE_PLUGIN_ROOT}`, the repo's check commands and tracker written in, bare-name calls, one sentence per line, no em dashes.
- [ ] The user-only skills carry `disable-model-invocation: true`; review, fix, pr and research do not.
- [ ] `/flow` names the current step and the next command, then stops.

## Grilled path

- [ ] Declining the offer starts the rounds; each round asks the whole frontier, each question with a recommendation that "yes" accepts.
- [ ] A later round asks only what the earlier answers unblocked, following the Waits for lines of `workflow.md`.
- [ ] Asking for a custom reviewer runs the add-a-reviewer round and writes a reviewer file in the shape of `references/reviewers/README.md`.
- [ ] Nothing is written before the frontier is empty and you confirm.
- [ ] The generated files reflect every non-default answer: tracker, checkpoint off, user commits, a non-default model, a dropped template section.

## Location modes

- [ ] `committed`: `git status --porcelain` lists the generated paths, and `.worktrees/` is ignored through `.gitignore`.
- [ ] `private`: `git status --porcelain` lists none of the generated paths; the git exclude file lists them and `.worktrees/`.
- [ ] `external`: the files live in the directory you named, each skill directory, agent file and the flow directory is a symlink under `.claude/`, Claude Code lists the linked skills, and `git status --porcelain` lists none of them.
- [ ] In `private` or `external` mode, `/implement-spec` on a two-ticket epic links the main checkout's `.claude` into each worktree, and the implementers write into the main checkout's ticket folders.

## Re-run

- [ ] Edit one generated skill by hand, then run `/flow:setup` again and change one decision.
- [ ] Setup recommends the recorded answers, asks only what to change, and shows a diff per affected file rather than regenerating anything.
- [ ] Your hand edit survives unless you accept losing it.
- [ ] `.claude/flow/setup.md` records the new answer and the current plugin version.

## The loop

- [ ] `/grill` an idea, `/spec` it, `/tickets` it; the epic and tickets land in `.claude/flow/<epic>/` and `<epic>/<NN>-<ticket>/` with Touches, Verify and when-then criteria.
- [ ] `/implement` the first ticket: tests first at the agreed seams, the checks run, one commit per green cycle in the repo's convention, then review runs.
- [ ] Review says which reviewers it chose and why, writes `review-01.md` into the ticket folder with ids, severity, confidence, file, fix and a recommendation, applies nothing, and ends with the `/fix` hint.

## External runner

- [ ] With `codex`, `opencode`, `gemini` or `claude` on `PATH`, add a reviewer with that `runner`; setup copies only that script into `.claude/skills/review/runners/`.
- [ ] A review runs it in the background and its findings appear in the review file in the contract's shape.
- [ ] With the CLI's credentials removed, the review reports `failed: <name> (<message>)`, never a clean review.

## Fix from pasted findings

- [ ] Paste two findings from another tool into `/fix <ticket>`; fix writes them as a new numbered review file under the ticket before changing code.
- [ ] Fix applies them test-first where behaviour changes, one commit per finding or group, stopping before each commit when checkpoint is on.
- [ ] Fix re-runs only the reviewers whose findings it touched, on the fix commits alone, marks each finding fixed with its commit or declined with a reason, and closes the ticket when no must-fix remains.

## Earlier designs

- [ ] On a repo set up by the generator design (`.claude/flow/settings`) or the 0.2.2 design, setup reports what it found, recommends from its answers, and names the specs, tickets and reviews left to move by hand.
