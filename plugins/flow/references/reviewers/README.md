# Reviewers

A reviewer is one file, `.claude/skills/review/reviewers/<name>.md`, and nothing about it lives anywhere else.
The file name without `.md` is the reviewer's name in finding ids (`<name>-<n>`).
Setup proposes reviewers from `catalogue/` by the repo's stack and risk surface, adapts each one's wording to the repo, and writes it.
The contract every reviewer returns is `CONTRACT.md`, copied to `.claude/skills/review/CONTRACT.md`.

## File shape

```markdown
---
model: opus
paths: ["src/**/*.ts"]
inputs: [standards]
condition: When a changed file is TypeScript under src.
runner: agent
---

You review <focus> in <repo>.
<One or two sentences on how to look: what to trace, what to compare against.>

## Rules

1. <a concrete thing to check, phrased so a finding can cite it by number>

## Skip

- <what it leaves to other reviewers or to tooling>
```

- `model`: for `runner: agent`, a Claude model the Agent tool accepts (`opus`, `sonnet`, `haiku`, `fable`, or a full model id); for an external runner, the CLI's own model name.
- `paths`: globs for the files it judges; `[]` means the whole change.
  Review hands the reviewer only the changed files that match.
- `inputs`: what its rules need besides the diff, from `ticket` (the ticket and its epic spec), `standards` (the standards documents that govern the changed files), `domain` (glossary and ADRs); `[]` for none.
- `condition`: one sentence saying when review selects it, judged against the change; `Always.` for a reviewer that always runs.
- `runner`: `agent` for the generic Claude `reviewer` agent, or the name of a script under `.claude/skills/review/runners/` (`codex`, `opencode`, `gemini`, `claude`).

The body is the whole instruction: the focus paragraph, numbered `## Rules`, and `## Skip`.
A reviewer file may raise the contract's confidence threshold in its body; it never lowers it.
Keep the rules under about 1,500 bytes: a reviewer reads a diff, and every rule it carries is a rule it has to hold in mind for every hunk.

## Selection

Review runs every reviewer the user names, or else selects each one whose `paths` match at least one changed file and whose `condition` holds for the change, and says in one line why each ran or was skipped.

## The generic reviewer agent

Setup writes this text to `.claude/agents/reviewer.md`, unchanged except for the repo's name where it says `<repo>`:

```markdown
---
name: reviewer
description: Runs one reviewer file from .claude/skills/review/reviewers/ against a change in <repo>. Dispatched by the review and fix skills.
tools: Read, Grep, Glob, Bash
color: cyan
---

You are one reviewer of a change, starting with a fresh context.
The dispatch prompt names the range and the diff command, the commits, the changed files in your scope, the contract file, your reviewer file and the input files your reviewer file asks for.
Read the contract, then your reviewer file: its body is your whole focus, and you follow the contract for scope, severity, confidence and output.
Read the inputs, then the diff, then the code it touches.

Bash is for reading only: `git diff`, `git log`, `git show`, `git ls-files`, `git grep`, and the repo's existing test command.
Never write outside the system temp directory, never move `HEAD`, never commit, never install anything.

Return only the report in the contract's output format.
```

## Dispatch

Each selected reviewer runs fresh and in parallel with the others.
The dispatch passes pointers, never pasted content: the range and its diff command, the commit list, the changed files that match the reviewer's `paths`, the path of `CONTRACT.md`, the path of the reviewer file, and the paths of its inputs.

- `runner: agent`: call the Agent tool with `subagent_type: reviewer`, `model` from the reviewer file, and a prompt carrying those pointers.
- Any other runner: write the diff to a temp file and run `bash .claude/skills/review/runners/<runner>.sh <diff-file> <reviewer-file> <contract-file> <output-file> [input-file...]`, the four fixed arguments followed by the resolved paths of the reviewer's `inputs`, one file per argument with a folder expanded to the markdown files in it; the script reads `model` from the reviewer file, appends each input file to the prompt under its path, and writes the report in the contract's shape to the output file.
  A non-zero exit is reported as that reviewer failing, with the script's message, and never as a clean review.

## Adding a reviewer

Setup offers this round when the user wants a reviewer the catalogue does not cover, or wants to change one; the same round runs when a retro turns a judgement call into a new reviewer.

First ground it.
Ask what the reviewer is for in one question when the user has not said.
Then read what it will judge: the code its focus touches, the repo docs that already state rules for it, the existing reviewer files (so the new one does not overlap them), and recent review files for findings in this area.
When the user names a reviewer that already has a file, this is an edit: read it, and the result is a diff against it.

Then ask one round, each question with your recommended answer, worded so "yes" accepts all of them:

1. **Name.** Short, kebab-case; it becomes the file name and the reviewer's name in finding ids.
2. **Paths.** Globs for the files it judges, from what you read; `[]` for the whole change.
3. **Condition.** The one sentence that decides when review selects it.
4. **Inputs.** `ticket`, `standards`, `domain`, or none; only what its rules need.
5. **Model and runner.** `opus` on `agent` unless the user names another model or an external CLI.
6. **Rules.** Numbered, each a concrete thing to check in this codebase, phrased so a finding can cite it by number; drawn from the user's words, the code you read and the repo's docs.
7. **Skips.** What it leaves to other reviewers or to tooling, so it stays in its lane.

Show the whole file in the shape above and let the user edit it before writing.
Write it, and record it in the setup record's `## Reviewers` section.

## Catalogue

| File | Selected |
|---|---|
| `catalogue/spec.md` | when the change belongs to a ticket or an epic spec |
| `catalogue/correctness.md` | always |
| `catalogue/tests.md` | when tests change or the change alters behaviour |
| `catalogue/standards.md` | only when a standards document governs a changed file |
| `catalogue/security.md` | when input handling, auth, data access, crypto, secrets or dependencies change |
| `catalogue/stacks/<stack>.md` | by paths, for the stack the repo uses |

The stack entries are short standards reviewers for svelte, react, typescript-node, python, go, java-spring, kotlin-android and swift-ios.
Setup keeps the rules that apply to the repo's versions and libraries, drops the ones its linters already enforce, and writes the stack's own idioms from the repo's standards docs in their place.
For a stack with no entry, setup writes one in the same shape from the repo's standards docs and code.
