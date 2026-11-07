# Improvements setup proposes

After exploring, `/flow:setup` walks this list, keeps the items whose detection matches the repo, and proposes each with its evidence and its cost effect.
The user accepts or declines each; both land in the setup record's `## Improvements`, so a re-run does not propose a declined item again unless the evidence changed.
An accepted item that changes a file the repo owns (outside the generated paths) is shown as a diff before it is written, and is never committed.

Each item says how to detect it, what to propose, and its cost effect: what it saves or costs per ticket.

## Guardrails

### No automated checks before merge

- Detect: no CI config (`.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/`, `azure-pipelines.yml`) runs the test or lint command, and no pre-commit hook (`.husky/`, `.pre-commit-config.yaml`, `lefthook.yml`, `.git/hooks/pre-commit`) runs them.
- Propose: a pre-commit hook or a CI job running the checks, in the tool the repo already uses.
- Cost effect: a red check found by a reviewer or the user costs a review round; found by the hook it costs one command.

### Check commands the flow cannot run

- Detect: no test, typecheck, lint or build command explore could find, or a command that fails on the default branch when run once.
- Propose: name the command or fix the failing one before the first ticket.
- Cost effect: without a green baseline every implementer spends turns deciding whether a failure is its own.

### No type or lint check on a typed stack

- Detect: TypeScript without `tsc --noEmit` in any script, Python with type hints but no `mypy` or `pyright` config, no linter config for the main language.
- Propose: wire the existing tool into a script the checks can call.
- Cost effect: mechanical findings move from opus reviewers to a free command.

### Mechanical rules written as prose

- Detect: lines in standards docs or the instruction file that a linter rule could enforce (import order, banned APIs, file naming, a fixed pattern).
- Propose: the lint rule, and remove the prose line once the rule exists.
- Cost effect: every reviewer that carries standards reads fewer lines, and the rule never misses.

### Secrets and generated files reachable by agents

- Detect: `.env` files tracked or not ignored, large generated or vendored directories not in `.gitignore`, no `permissions.deny` for secrets in `.claude/settings.json`.
- Propose: ignore lines and a deny rule for secret files.
- Cost effect: fewer tokens spent reading generated code, and no secret pasted into a context.

## Instruction files

### Instruction file bloat

- Detect: `CLAUDE.md` or `AGENTS.md` over about 200 lines or 10 KB, or sections that summarise the codebase, restate the README, or describe what any agent could read from the code.
- Propose: cut it to gotchas, commands and pointers; move path-specific rules into `.claude/rules/` with a `paths:` filter.
- Cost effect: the file is loaded into every session and every dispatched agent; each KB removed saves that KB on every context.

### Duplicated or conflicting instruction files

- Detect: both `CLAUDE.md` and `AGENTS.md` with overlapping content, or nested instruction files contradicting the root one.
- Propose: one source, the other a one-line pointer or symlink.
- Cost effect: removes a whole file from every context and a class of contradictory behaviour.

### Missing navigation pointers

- Detect: a monorepo or a codebase over a few hundred files with no instruction-file lines pointing at where the main parts live.
- Propose: a handful of pointer lines (where the domain lives, where the tests live, the one hidden coupling).
- Cost effect: explorers find the right files in fewer turns on every ticket.

### Old flow instructions left behind

- Detect: an `## Agent skills` block or flow pointers in `CLAUDE.md` or `AGENTS.md`, `docs/agents/`, `.scratch/` tickets, or a `.scratch/reviews/` ignore line from earlier designs.
- Propose: remove the stale lines after the new flow is generated; list the old specs and tickets for the user to move by hand.
- Cost effect: removes instructions that point agents at files that no longer drive anything.

## Models and roles

### Expensive models on mechanical roles

- Detect: any existing agent, reviewer or setup answer running the merger, explorer or verifier on `opus`.
- Propose: `sonnet` for the merger and explorers, `haiku` for verification and other mechanical work.
- Cost effect: these roles run most often; each step down roughly divides their cost by three to five with no loss on the judgement roles.

### Reviewers that run on every change

- Detect: reviewers whose `paths` is the whole repo and whose condition is always, beyond `spec` and `correctness`.
- Propose: narrow `paths` and give each a condition, so a one-line fix does not pay for a full review.
- Cost effect: a small change runs one or two reviewers instead of all of them.

### One model family reviewing its own work

- Detect: every reviewer runs on Claude and a `codex`, `opencode` or `gemini` CLI is on `PATH`.
- Propose: one correctness reviewer on that CLI through its runner script.
- Cost effect: one extra reviewer per review, paid on another account, catches what one model family misses.

## Tooling

### Token-expensive tools always loaded

- Detect: MCP servers in `.mcp.json` or the user's settings that the flow never needs for this repo, or tools whose output dumps whole files or pages.
- Propose: disable them for this project or scope them to the skills that need them.
- Cost effect: every tool definition is paid in every context; unused ones are pure overhead.

### Slow or noisy checks

- Detect: the full test suite takes minutes when one package or file could be tested, or a check prints thousands of lines on success.
- Propose: a scoped test command per package and a quiet flag, written into the checks.
- Cost effect: each implementer cycle runs faster and reads less output.

### Worktrees that break on ignored files

- Detect: tests that read gitignored fixtures, `.env` files or build outputs that a fresh worktree will not have.
- Propose: a `.worktreeinclude` or a worktree setup command in the implement-spec skill.
- Cost effect: parallel implementers stop failing on missing files they cannot see.
