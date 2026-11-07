# 04: Reviewer contract, shape and catalogue

## What to build

`references/reviewers/CONTRACT.md` from the installed 0.2.2 contract at `~/.claude/plugins/cache/amadej/flow/0.2.2/skills/review/REVIEWER-CONTRACT.md`, kept as the shape every reviewer returns.
`references/reviewers/README.md`: the reviewer file shape (frontmatter `model`, `paths`, `inputs`, `condition`, `runner`; body with focus, numbered rules, skips), the generic read-only `reviewer` agent text (from 0.2.2 `agents/reviewer.md`, tools Read, Grep, Glob, Bash read-only), how review dispatches one reviewer (Claude agent with model from the file, or the runner script), and the add-a-reviewer round from 0.2.2's add-reviewer skill as the way setup asks for custom reviewers.
`references/reviewers/catalogue/`: `spec.md`, `correctness.md`, `tests.md`, `standards.md` (with the Fowler smell baseline from the generator's standards reviewer), `security.md` carrying the categories, hard exclusions, trust assumptions and the per-finding false-positive filter of Anthropic's public security-review prompt (fetch it from `https://raw.githubusercontent.com/anthropics/claude-code-security-review/main/.claude/commands/security-review.md`), and `stacks/` with at least svelte, react, typescript-node, python, go, java-spring, kotlin-android, swift-ios, each a short standards reviewer setup adapts.
Each catalogue entry has a `condition` line saying when review selects it (correctness always; standards only when a standards doc governs a changed file; security when input handling, auth, data access, crypto or dependencies change; tests when tests or behaviour change; stacks by paths).

## Blocked by

None (can start immediately).

## Touches

`plugins/flow/references/reviewers/**`.

## Verify

Every file under 20000 bytes; every catalogue entry has frontmatter with the five keys and a `## Rules` and `## Skip` section.

## Status

ready-for-agent

## Acceptance criteria

- [ ] When review reads a reviewer file, then the frontmatter tells it the model, the paths, the inputs, the condition and the runner, and the body is the whole instruction.
- [ ] When the security reviewer is generated from the catalogue, then it reviews any range with the official prompt's categories, exclusions and false-positive filter.
- [ ] When setup asks for a custom reviewer, then README.md gives it the one-round question set and the file to show before writing.
