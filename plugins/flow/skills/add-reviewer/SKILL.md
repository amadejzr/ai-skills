---
name: add-reviewer
description: "Define one reviewer for this repo, or change an existing one, as a file in the flow directory's reviewers/."
disable-model-invocation: true
---

# Add reviewer

Write one reviewer file, `reviewers/<name>.md` in the flow directory, that `flow:review` runs from then on.
The file is the whole reviewer: nothing about it lives anywhere else.

Call the Skill tool with "flow:config" for the flow directory and the reviewer file format.
With no flow directory, stop and suggest `/flow:setup`.
When the user names a reviewer that already has a file, this is an edit: read it, and the result is a diff against it.

## Process

### 1. Ground it

Ask what the reviewer is for in one question when the user has not said.
Then read what it will judge: the parts of the code its focus touches, the repo docs that already state rules for it, the existing reviewer files (so the new one does not overlap them), and recent review files in `reviews/` for findings in this area.

### 2. Ask one round

Each with your recommended answer, worded so "yes" accepts all of them:

1. **Name.** Short, kebab-case; it becomes the file name and the reviewer's name in finding ids.
2. **Paths.** Globs for the files it judges, from what you read; `[]` for the whole change.
3. **Inputs.** `spec`, `standards`, `domain-docs`, or none; only what its rules need.
4. **Model.** `opus` unless the user names another.
5. **Rules.** Numbered, each a concrete thing to check in this codebase, phrased so a finding can cite it by number; drawn from the user's words, the code you read and the repo's docs.
6. **Skips.** What it leaves to other reviewers or to tooling, so it stays in its lane.

### 3. Confirm

Show the whole file:

```markdown
---
model: opus
paths: ["**/src/main/**/*.java"]
inputs: []
---

You review <focus> in <repo>. <One or two sentences on how to look: what to trace, what to compare against.>

## Rules

1. ...

## Skip

- ...
```

Let the user edit before writing.

### 4. Write

Write the file.
Tell the user its path, that `flow:review` runs it from now on (`/flow:review <mode> <name>` runs it alone), and that they can edit it by hand at any time.
