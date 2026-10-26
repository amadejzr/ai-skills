---
name: spec
description: "Turn the current conversation into a spec, check it with a fresh builder, and publish it to the issue tracker as the epic: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec: the **epic** that `flow:tickets` breaks into tickets. Synthesize from the conversation; the only questions are the seam check (step 2), the builder-check round (step 4) and the approval (step 5).

Call the Skill tool with "flow:config" for the tracker rules and the domain docs setting.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

3. Write the spec using the template below.

4. **Builder check.** Dispatch one fresh sub-agent with the prompt in [BUILDER-CHECK.md](./BUILDER-CHECK.md) and the spec. Sort its questions into three piles: already answered in the conversation (write the answer into the spec), minor (decide it yourself and mark it in Implementation Decisions as your call), and the user's (ask them in one message, most important first). This is the only round of questions the check produces.

5. **Approval.** Show the spec and the list of decisions you marked as your call. Publish only after the user approves; a correction loops back here, not through another builder check.

6. Publish the spec to the project issue tracker as the epic. On the local tracker it is `<flow dir>/features/<feature-slug>/spec.md`. Then tell the user the next step is `/flow:tickets`.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- The agreed seams, each with one line on what it catches and what it misses
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
