---
name: spec
description: "Turn the current conversation into the epic's spec in this repo's template and publish it to the tracker: synthesis of what was already discussed, no interview."
disable-model-invocation: true
---

# Spec

Synthesize the conversation and the codebase understanding into a spec: the **epic**.
The only questions are the ones the steps below mark as stops.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already.
   Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.
   Name the notes in `{{flow_dir}}/research/` the spec relies on instead of restating them.

2. Sketch out the seams at which you're going to test the feature.
   Existing seams should be preferred to new ones.
   Use the highest seam possible.
   If new seams are needed, propose them at the highest point you can.
   The fewer seams across the codebase, the better - the ideal number is one.
<!-- if stops~seams -->
   Check with the user that these seams match their expectations before going on.
<!-- else -->
   Decide the seams yourself and state them in one line.
<!-- endif -->

3. Write the spec into [template.md](template.md): every section the template has, in its order, with its placeholder text replaced; no section it does not have.

<!-- if stops~builder -->
4. **Builder check.** Dispatch one fresh sub-agent on the `{{builder_model}}` model with the prompt in [builder-check.md](builder-check.md) and the spec.
   Sort its questions into three piles: already answered in the conversation (write the answer into the spec), minor (decide it yourself and mark it in the spec as your call), and the user's (ask them in one message, most important first).
   This is the only round of questions the check produces.
<!-- else -->
4. Mark every decision you made on the user's behalf in the spec as your call.
<!-- endif -->

<!-- if stops~spec -->
5. **Approval.** Show the spec and the list of decisions you marked as your call.
   Publish only after the user approves; a correction loops back here, not through another builder check.
<!-- else -->
5. List the decisions you marked as your call in one message, then publish.
<!-- endif -->

6. Publish the spec to the issue tracker as the epic.
<!-- if tracker=local -->
   Write it to `{{flow_dir}}/features/<feature-slug>/spec.md`, creating the directory.
<!-- endif -->
<!-- if tracker=github -->
   `gh issue create --title "<epic title>" --body "<spec>"`, with a heredoc for the body; `gh` infers the repo from the clone.
<!-- endif -->
<!-- if tracker=gitlab -->
   `glab issue create --title "<epic title>" --description "<spec>"`, with a heredoc for the description; `glab` infers the repo from the clone.
<!-- endif -->
<!-- if tracker=other -->
   <!-- fill: how to publish the epic on this repo's tracker: the skill or CLI to call and the fields it needs -->
<!-- endif -->
