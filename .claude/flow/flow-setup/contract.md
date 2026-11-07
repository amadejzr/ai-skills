# Build contract for the flow-setup epic

Every ticket of this epic writes into `plugins/flow/` of this checkout unless it says otherwise.
This file fixes the names the tickets share so they can be built in parallel.

## Plugin tree after the epic

```
plugins/flow/
  .claude-plugin/plugin.json          one skill, pinned version 0.3.0
  skills/setup/SKILL.md               the only plugin skill, /flow:setup
  skills/setup/*.md                   step references setup reads at the step that needs them
  references/
    workflow.md                       the design tree setup grills from
    principles.md                     rules every generated file obeys
    improvements.md                   the checklist setup proposes from
    verbatim/grilling/SKILL.md
    verbatim/tdd/SKILL.md  tests.md  mocking.md
    verbatim/domain-modeling/SKILL.md  ADR-FORMAT.md  GLOSSARY-FORMAT.md
    recipes/<skill>.md                flow grill spec tickets implement implement-spec review fix pr research retro
    reviewers/README.md               reviewer file shape, the generic reviewer agent, how review dispatches
    reviewers/CONTRACT.md             severity, confidence, output shape, declined-to-judge
    reviewers/catalogue/<name>.md     spec correctness security tests standards, plus stacks/<stack>.md
    trackers/local.md github.md gitlab.md other.md
    runners/README.md codex.sh opencode.sh gemini.sh claude.sh
  scripts/upstream-check.sh           unchanged
  tests/references.test.sh            the structural test
  upstream/                           unchanged
```

## Generated tree in a repo

```
<repo>/.claude/
  skills/<name>/SKILL.md              flow grill grilling domain-modeling spec tickets implement implement-spec tdd review fix pr research retro
  skills/review/reviewers/<name>.md   one reviewer each
  skills/review/runners/<cli>.sh      copied from references/runners when a reviewer uses that runner
  skills/review/CONTRACT.md           copied from references/reviewers
  skills/review/REVIEW-FORMAT.md      the shape of a review file, from the review recipe
  agents/reviewer.md implementer.md merger.md
  flow/setup.md                       the setup record
  flow/<epic-slug>/spec.md  research-<date>-<slug>.md  review-NN.md
  flow/<epic-slug>/<NN>-<ticket-slug>/ticket.md  grill.md  review-NN.md
  flow/codebase/review-NN.md
```

## Decision names in workflow.md

Recipes, setup and the test use exactly these names: `location` (committed, private, external), `tracker` (described; recipes local, github, gitlab, other), `domain` (off, on), `commits` (conventional by default, agent or user commits), `checkpoint` (on, off), `worktrees` (git, herdr), `reviewers` (the set, each with model, paths, inputs, condition, runner), `models` (implementer, merger, explorer, verifier, builder, research), `research_sources`, `templates` (spec, ticket, pr).

## Recipe format

A recipe is the finished skill text the composing agent writes into the repo, with spans it must fill.
Sections, in order: `# <skill>`, `## Frontmatter` (name, description, invocation mode), `## Varies by` (the decisions that change the text and how), `## Skill text` (the body, with `{setup: <what goes here>}` spans), `## Sibling files` (templates and references the skill carries, with their text), `## Handoffs` (which skill it calls and which it names next).
A `{setup: ...}` span is the only placeholder form; no directives, no template variables.

## Setup record format (.claude/flow/setup.md)

Sections: `## Plugin version`, `## Answers` (one line per decision), `## Improvements` (accepted and declined, one line each), `## Reviewers` (one line each: name, runner, model, paths, condition), `## Generated` (one path per line).

## Writing rules

- Every SKILL.md, recipe and reference stays under 20,000 bytes; move step material into a sibling file read at that step.
- One full sentence per line in Markdown.
- No em dashes; use a plain dash.
- No comments in shell scripts; names carry the meaning.
- A user-only skill has `disable-model-invocation: true` and a one-line human description; a model-invoked skill's description says only when to use it, never its process.
- Generated skills call each other by bare name ("Call the Skill tool with review") and link sibling files relatively; only the plugin skill uses `${CLAUDE_PLUGIN_ROOT}`.
- Every dispatched agent starts with a fresh context window; communication through context pointers, never pasted summaries.
- Verbatim files are byte-identical to `plugins/flow/upstream/mattpocock-skills/skills/...`.
- Do not commit; leave the working tree for review.
