---
name: setup
description: "Set up the flow for this repo: where its flow directory lives (local or git), tracker, domain docs, the reviewers you define, standards, checks. Run once per repo, again to change it or switch modes."
disable-model-invocation: true
---

# Setup

Create the repo's flow directory: `config.md` and one file per reviewer, in the mode the user picks.
Everything the flow owns for this repo ends up there; nothing it owns stays anywhere else.

Call the Skill tool with "flow:config" for the layout, the two modes and the meaning of each section and reviewer field.
When the flow directory already exists this is a re-run: the result is a diff against what is there, not a fresh start.

## Process

### 1. Explore

Read what is there; don't assume:

- `"${CLAUDE_PLUGIN_ROOT}/scripts/flow-config.sh"`: an existing flow directory and its mode, its `config.md` and `reviewers/`.
- `git remote -v`: GitHub, GitLab, something else, or no remote.
- Monorepo signals: `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, `packages/*` or `apps/*` each with its own `src/`, `go.work`, a Cargo workspace, a `.sln` with several projects.
- Domain docs: a committed `GLOSSARY.md`, `GLOSSARY-MAP.md` or `docs/adr/` is the repo's own and stays; untracked or git-excluded ones (`git ls-files`, `.git/info/exclude`) are flow material to move.
- Standards docs: every file that says how code should be written. `CONTRIBUTING.md`, `CODING_STANDARDS.md`, `STYLEGUIDE.md`, `ARCHITECTURE.md`, `docs/**/standards*`, `docs/**/conventions*`, `CLAUDE.md`, `AGENTS.md`, and in a monorepo the same names inside each package. Lint, format and type configs are tooling-enforced and reviewers skip them, so they are not standards docs.
- Check commands: the scripts in `package.json`, `Makefile`, `pyproject.toml`, `Cargo.toml`, CI config. Find test, typecheck, lint and build.
- Flow material outside the flow directory: a `## Reviewers` table in an existing `config.md`, reviewer rules those rows point at (for example under `.claude/skills/*/reviewers/`), `docs/agents/`, tickets under `.scratch/`, a `.scratch/reviews/` line in `.gitignore`, an `## Agent skills` block in `CLAUDE.md` or `AGENTS.md`.
- Is a tracker skill (for example `jira`) available in this session? It shapes the `other` tracker answer.

### 2. Ask one round

Summarise what you found.
Then ask every decision as one numbered round, each with your recommended answer, worded so "yes" accepts all of them:

1. **Mode.** Recommend `local`: the directory outside the repo, a git-excluded `.flow` symlink in the repo. `git` commits `.flow/` with the repo and is only for when the user wants it shared. On a re-run, a different answer switches modes.
2. **Tracker.** Recommend `local` always: specs and tickets as files in the flow directory. Name `github`, `gitlab` and `other` as the alternatives only; `other` takes one paragraph from the user on how to publish, fetch and close, naming the tracker skill when one is available.
3. **Domain docs.** `off` unless glossary or ADR files already exist; then `single`, or `multi` when a `GLOSSARY-MAP.md` exists or monorepo signals suggest separate contexts. Whatever the setting, the flow writes them only into the flow directory's `domain/`.
4. **Reviewers.** Nothing is built in and you recommend none: ask which reviewers the user wants. For each: a name, what it looks at and how, its rules, what it skips, `paths`, `inputs`, and `model` (`opus` unless the user names another). Reviewers found in step 1 are listed with what they currently say; rules that pointed at files now missing are named as lost, for the user to rewrite. On a re-run, list the existing files and ask what to add, change or remove.
5. **Standards map.** From the exploration: one row per path scope, most specific first, the catch-all last, each listing the repo's existing docs. In a monorepo, one row per package with its own doc; the rest fall through to the catch-all. No doc anywhere → an empty catch-all.
6. **Standards notes.** Conventions you observed in the code that no doc states and the user wants enforced: short, judgement calls only. Recommend `none yet` when nothing stands out.
7. **Checks.** The commands you found; name the ones you could not find so the user supplies them.
8. **Move in.** When flow material was found outside the flow directory: reviewer rules into the reviewer files, untracked glossary and ADRs into `domain/` (and their `.git/info/exclude` lines removed), `.scratch/` tickets into `features/` or deleted, `docs/agents/`, the `.scratch/reviews/` ignore line and the old `## Agent skills` block removed.

Selection mode defaults to `chat`; write it without asking.

### 3. Confirm

Show the draft `config.md` and every reviewer file in full.
Let the user edit before writing.

### 4. Write

- New: `"${CLAUDE_PLUGIN_ROOT}/scripts/flow-config.sh" --init <mode>` creates the directory, the scaffolded `config.md`, `reviewers/`, and the symlink and exclude line (local) or `.flow/.gitignore` (git).
- Re-run with a new mode: `"${CLAUDE_PLUGIN_ROOT}/scripts/flow-config.sh" --switch <mode>` moves the directory and fixes the link.

Then write the confirmed `config.md` and reviewer files, delete reviewer files the user removed, and apply the accepted moves.
Never commit; in git mode, tell the user `.flow/` is ready to commit.

### 5. Done

Tell the user the flow directory, its mode, the reviewer files, that they can edit any of them by hand at any time or add and change reviewers with `/flow:add-reviewer`, and that `spec`, `tickets`, `implement` and `review` now read them.
