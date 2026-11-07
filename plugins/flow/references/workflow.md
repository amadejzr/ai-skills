# Workflow design tree

This is the tree `/flow:setup` grills from and composes from.
Each node is one decision: its options, its default, the rule that turns what explore found into a recommendation, the decisions it waits for, and the recipes and files it shapes.
The decision names are fixed; recipes, the setup record and the structural test use exactly these.
Paths below are relative to `${CLAUDE_PLUGIN_ROOT}/references/`.

## The loop a repo gets

`/grill` an idea or a ticket, `/spec` the epic, `/tickets` to break it down, `/implement` one ticket or `/implement-spec` the whole epic, `review` and `fix` until clean, `/pr`, and `/retro` on request.
`/flow` names the step the user is at and the next command.

## What every repo gets

| generated path | source | when |
| --- | --- | --- |
| `.claude/skills/flow/` | `recipes/flow.md` | always |
| `.claude/skills/grill/` | `recipes/grill.md` | always |
| `.claude/skills/grilling/` | `verbatim/grilling/` | always |
| `.claude/skills/domain-modeling/` | `verbatim/domain-modeling/` | `domain` is on |
| `.claude/skills/spec/` | `recipes/spec.md` | always |
| `.claude/skills/spec/template.md`, `builder-check.md` | sibling files of `recipes/spec.md` | always |
| `.claude/skills/tickets/` | `recipes/tickets.md` | always |
| `.claude/skills/tickets/template.md` | sibling file of `recipes/tickets.md` | always |
| `.claude/skills/implement/` | `recipes/implement.md` | always |
| `.claude/skills/implement-spec/` | `recipes/implement-spec.md` | always |
| `.claude/skills/tdd/` | `verbatim/tdd/` | always |
| `.claude/skills/review/` | `recipes/review.md` | always |
| `.claude/skills/review/CONTRACT.md` | `reviewers/CONTRACT.md` | always, copied |
| `.claude/skills/review/REVIEW-FORMAT.md` | sibling file of `recipes/review.md` | always |
| `.claude/skills/review/reviewers/<name>.md` | `reviewers/catalogue/<name>.md`, `reviewers/catalogue/stacks/<stack>.md`, or the add-a-reviewer round | one per chosen reviewer, adapted |
| `.claude/skills/review/runners/<runner>.sh` | `runners/<runner>.sh` | only when a chosen reviewer has that `runner`, copied |
| `.claude/skills/fix/` | `recipes/fix.md` | always |
| `.claude/skills/pr/` | `recipes/pr.md` | always |
| `.claude/skills/pr/template.md`, `CREDITS.md` | sibling files of `recipes/pr.md` | always |
| `.claude/skills/research/` | `recipes/research.md` | always |
| `.claude/skills/retro/` | `recipes/retro.md` | always |
| `.claude/agents/reviewer.md` | the generic reviewer agent in `reviewers/README.md` | always |
| `.claude/agents/implementer.md`, `merger.md` | sibling files of `recipes/implement-spec.md` | always |
| `.claude/flow/setup.md` | the setup record | always |

The recipes are `recipes/flow.md`, `recipes/grill.md`, `recipes/spec.md`, `recipes/tickets.md`, `recipes/implement.md`, `recipes/implement-spec.md`, `recipes/review.md`, `recipes/fix.md`, `recipes/pr.md`, `recipes/research.md` and `recipes/retro.md`.
The trackers are `trackers/local.md`, `trackers/github.md`, `trackers/gitlab.md` and `trackers/other.md`.
The runners are `runners/codex.sh`, `runners/opencode.sh`, `runners/gemini.sh` and `runners/claude.sh`, described in `runners/README.md`.
The reviewer catalogue is `reviewers/catalogue/spec.md`, `correctness.md`, `security.md`, `tests.md`, `standards.md` and the stack reviewers under `reviewers/catalogue/stacks/`.

## Facts the recipes also need

These are found by explore and confirmed in the summary, not grilled; the user corrects them when they are wrong.

- **checks**: the test, typecheck, lint and build commands, per package in a monorepo, and where they already run (pre-commit hooks, CI workflows).
  A check explore could not find is asked as a question in the first round.
- **standards**: the repo's own docs that say how code is written, with the paths each governs.
- **stack**: languages, frameworks and the risk surface (user input, auth, payments, a database, secrets, public APIs).
- **remote**: GitHub, GitLab, another host or none, and the `gh` or `glab` version when present.
  When the remote takes PRs or MRs, how a draft one is opened from a branch (`gh pr create --draft`, `glab mr create --draft`); with none, the repo opens no PRs and implement-spec's draft PR sentence is deleted.
