# Explore

Read what is there; assume nothing.
Run the git and session checks yourself; dispatch the codebase reading to 2 or 3 Explore agents in parallel on `sonnet`, each with a fresh context and one group below, each returning facts with the file path that proves them, never file contents.
Wait for all of them before step 3; the summary needs every finding.

## Earlier flow in this repo

Run these first; they decide whether this is a first run.

- `.claude/flow/setup.md`, following a symlink: a setup record from this design.
  Note its plugin version.
- `.claude/flow/settings` and `.claude/flow/generated`: the generator design.
  `settings` holds `key=value` lines (`mode`, `scope`, `pacing`, `commits`, `gate`, `stops`, `tracker`, `domain`, `reviewers`, `implementer_model`, `builder_model`, `research_model`, `research_agents`); `generated` lists the paths it wrote.
- `.flow` at the repo root, a directory or a symlink (usually into `~/.flow/<repo-key>`): the 0.2.2 design, with `config.md` (tracker, domain docs, standards map, standards notes, checks, navigation), `reviewers/<name>.md`, `features/`, `domain/` and `reviews/`.
- Existing `.claude/skills/<name>/` and `.claude/agents/<name>.md` whose names collide with the generated ones in `workflow.md`, and whether each is tracked (`git ls-files .claude`), excluded (`$(git rev-parse --git-common-dir)/info/exclude`), or a symlink.
- Leftovers of earlier designs: `docs/agents/`, `.scratch/`, an `## Agent skills` block in `CLAUDE.md` or `AGENTS.md`.

## Git and remote

- `git remote -v`: GitHub, GitLab, another host, or none; derive the repo-key as `workflow.md` defines it.
- `gh --version` and `gh auth status`, or `glab --version` and `glab auth status`, for the matching host; native blocked-by edges on GitHub need gh 2.94 or later.
- Whether the tracker is in use: `gh issue list --limit 5` or `glab issue list --per-page 5`.
- `git log --oneline -30`: the commit style, and whether at least half follows one convention.
- `git worktree list`, and whether `.worktrees/` is ignored (`git check-ignore -q .worktrees/x`).
- The default branch: `git symbolic-ref --short refs/remotes/origin/HEAD`, else the current branch.

## Session

- The available skills listed in this session: a tracker skill (`jira`, `linear`, or the like), and whether an `orchestrate` skill exists, which decides whether the `herdr` worktree engine is offered at all.
- External review CLIs on `PATH`: `command -v codex opencode gemini claude`.
- `.mcp.json` and the project's `.claude/settings.json`: MCP servers, hooks, permission rules.

## Stack and risk surface (Explore agent)

- Languages, frameworks and build tools from manifests (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle*`, `*.csproj`, `Package.swift`, `Gemfile`, `composer.json`), and which directories each lives in.
- Kind of software: web server, web app, mobile app, CLI, library, infrastructure.
- Risk surface: user input handling, auth and sessions, payments, database access and migrations, file uploads, secrets, crypto, public API contracts, dependency manifests.
- Monorepo signals: `pnpm-workspace.yaml`, a `workspaces` field, `packages/*` or `apps/*` each with its own source, `go.work`, a Cargo workspace, a `.sln` with several projects; list the packages and their stacks.
- Size: rough file count of source and tests.

## Checks and guardrails (Explore agent)

- Test, typecheck, lint and build commands from the manifests' scripts, `Makefile`, `justfile`, `Taskfile.yml` and CI config; per package in a monorepo.
- CI config and what it runs; pre-commit hooks (`.husky/`, `.pre-commit-config.yaml`, `lefthook.yml`).
- Linter and type-checker configs.
- Tests that depend on gitignored files (`.env`, fixtures, build outputs).
- `.gitignore` coverage of `.env`, generated and vendored directories.

## Docs (Explore agent)

- Standards docs: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `STYLEGUIDE.md`, `ARCHITECTURE.md`, `docs/**/standards*`, `docs/**/conventions*`, and the same names inside each package; for each, the paths it governs.
- Instruction files: `CLAUDE.md`, `AGENTS.md`, nested ones, `.claude/rules/`; their sizes in bytes and lines, and sections that summarise the codebase or duplicate each other.
- Domain docs: `GLOSSARY.md`, `CONTEXT.md`, `GLOSSARY-MAP.md`, `docs/adr/`, `docs/decisions/`.
- A PR or MR template: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`, `.gitlab/merge_request_templates/`.
- Spec or ticket conventions already in use: `docs/specs/`, `specs/`, `rfcs/`.
- Docs directories or sibling repos the code refers to, as candidate research sources.

## Done

Write the findings down in your own working notes as one line each with the proving path or command.
Every bullet above has a finding or "not found".
