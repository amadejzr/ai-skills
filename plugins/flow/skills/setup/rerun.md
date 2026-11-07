# Re-run and earlier designs

A re-run changes what exists; it never regenerates a file from scratch, because composition is not deterministic and the user may have edited any file.
The existing files are the recommendation, the questions are what to change, and the result is a diff per file that the user accepts or declines.

## From a setup record

Read `.claude/flow/setup.md`.

- Its `## Answers` and `## Reviewers` are the recommended answers for every decision; the one-line offer becomes "keep everything and apply the plugin's updates".
- Its `## Improvements` says which items not to propose again; propose a declined one only when its evidence changed.
- Its `## Generated` is the list of paths that are ours; anything else under `.claude/` is the user's and is never touched.
- Its `## Plugin version` tells you which recipes moved.
  When the recorded version differs from the one in `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`, look for the old plugin next to this one (`${CLAUDE_PLUGIN_ROOT}/../<recorded version>/references/`); when it exists, `diff -ru` its references against the current ones to see exactly what changed in each recipe, reviewer entry, tracker, runner and verbatim file.
  When it does not, treat every recipe as possibly changed and compare each generated file against its current recipe.

Run explore as usual; a fact that changed since the record (a new stack, a new CLI, a removed check) becomes a question in the first round with the record's answer and the new fact side by side.

## From the generator design

`.claude/flow/settings` and `.claude/flow/generated` mean the files were composed by the generator.
Map its settings to the recommendation:

- `mode` becomes `location` (`private` stays `private`, `committed` stays `committed`).
- `commits` keeps its author; the style comes from `git log` as usual.
- `pacing` becomes `checkpoint`: `checkpoint` is on, `autonomous` is off.
- `tracker` and `domain` carry over.
- `reviewers` lists names; each `.claude/agents/<name>-reviewer.md` becomes `.claude/skills/review/reviewers/<name>.md`, its rules kept as the starting body, with `paths` and `inputs` from the old review skill's table and a `condition` and `runner` added.
- `implementer_model`, `builder_model`, `research_model` become `models`.
- `scope`, `gate`, `stops` and `research_agents` have no node any more: the repo now has both `/implement` and `/implement-spec`, the seams, spec, builder and ticket stops are part of the recipes, and `/grill <ticket>` replaces the gate.
  Say so in the summary, once.

The generated files sit at the paths the new design uses, so treat them as the existing files for "Edits in place".
Propose deleting each old `<name>-reviewer.md` agent, `.claude/flow/settings` and `.claude/flow/generated` once the new files are accepted, each as its own yes or no.
Specs and tickets under `.claude/flow/features/` and notes under `.claude/flow/research/` are left where they are; tell the user in the report that moving them into `.claude/flow/<epic-slug>/` folders is theirs to do.

## From the 0.2.2 design

A `.flow` directory or symlink with `config.md` and `reviewers/` means the 0.2.2 plugin.
Map it to the recommendation:

- `.flow` as a symlink into `~/.flow/<repo-key>` suggests `location` `external` with that directory; a committed `.flow/` suggests `committed`.
- `Tracker` and its `## Tracker notes` carry over.
- `Domain docs` `single` or `multi` becomes `domain` on, with the glossary and ADRs where they are.
- `## Checks` become the checks facts.
- `## Standards map` and `## Standards notes` become the standards facts and the `standards` reviewer's `paths`, `inputs` and extra rules.
- `## Navigation` pointers are proposed as an improvement: lines in the repo's instruction file.
- Each `reviewers/<name>.md` becomes `.claude/skills/review/reviewers/<name>.md` with its body and `model`, `paths` and `inputs` kept (`spec` becomes `ticket`, `domain-docs` becomes `domain`), and a `condition` and `runner: agent` added.

No 0.2.2 skill file sits at a generated path, so every file is new: show each in full instead of a diff.
Leave `.flow` itself in place; tell the user in the report that its `features/`, `domain/` and `reviews/` are theirs to move into the per-ticket folders, and that `.flow` and its exclude line can go once they have.

## Edits in place

For each path that is ours (from `## Generated`, or the earlier design's list), in the order of the table in `workflow.md`:

1. Read the existing file, its recipe or source, and the answers that changed.
2. Decide what must change: a span whose answer changed, a Varies by branch whose decision changed, a recipe passage that moved between plugin versions, a verbatim file that differs from `${CLAUDE_PLUGIN_ROOT}/references/verbatim/`.
   Text the user edited by hand, where no answer or recipe changed, stays as it is.
3. When nothing must change, say "unchanged" for the file and move on.
4. Otherwise write the proposed file to a scratch path, show `diff -u <existing> <proposed>`, and ask: take it, keep mine, or edit.
   Batch small diffs into one message, numbered, so the user answers them in one line.
5. Write only what the user accepts.
   Verbatim files are replaced with `cp`, never edited, and only when accepted.

Then handle what the new answers add or remove:

- A new skill, reviewer, runner or agent is written as in generate.md and shown in full.
- A removed reviewer, a runner no reviewer uses any more, or domain-modeling with `domain` turned off is proposed as a deletion.
- A changed `location` moves every generated path: from `committed` or `private` to `external`, move the files into the external directory and link them back; from `external` to `committed` or `private`, replace each link with the files; update the exclude lines to match the new mode, removing lines this flow added that no longer apply.

Finally rewrite `.claude/flow/setup.md` for the new answers, the new plugin version, every improvement decision and the current generated list, and run generate.md's "Verify" section.