- **repo-key**: the origin remote as `<host>-<path>` with every `/` and `:` replaced by `-`, or the directory name without a remote.

## Decisions

### location

- Options: `committed` (files under `.claude/`, left for the repo to commit), `private` (files under `.claude/`, every generated path listed in the git exclude file), `external` (files in a directory the user names, each skill directory, agent file and the flow directory symlinked into `.claude/`, the links excluded).
- Default: `private`.
- Recommend: `committed` when `git ls-files .claude` already lists skills or agents, or the user says the team shares the flow; `external` when the user works in several clones of the same repo or wants the files to survive a fresh clone; `private` otherwise.
- Waits for: nothing.
- Shapes: where every file is written, the exclude file, `domain`'s file location, and the `{setup:}` span in `recipes/implement-spec.md` that links the main checkout's `.claude` into each worktree when the files are not in git.

### tracker

- Options: described by the user in their own words; recipes `trackers/local.md`, `trackers/github.md`, `trackers/gitlab.md`, and `trackers/other.md` for anything else, including hybrids such as a local spec with remote tickets.
- Default: `local`.
- Recommend: `local` unless the repo already tracks its work elsewhere; `github` when the remote is GitHub, `gh` is installed and `gh issue list --limit 5` shows recent issues; `gitlab` the same way with `glab`; `other` when the user names Jira, Linear or the like, naming the tracker skill or CLI found in the session.
- Waits for: nothing.
- Verbs: every tracker recipe has the same blocks, and every tracker span in a recipe names one of them: `ticket-folder`, `publish-epic`, `publish-ticket`, `fetch`, `mark-ready`, `comment`, `close`, `blocker-done`, `fetch-review-comments`.
- Shapes: `recipes/flow.md`, `recipes/grill.md`, `recipes/spec.md`, `recipes/tickets.md`, `recipes/implement.md`, `recipes/implement-spec.md`, `recipes/review.md`, `recipes/fix.md`; the tracker recipe's text is written into each skill's tracker span, never linked.

### domain

- Options: `off`, `on`.
- Default: `off`.
- Recommend: `on` when explore found a `GLOSSARY.md`, `CONTEXT.md`, `GLOSSARY-MAP.md` or `docs/adr/`, or the user wants grill to keep a glossary and ADRs.
- Where, when on: an existing glossary and ADR directory stay where they are; otherwise the repo root `GLOSSARY.md` and `docs/adr/` when `location` is `committed`, and `.claude/flow/domain/GLOSSARY.md` and `.claude/flow/domain/adr/` otherwise.
- Waits for: `location`.
- Shapes: whether `verbatim/domain-modeling/` is copied, `recipes/grill.md` (calls domain-modeling and says where the files live), the vocabulary or glossary sentence of `recipes/flow.md`, `recipes/spec.md`, `recipes/tickets.md`, `recipes/implement.md`, `recipes/pr.md` and `recipes/retro.md`, and the `domain` input of `recipes/review.md`.

### commits

- Options: style `conventional` or the repo's detected style; author `agent` (one commit per green cycle, written by the agent) or `user` (the agent stops and the user commits).
- Default: `conventional`, `agent`.
- Recommend: the detected style when at least half of `git log --oneline -30` follows one recognisable convention other than conventional commits; conventional commits otherwise; `agent` unless the user asks.
- Waits for: nothing; the ticket footer follows `tracker` and is not asked.
- Ticket footer: every agent commit names its ticket in the footer in the form the tracker recognises: `Refs #<n>` for GitHub and GitLab issues, `Refs <KEY-n>` with the identifier pattern from `trackers/other.md`, or the ticket folder name (`Refs 03-auth-session`) for local tickets.
- Merge message: the merger's `git merge --no-ff` message in the same style, `merge: <NN> <ticket title>` for conventional commits.
- Shapes: `recipes/flow.md`, `recipes/implement.md`, `recipes/implement-spec.md` and its implementer and merger agents, `recipes/fix.md`.

### checkpoint

- Options: `on` (implement and fix stop before each commit, implement-spec pauses after each merge), `off`.
- Default: `on`.
- Recommend: `on` for a repo the user maintains and reads closely; `off` when they say they will mostly let it run.
- Waits for: `commits`; with `user` commits, the stop before each commit is implied and only the pause after each merge is asked.
- Shapes: `recipes/flow.md`, `recipes/implement.md`, `recipes/implement-spec.md`, `recipes/fix.md`.

### worktrees

