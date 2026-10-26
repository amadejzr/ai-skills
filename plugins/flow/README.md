# flow

A spec-first engineering loop, forked from Matt Pocock's skills, superpowers and feature-dev and regrouped into one plugin.
Everything it owns for a repo lives in one flow directory, `.flow`, kept local or committed with the repo.

```
/flow:setup                                  once per repo
/flow:add-reviewer                           define or change one reviewer, any time
/flow:grill                                  interview; glossary and ADRs only when the repo config allows
/flow:spec                                   the epic, builder-checked, approved, on the tracker
/flow:tickets                                tracer-bullet tickets, children of the epic
/flow:implement <ticket>                     TDD at agreed seams, checks green, hands off to review
/flow:review since <ref>|<fixed-point>|staged|working [reviewer ...]
                                             every reviewer file (or the named ones) in parallel, the review file written, then fix
/flow:fix [<review file>|<PR number>|<pasted review>]
                                             findings listed, apply what you say, re-review, checks; any review, any day
```

`/flow:flow` prints this map with what each step leaves behind.

## Skills

User-invoked: `setup`, `add-reviewer`, `grill`, `spec`, `tickets`, `implement`, `retro`, `upstream`, `flow`.
Model-invoked (reachable by the steps above and by Claude on its own): `config`, `grilling`, `domain-modeling`, `tdd`, `review`, `fix`, `pr`.

## Where the flow keeps things

Per repo, one flow directory holds everything the flow owns; nothing it owns lives anywhere else:

```
<flow dir>/
  config.md              tracker, domain docs, selection, standards map and notes, checks, navigation
  reviewers/<name>.md    one file per reviewer: the whole reviewer
  features/<slug>/       local tracker: spec.md and issues/<NN>-<slug>.md
  domain/                glossary and ADRs, when Domain docs is on
  reviews/               one file per review run
```

`setup` picks one of two modes per repo, and can switch later:

- **local** (recommended): the directory is `~/.flow/<repo-key>` (override with `FLOW_HOME`), keyed by the origin remote so clones and worktrees share it; the repo gets a `.flow` symlink to it, listed in `.git/info/exclude`.
- **git**: the directory is `<repo>/.flow`, committed with the repo; `.flow/.gitignore` keeps `reviews/` out.

`scripts/flow-config.sh` resolves the directory (`--init local|git`, `--switch local|git`); `flow:config` reads it for every other skill.
Without a flow directory nothing runs: there are no built-in defaults.
The repo's own docs (`CONTRIBUTING.md`, `CLAUDE.md`, a committed glossary or ADRs) stay where they are; the flow reads them and never edits them.

## Reviewers

Nothing is built in: each reviewer is a file you write for the repo, through `setup` or `/flow:add-reviewer`, or by hand.
Its frontmatter holds `model`, `paths` and `inputs` (`spec`, `standards`, `domain-docs`); its body is the reviewer's whole instructions: what it looks at, its numbered rules, what it skips.
`flow:review` runs every file in parallel, or only the ones you name, each as the one generic agent `agents/reviewer.md` with the file's body as its instructions.
Every reviewer also gets the same contract (`skills/review/REVIEWER-CONTRACT.md`): read-only, severities must-fix / worth-doing / optional, confidence 75 or above, one fixed output shape.
The standards map assigns the repo's own standards docs to path globs, so a monorepo can review each package against its own rules, and the standards notes hold your rules for the repo; both go to reviewers that take `standards`.

## Review output

- The review file: `<flow dir>/reviews/<YYYY-MM-DD-HHMM>-<slug>.md` with a merge verdict, the tiers, declined-to-judge lists, and `## Applied`, `## Deferred` and `## Checks` sections appended after fixes.
- The fix: `flow:review` hands its file to `flow:fix`; run `/flow:fix` yourself to act on a review in a later session, on a pull request's review comments, or on a review someone pasted. A PR or pasted review is first written to `reviews/` with the original text kept under `## Original review`.
- The selection: the findings are listed in chat with a recommendation (apply all must-fix; for a person's review, all, each verified first). Reply `yes`, `+F7`, `-F2`, a list of ids, `all`, or `none`. Set `Selection: dialog` in `config.md` for a multi-select question per tier instead.
- After applying: one scoped re-review of the fix diff by the reviewers involved (a person re-reviews their own comments), the check commands quoted, and the ticket set to `done`.

## OpenCode

The skill text is written once, for Claude Code, and `scripts/install-opencode.sh` generates the OpenCode form into `~/.config/opencode/`: one `flow-<name>` skill per skill, one `/flow-<name>` command per user-invoked skill plus `/flow-review` and `/flow-fix`, and the one `flow-reviewer` subagent.
It rewrites `flow:<name>` to `flow-<name>` and `${CLAUDE_PLUGIN_ROOT}` to this plugin's path.
Rerun it after editing the plugin.
The same flow directory serves both hosts.
OpenCode cannot pick a model per dispatch, so a reviewer file's `model` is ignored there and reviewers run on the dispatching agent's model; `Selection: dialog` falls back to chat.

## Keeping up with the sources

`upstream/<source>/` holds the upstream files this plugin forked, at the version last reviewed, plus a `SOURCE` file with the commit.
`/flow:upstream` runs `scripts/upstream-check.sh --diff` (a depth-1 clone of each source), decides per hunk whether to port or skip, applies the ports, and accepts the new baseline.
`/flow:retro` turns what a review missed into reviewer rules, standards notes, checks or navigation pointers.
