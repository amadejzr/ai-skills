# Generate

Write every file the "What every repo gets" table of `${CLAUDE_PLUGIN_ROOT}/references/workflow.md` lists for these answers, then apply the location mode and write the setup record.
On a re-run, rerun.md's "Edits in place" decides how each file changes; this file still says what each file must contain.

## 1. Where files go

The **target** is where generated files are written:

- `committed` and `private`: the repo's `.claude/`.
- `external`: the directory the user named (default `~/.flow/<repo-key>`), laid out as `<dir>/skills/`, `<dir>/agents/` and `<dir>/flow/`, mirroring `.claude/`.

Below, `.claude/<path>` means `<target>/<path>`.
Before writing, check each generated path against what explore found: an existing skill or agent of the same name that no earlier flow wrote is the user's own; ask whether to replace it, keep it and skip ours, or rename ours, and record the answer.

## 2. Skills from recipes

For each recipe `${CLAUDE_PLUGIN_ROOT}/references/recipes/<skill>.md` the table lists, read the whole recipe, then:

1. **Frontmatter.** The fenced YAML block under `## Frontmatter` is the skill's whole frontmatter: write it between `---` lines at the top of `.claude/skills/<skill>/SKILL.md`, every key and value exactly as given (`name`, `description`, `argument-hint` when present, `disable-model-invocation: true` only on a user-only skill, and any other key such as `metadata`).
   The fenced Skill text never carries frontmatter of its own.