- Options: `git` (plain git worktrees under `.worktrees/` at the repo root, created by the orchestrator from the integration branch), `herdr` (Herdr panes, dispatch handed to the user's own `orchestrate` skill).
- Default: `git`.
- Offer `herdr` only when an `orchestrate` skill is listed in the session's available skills; otherwise do not mention it.
- Recommend: `git`; `herdr` only when the user asks for it.
- Waits for: nothing.
- Shapes: `recipes/implement-spec.md`, `recipes/flow.md`; with `git`, setup makes sure `.worktrees/` is ignored: when `git check-ignore -q .worktrees/x` fails, a line in `.gitignore` when `location` is `committed`, in the git exclude file otherwise.

### reviewers

- Options: a set of reviewers, each one file `.claude/skills/review/reviewers/<name>.md` in the shape `reviewers/README.md` gives: frontmatter `model`, `paths`, `inputs` (`ticket`, `standards`, `domain`), `condition` (one sentence, `Always.` for always), `runner` (`agent` for the generic reviewer agent, or `codex`, `opencode`, `gemini`, `claude` for a script under `.claude/skills/review/runners/`), and a body with focus, numbered `## Rules` and `## Skip`.
  Each comes from `reviewers/catalogue/<name>.md` or `reviewers/catalogue/stacks/<stack>.md`, adapted to the repo, or from the user through the add-a-reviewer round in `reviewers/README.md`.
- Default: `spec` and `correctness`, `model: opus`, `runner: agent`.
- Recommend: `spec` and `correctness` always; `security` when the risk surface has input handling, auth, data access, crypto, secrets or dependency manifests; `tests` when the repo has a test suite; `standards` only when explore found standards docs, its `inputs` including `standards`; one stack reviewer per detected stack, its `paths` narrowed to where that stack lives, and for a stack with no catalogue entry one written in the same shape from the repo's docs and code.
  Offer an external runner only for a CLI found on `PATH`, and when one exists, offer a second correctness reviewer on that model family (for example `correctness-codex` with `runner: codex`) as an option the user opts into.
- Waits for: nothing.
- Shapes: `.claude/skills/review/reviewers/<name>.md`; the reviewer names in `recipes/flow.md` and the reviewer and standards lines of `recipes/retro.md`; `.claude/skills/review/CONTRACT.md` copied from `reviewers/CONTRACT.md`; `.claude/agents/reviewer.md` from the generic reviewer agent text in `reviewers/README.md`; only the `runners/<runner>.sh` scripts a chosen reviewer uses, copied to `.claude/skills/review/runners/`; the setup record's `## Reviewers`.

### models

- Options: per role, `opus`, `sonnet`, `haiku`, `fable` or a full model id.
- Default: implementer `opus`, merger `sonnet`, explorer `sonnet`, verifier `haiku`, builder `opus`, research `opus`; each reviewer's model is part of `reviewers`, `opus` by default.
  The verifier model also serves any other mechanical dispatch a recipe makes.
  A reviewer on an external runner takes the CLI's own model name instead.
- Recommend: the defaults; a cheaper explorer or verifier when the user cares about cost; never below `opus` for the implementer or the builder check unless the user asks.
- Waits for: nothing.
- Shapes: `.claude/agents/implementer.md`, `.claude/agents/merger.md`, `recipes/implement-spec.md`, `recipes/review.md` (verifier), `recipes/spec.md` (builder), `recipes/research.md`, and every recipe that dispatches an explorer.

### research_sources

- Options: folders or files on this machine, URLs, repos, or `none`; the web is always the fallback.
- Default: `none`.
- Recommend: docs directories and sibling repos explore found that the code refers to; vendor docs for the main frameworks.
- Waits for: nothing.
- Shapes: `recipes/research.md`.

### templates

- Options: the spec, ticket and PR shapes; sections added, dropped or renamed.
- Default: the spec sections Problem Statement, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope, Further Notes, seams first; the ticket with What to build, Blocked by, Touches, Verify, Status and when-then acceptance criteria; the PR body with Evidence and Merge Danger.
- Recommend: the defaults; the repo's own PR template's sections merged into the PR shape, keeping Evidence and Merge Danger; a tracker's required fields added to the ticket shape.
- Waits for: `tracker`.
- Shapes: the sibling template files of `recipes/spec.md`, `recipes/tickets.md` and `recipes/pr.md`.

## Rounds

The frontier on a first run is usually `location`, `tracker`, `commits`, `worktrees`, `reviewers`, `models` and `research_sources`, with any missing check commands.
The second round is usually `domain`, `checkpoint` and `templates`, plus the custom reviewers the user asked for in the first.
Recompute the frontier from the Waits for lines every round rather than following this order.
