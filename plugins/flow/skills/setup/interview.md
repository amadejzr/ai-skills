# Interview

## Summary

A few lines, facts only, each with where it came from when it is not obvious.
Name what you could not find, so the user can correct it: a missing check command, an unclear tracker, a stack you guessed.
On a re-run or over an earlier design, say what exists, its version, and that its answers are the recommendation.

## Improvements

Walk every item of `${CLAUDE_PLUGIN_ROOT}/references/improvements.md`, keep the ones whose Detect line matches a finding, and drop the rest silently.
On a re-run, drop the ones the setup record lists as declined unless their evidence changed.
List the kept ones numbered as `I1`, `I2`, ..., each in this shape:

```
I1 - <title>: <evidence, with the path or command> -> <what you propose>. Cost: <cost effect>. Recommended.
```

Mark an item recommended when its evidence is unambiguous and the change is small; otherwise say why not.
An accepted improvement is applied in step 5, after the flow is generated; one that changes a file the repo owns is shown as a diff first.

## The one-line offer

End the message with one line in this shape:

```
Reply "go" to generate the recommended set (<the 4 to 6 most significant choices, comma-separated>) with the recommended improvements, or tell me what to change and I will grill you on the rest.
```

On "go", or "go" with edits such as "go, but no I3" or "go, location committed", list the significant choices one line each (location, tracker, domain, commits and checkpoint, worktrees, reviewers with their runners, models that differ from the defaults, improvements accepted) and continue to step 5 without another question.
On anything else, take what the user said as settled answers and grill the rest.

## Grilling

This is the grilling discipline from Matt Pocock's grilling skill, applied to the design tree in `${CLAUDE_PLUGIN_ROOT}/references/workflow.md`.
Read this section again before every round.

Interview the user relentlessly until you reach a shared understanding.
Map this as a **design tree**: every decision branches into the decisions that hang off it.
Here the tree is `workflow.md`: each `###` node under Decisions is a decision, its Waits for line its prerequisites, and the checks explore could not find are questions too.

Work the tree in **rounds**.
The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet.
Ask the whole frontier in one round: number each question and give your recommended answer.
Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them.
Recompute the frontier and ask the next round.
A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's.
When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself.
Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now.
The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed.
Do not act on it until the user confirms you have reached a shared understanding.

## How to ask each decision

- Each question states the options from the node, your recommendation from its Recommend rule, and the finding that drove it, in plain engineering terms.
- `location`: say what each mode means for a fresh clone, for worktrees and for teammates; for `external`, recommend `~/.flow/<repo-key>` as the directory unless the user names one.
- `tracker`: ask the user to describe how this repo tracks work in their own words when it is not plainly local, GitHub or GitLab; for a hybrid or another tracker, read `${CLAUDE_PLUGIN_ROOT}/references/trackers/other.md` and ask the questions its shape needs, one per verb: `ticket-folder`, `publish-epic`, `publish-ticket` (with blocking edges), `fetch`, `mark-ready`, `comment`, `close`, `blocker-done`, `fetch-review-comments`, naming the tracker skill or CLI found in the session.
- `worktrees`: never mention `herdr` unless explore found an `orchestrate` skill in the session.
- `reviewers`: present the proposed set as a table of name, source (catalogue entry or new), paths, condition, inputs, model and runner, and ask in the same question whether they want reviewers of their own.
  For each one they want, run the add-a-reviewer round from `${CLAUDE_PLUGIN_ROOT}/references/reviewers/README.md` in the next round.
- `models`: one question listing every role with its recommended model.
- `templates`: show the section list of each template, not the full text, and the sections merged from the repo's own PR template.
- A re-run asks only what to change: each question states the recorded answer as the recommendation.
