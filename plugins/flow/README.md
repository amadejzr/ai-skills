# flow

One skill that sets up a repo's own spec-first, test-first engineering loop, built from Matt Pocock's skills, superpowers and Anthropic's official plugins.
Install the plugin once.
In each repo, `/flow:setup` explores the code, proposes improvements, offers a recommended set in one line or grills you in rounds over a workflow design tree, and then writes the loop into the repo as its own skills and agents.
Claude composes every file itself from the plugin's references; there is no template engine and nothing reads a config at run time.
From then on those files are the behaviour: edit them like code.

```
/flow:setup                     once per repo; again to change any decision, with a diff per file
```

## What a repo gets

```
<repo>/.claude/
  skills/
    flow/             names the step you are at and the next command
    grill/            grills an idea or a ticket; calls grilling, and domain-modeling when domain is on
    grilling/         Matt Pocock's grilling, byte for byte
    domain-modeling/  Matt Pocock's domain-modeling with its format files, byte for byte; only when domain is on
    spec/             the epic, seams agreed first, builder-checked, published through your tracker
    tickets/          tracer-bullet tickets with Blocked by, Touches, Verify and when-then criteria
    implement/        Matt Pocock's implement for one ticket, then review
    implement-spec/   the whole epic through fresh implementers in worktrees and a merger per landing
    tdd/              Matt Pocock's tdd with tests.md and mocking.md, byte for byte
    review/           picks reviewers by paths and conditions, runs them fresh and in parallel, writes a numbered review
      reviewers/<name>.md   one file per reviewer: model, paths, inputs, condition, runner
      runners/<cli>.sh      codex, opencode, gemini or headless claude, only when a reviewer uses it
      CONTRACT.md           severity, confidence, finding shape, declined-to-judge
    fix/              applies a review's recommendation, named ids, a review file, pasted findings or PR comments
    pr/               the PR body, merged with the repo's own template
    research/         background agents over the sources you trust, one cited note
    retro/            turns what slipped into a check, a standards line, a reviewer rule or a pointer
  agents/
    reviewer.md  implementer.md  merger.md
  flow/
    setup.md                                 the setup record: version, answers, improvements, reviewers, generated paths
    <epic>/spec.md  research-*.md  review-NN.md
    <epic>/<NN>-<ticket>/ticket.md  grill.md  review-NN.md
    codebase/review-NN.md
```

The loop: `/grill` an idea or a ticket, `/spec`, `/tickets`, `/implement` one ticket or `/implement-spec` the epic, `review` and `/fix` until clean, `/pr`, and `/retro` on request.
`review`, `fix`, `pr` and `research` can also be reached by Claude on its own; the rest are typed by you.

## What setup decides

| decision | options | what it changes |
| --- | --- | --- |
| `location` | `committed`, `private`, `external` | files committed under `.claude/`, listed in the git exclude file, or kept in a directory you name and linked in |
| `tracker` | described in your words; recipes for local, GitHub, GitLab and any other | where epics, tickets and review comments live, including hybrids |
| `domain` | `off`, `on` | whether grill keeps a glossary and ADRs |
| `commits` | style, `agent` or `user` | the commit convention and who commits |
| `checkpoint` | `on`, `off` | implement and fix stop before each commit; implement-spec pauses after each merge |
| `worktrees` | `git`, `herdr` | how implement-spec runs parallel implementers |
| `reviewers` | spec, correctness, security, tests, standards, stack reviewers, your own | one file each, with model, paths, inputs, condition and runner |
| `models` | per role | implementer, merger, explorer, verifier, builder check, research |
| `research_sources` | folders, URLs, repos | where research looks first |
| `templates` | spec, ticket, PR shapes | the template files spec, tickets and pr carry |

`references/workflow.md` is the full tree, with defaults and the rule behind each recommendation.

## Install

```
/plugin marketplace add amadejzr/ai-skills
/plugin install flow@amadej
```

Update with `/plugin marketplace update amadej` then `/plugin update flow@amadej`, or switch auto-update on for the `amadej` marketplace under `/plugin`.
For development, `claude --plugin-dir ./plugins/flow` loads this checkout.
Generated repos are untouched by plugin updates; run `/flow:setup` again in a repo to pull improvements in, file by file.

## Inside the plugin

```
skills/setup/         the only skill: SKILL.md plus explore, interview, generate and rerun steps
references/
  workflow.md         the design tree setup grills from, and the table of every generated path
  principles.md       rules every generated file obeys
  improvements.md     the checklist setup proposes from
  verbatim/           grilling, tdd, domain-modeling, byte-identical to upstream/
  recipes/            one finished skill text per generated skill, with {setup: ...} spans to fill
  reviewers/          the reviewer file shape, the contract, and the catalogue to adapt
  trackers/           local, github, gitlab, other
  runners/            external reviewer scripts and how review calls them
scripts/upstream-check.sh   compares upstream/ and references/verbatim/ with the sources
tests/references.test.sh    the structural test
tests/e2e.sh                scaffolds a sample repo, runs setup headless, grades the result
tests/E2E.md                the end-to-end run before each release: the script, then the manual checks
upstream/                   the forked files at the version last reviewed
```
