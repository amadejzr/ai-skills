---
name: research
description: "Investigate a question against trusted primary sources in a background agent and leave a cited note in {{flow_dir}}/research/. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated while they keep working; grill reaches it when a frontier question needs a fact from outside the repo."
---

# Research

Spin up background agents with fresh context windows to do the reading, so the user keeps working while they read.

The note goes to `{{flow_dir}}/research/<YYYY-MM-DD>-<slug>.md`.
Read the notes already there first: a question an existing note answers is answered by pointing at it, not by a new agent.

## Sources this repo trusts first

Read these before anything else, and prefer them when they answer the question:

<!-- fill: the sources this repo trusts first: local docs or folders on this machine, URLs, repos; or none -->

Beyond them, only **primary sources** count: official docs, source code, specs, first-party APIs, never a secondary write-up of them.
Follow every claim back to the source that owns it.

## Dispatch

<!-- if research_agents=1 -->
Run one background agent on the `{{research_model}}` model; it takes the whole question.
<!-- else -->
Run {{research_agents}} background agents on the `{{research_model}}` model: split the question into {{research_agents}} independent sub-questions, one agent each, and merge their findings into the one note; where two agents disagree, the note says so and names both sources.
<!-- endif -->

Each agent's job:

1. Investigate against the trusted sources, then the primary sources.
2. Write every claim with its source: a URL or a file path and the version or date it was read at.
3. Open with the question and a three-line answer; the rest is the evidence, so a later reader can stop after the opening.

When the agents report, tell the user the note's path and the three-line answer.
The note is a **context pointer** from then on: a spec, ticket or implementer that relies on it names the path instead of restating it.
