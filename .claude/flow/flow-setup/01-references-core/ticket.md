# 01: References core and the setup skill

## What to build

The plugin's `references/workflow.md`, `principles.md`, `improvements.md`, the `verbatim/` tree, and the `skills/setup/SKILL.md` skill with its step references.
`workflow.md` is the design tree: one node per decision named in the contract, each with options, default, the recommendation rule from what explore found, and the recipes and files it shapes.
`principles.md` distils the research note into the rules every generated file obeys.
`improvements.md` is the retro-style checklist setup proposes from after exploring, each item with how to detect it and its cost effect.
`skills/setup/SKILL.md` runs explore, summary and improvements, the one-line shortcut, the grilling rounds over `workflow.md` (the grilling discipline inlined from the verbatim grilling skill, since the plugin has no other skill), generation from the recipes, the setup record, the location mode, and the re-run as edits in place with a diff per file.

## Blocked by

None (can start immediately).

## Touches

`plugins/flow/references/workflow.md`, `principles.md`, `improvements.md`, `verbatim/**`, `plugins/flow/skills/setup/**`.

## Verify

`bash -n` passes for nothing here; `wc -c` of every new file is under 20000; `diff -r plugins/flow/references/verbatim/grilling plugins/flow/upstream/mattpocock-skills/skills/productivity/grilling` and the same for tdd and domain-modeling under `skills/engineering/` print nothing.

## Status

ready-for-agent

## Acceptance criteria

- [ ] When setup starts in a repo with no setup record, then it explores, summarises, proposes improvements, offers the recommended set in one line, and otherwise grills in rounds from `workflow.md`.
- [ ] When setup starts in a repo with a setup record, or with the files of the generator or 0.2.2 designs, then it uses them as the recommendation and ends in edits in place with a diff per file.
- [ ] When setup generates, then it writes every file from the recipes, copies the verbatim files, the contract and the needed runner scripts, writes `.claude/flow/setup.md` in the contract's format, and applies the location mode (committed, private via the git exclude file, external via symlinks).
- [ ] When the worktree engine herdr is offered, then setup has first checked that an `orchestrate` skill exists in the session.
- [ ] When any reference or the skill is written, then it is under 20,000 bytes and verbatim files are byte-identical to upstream.
