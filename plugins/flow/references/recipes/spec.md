# spec

## Frontmatter

```yaml
name: spec
description: Turn the current conversation into the epic's spec and publish it.
disable-model-invocation: true
```

Invocation mode: user-only.
The description is the one-line human description; it never changes.

## Varies by

- `domain`: on makes the vocabulary sentence name where the glossary and ADRs live; off makes it "Use the vocabulary the conversation and the code already use."
- `models`: the builder check names the `builder` model (default `opus`).
- `tracker`: the publish step names the tracker recipe's `publish-epic` verb and what it records at the top of `spec.md` (for local, nothing: the file is the epic; for a remote tracker, the epic's identifier).
- `templates`: `template.md` is the spec template the user chose; the default is the text under Sibling files, and a change keeps the Testing Decisions section with its seams line, since the builder check and tickets read it.

## Skill text

````markdown
This skill takes the current conversation context and codebase understanding and produces a spec: the **epic** that tickets breaks into tickets.
Do NOT interview the user; just synthesize what you already know.
The only questions are the seam check (step 2), the builder-check round (step 4) and the approval (step 5).

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already.
   {setup: when domain is on, "Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching; both live in <their location>."; when off, "Use the vocabulary the conversation and the code already use."}
   Name the research notes in the epic folder the spec relies on instead of restating them.

2. Sketch out the seams at which you're going to test the feature.
   Existing seams should be preferred to new ones.
   Use the highest seam possible.
   If new seams are needed, propose them at the highest point you can.
   The fewer seams across the codebase, the better - the ideal number is one.

   Check with the user that these seams match their expectations before going on.

3. Write the spec into [template.md](template.md): every section the template has, in its order, with its placeholder text replaced; no section it does not have.

4. **Builder check.** Dispatch one fresh sub-agent on the `{setup: the builder model}` model with the prompt in [builder-check.md](builder-check.md) and the spec.
   Sort its questions into three piles: already answered in the conversation (write the answer into the spec), minor (decide it yourself and mark it in Implementation Decisions as your call), and the user's (ask them in one message, most important first).
   This is the only round of questions the check produces.

5. **Approval.** Show the spec and the list of decisions you marked as your call.
   Publish only after the user approves; a correction loops back here, not through another builder check.

6. Publish the spec as the epic.
   Pick the epic slug: short, lowercase, hyphenated, from the epic's title.
   Write the spec to `.claude/flow/<epic-slug>/spec.md`, creating the folder.
   Then {setup: the tracker recipe's `publish-epic` verb, and what it records at the top of `spec.md`}.
````

## Sibling files

### template.md

{setup: the spec template the user chose; the default is the text below, unchanged}

````markdown
## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories.
Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made.
This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets.
They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype.
Trim to the decision-rich parts, not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made.
Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- The agreed seams, each with one line on what it catches and what it misses
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.
````

### builder-check.md

Fixed text.

````markdown
# Builder check prompt

Dispatch as a fresh general-purpose sub-agent.
Replace the bracketed parts.

```
You are a talented software engineer. You've been handed a spec and asked to break it into tickets and build what it describes. You will not be able to talk to the person who wrote it.

Read the spec below (or at [SPEC_PATH]).

Report only the questions you'd still need answered before you could plan this well: places where you'd have to guess and a wrong guess would matter. For each, give the question and why the answer changes the plan. Rank them by importance.

Skip anything the spec explicitly leaves to the builder or lists as out of scope, and anything you could reasonably decide yourself. Skip nitpicks about wording.

If nothing important is left, say "nothing important left".

[SPEC TEXT]
```
````

## Handoffs

Dispatches one fresh sub-agent for the builder check; calls no skill.
Names no next step.