2. **Varies by.** For each decision listed there, apply what it says for this repo's answer: keep or delete the paragraphs it names, choose the variant it names.
3. **Skill text.** Copy the body from inside the fenced block under `## Skill text` (not the fence itself) into `.claude/skills/<skill>/SKILL.md` after the frontmatter.
   Replace every `{setup: <what goes here>}` span with the finished text it describes, drawn from the answers and the explore facts.
   Where a span asks for a tracker verb, read `${CLAUDE_PLUGIN_ROOT}/references/trackers/<tracker>.md` (or the `other.md` shape filled from the user's description) and write the repo's actual command or steps into the span; never link to the tracker file.
   Where a span asks for check commands, write the commands explore found and the user confirmed, per package in a monorepo.
   Where a span asks for a model, write the model from `models`: `opus`, `sonnet`, `haiku`, `fable` or a full model id.
   Where a span asks for the ticket footer, the merge message or how this repo opens a draft PR, write what `workflow.md`'s `commits` node and the remote fact say.
   Leave the rest of the text as the recipe has it: the recipe is the finished text, and upstream wording is deliberate.
4. **Sibling files.** Each `###` heading under `## Sibling files` is a path: a bare file name goes next to the skill's SKILL.md, a path starting with `.claude/` goes there in the target.
   Its content is the fenced block under the heading, with its spans filled the same way.
   A sibling with a `{setup:}` line before the fence (such as a template the user reshaped) takes the user's version when the answer changed it.
5. **Handoffs.** Check that every skill and agent the `## Handoffs` section calls or names next is generated for this repo; a call to a skill that is not generated (domain-modeling with `domain` off) must already have been removed by the Varies by step.

## 3. Verbatim skills

Copy byte for byte, never retyped:

```bash
cp -R "${CLAUDE_PLUGIN_ROOT}/references/verbatim/grilling" "<target>/skills/grilling"
cp -R "${CLAUDE_PLUGIN_ROOT}/references/verbatim/tdd" "<target>/skills/tdd"
cp -R "${CLAUDE_PLUGIN_ROOT}/references/verbatim/domain-modeling" "<target>/skills/domain-modeling"
```

The third only when `domain` is on.
Where the domain files live is told by the grill skill's text, not by editing domain-modeling.

## 4. Reviewers

Read `${CLAUDE_PLUGIN_ROOT}/references/reviewers/README.md` for the file shape.

1. For each chosen reviewer, read its catalogue entry (`reviewers/catalogue/<name>.md` or `reviewers/catalogue/stacks/<stack>.md`) and write `.claude/skills/review/reviewers/<name>.md` adapted to the repo: `paths` narrowed to where it applies, `condition`, `inputs`, `model` and `runner` from the answers, rules reworded for the repo's languages, versions and libraries, rules its linters already enforce or that cannot apply removed, the repo's standards docs' own idioms added where the README says so.
   A reviewer from the add-a-reviewer round is written exactly as the user confirmed it.
2. Copy `reviewers/CONTRACT.md` to `.claude/skills/review/CONTRACT.md` with `cp`.
3. Write `.claude/agents/reviewer.md` from the fenced generic reviewer agent text in the README, with `<repo>` replaced by the repo's name.
4. For each distinct `runner` other than `agent`, copy `${CLAUDE_PLUGIN_ROOT}/references/runners/<runner>.sh` to `.claude/skills/review/runners/<runner>.sh` and `chmod +x` it; copy no other runner.
   Read `${CLAUDE_PLUGIN_ROOT}/references/runners/README.md` for the environment each CLI needs, and tell the user in the report when it is not set up.

## 5. Agents from implement-spec

`recipes/implement-spec.md` carries `.claude/agents/implementer.md` and `.claude/agents/merger.md` as sibling files; step 2 writes them, with the implementer and merger models and the commit style in their text.

## 6. The flow directory

Create `.claude/flow/`.
The skills create the epic, ticket and codebase folders as they need them; do not create empty ones.
When `domain` is on and no glossary exists yet, create nothing either; domain-modeling writes the files lazily where the grill skill says.

## 7. Location mode

The exclude file is `$(git rev-parse --git-common-dir)/info/exclude`, so worktrees share it.
Add a line only when it is not already there; write patterns without a trailing slash so they match symlinks too.

- `committed`: exclude nothing.
  Tell the user `.claude/` is ready to commit.
- `private`: add one line per generated top-level path: `/.claude/skills/<name>` for each generated skill, `/.claude/agents/<file>` for each generated agent, and `/.claude/flow`.
  Check with `git status --porcelain .claude` that none of them shows as untracked.
- `external`: with the files written into the external directory, link each into the repo with absolute targets:
  `ln -s <dir>/skills/<name> .claude/skills/<name>` per skill, `ln -s <dir>/agents/<file> .claude/agents/<file>` per agent, `ln -s <dir>/flow .claude/flow`.
  Create `.claude/skills` and `.claude/agents` as real directories when missing.
  Add the same exclude lines as `private`, one per link.

With `worktrees` set to `git`, make sure `.worktrees/` is ignored: if `git check-ignore -q .worktrees/x` fails, add `/.worktrees` to `.gitignore` in `committed` mode (shown as a diff first) or to the exclude file otherwise.

## 8. Improvements

Apply each accepted improvement now.
A change to a file the repo owns (outside the generated paths) is shown as a diff and written only when the user accepts it.
An accepted improvement that is a question for the user (a missing check command) is already answered by now; write the answer where the recipes need it.

## 9. The setup record

Write `.claude/flow/setup.md` in exactly these sections:

```markdown
# Flow setup

## Plugin version

<version from ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json>, set up <YYYY-MM-DD>

## Answers

- location: <committed | private | external <dir>>
- tracker: <local | github | gitlab | other>: <one sentence as the user described it>
- domain: <off | on>, <where the glossary and ADRs live>
- commits: <style>, <agent | user>
- checkpoint: <on | off>
- worktrees: <git under .worktrees/ | herdr through orchestrate>
- reviewers: <names, comma-separated>
- models: implementer <m>, merger <m>, explorer <m>, verifier <m>, builder <m>, research <m>
- research_sources: <list or none>
- templates: spec <default or the changes>, ticket <default or the changes>, pr <default or merged with path>
- checks: <name: command, ...>
- standards: <doc: paths it governs, ...>

## Improvements

- accepted: <I-title>: <what was done>
- declined: <I-title>

## Reviewers

- <name>: runner <runner>, model <model>, paths <globs>, condition <sentence>

## Generated

<one path per line, relative to the repo root, as the repo sees it (.claude/...)>
```

The record never holds a whole file; it is what a re-run reads to recommend and to know which paths are ours.

## Verify

Run these and fix anything they print before reporting; when the repo has skills or agents of its own, narrow the paths to the generated ones:

```bash
grep -rln '{setup:' .claude/skills .claude/agents
grep -rln 'CLAUDE_PLUGIN_ROOT' .claude/skills .claude/agents
find -L .claude/skills .claude/agents .claude/flow -type f -size +19999c
diff -r "${CLAUDE_PLUGIN_ROOT}/references/verbatim/grilling" .claude/skills/grilling
diff -r "${CLAUDE_PLUGIN_ROOT}/references/verbatim/tdd" .claude/skills/tdd
cmp "${CLAUDE_PLUGIN_ROOT}/references/reviewers/CONTRACT.md" .claude/skills/review/CONTRACT.md
bash -n .claude/skills/review/runners/*.sh
```

Add `diff -r` for domain-modeling when it is on; skip the runner line when no runner was copied.
The first three must print nothing; the diffs and `cmp` must print nothing.
Then read every generated SKILL.md once against `${CLAUDE_PLUGIN_ROOT}/references/principles.md`: frontmatter shape, bare-name calls, relative sibling links, one sentence per line, no em dashes.
Finally check the location mode: `git status --porcelain` shows the generated paths in `committed` mode and none of them otherwise.
