# research

## Frontmatter

```yaml
name: research
description: Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent, or when a grill, spec or ticket question needs a fact from outside the repo.
argument-hint: "<question>"
```

Invocation mode: model-invoked and typed by the user; no `disable-model-invocation`.
The description says only when to use the skill.

## Varies by

- `research_sources`: the trusted-sources list names each source the user gave, one bullet each (a local folder or doc, a URL, a repo, a first-party API), with one line on what it is the authority for; with none, the list is the single line "None beyond the primary sources below."
- `models`: the dispatch sentence names the `research` model (default `opus`).

## Skill text

````markdown
# Research

Spin up a **background agent** to do the research, so you keep working while it reads.
Start it with a fresh context window.

The note goes to `.claude/flow/<epic-slug>/research-<YYYY-MM-DD>-<slug>.md`, in the folder of the epic the question serves.
When there is no epic folder yet, create it under the slug the coming spec will use, and say which.
Read the notes already in that folder first: a question an existing note answers is answered by pointing at it, not by a new agent.

## Sources this repo trusts first

Read these before anything else, and prefer them when they answer the question:

{setup: the sources this repo trusts first, one bullet each with what it is the authority for; or "None beyond the primary sources below."}

Beyond them, only **primary sources** count: official docs, source code, specs, first-party APIs, not a secondary write-up of them.
Follow every claim back to the source that owns it.

## Dispatch

Run the agents in the background on the `{setup: the research model}` model.
One agent takes the whole question; when it splits into independent sub-questions, run one agent per sub-question and merge their findings into the one note.
Where two agents disagree, the note says so and names both sources.

Each agent's job:

1. Investigate the question against the trusted sources, then the primary sources.
2. Write the findings to the note, citing each claim's source: a URL or a file path, and the version or date it was read at.
3. Open the note with the question and a three-line answer; the rest is the evidence, so a later reader can stop after the opening.

When the agents report, tell the user the note's path and the three-line answer.
The note is a **context pointer** from then on: a spec, ticket or implementer that relies on it names the path instead of restating it.
````

## Sibling files

None.

## Handoffs

Dispatches background agents; calls no skill.
Names no next step.
