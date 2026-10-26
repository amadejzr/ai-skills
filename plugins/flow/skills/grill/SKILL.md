---
name: grill
description: "A relentless interview to sharpen a plan or design, writing glossary terms and ADRs into the flow directory as they crystallise when the repo config allows it. The entry point of the flow; ends ready for /flow:spec."
disable-model-invocation: true
---

Call the Skill tool for "flow:config", then for "flow:grilling" and "flow:domain-modeling".
The config's `Domain docs` setting decides whether terms and decisions are written into the flow directory's `domain/` or kept in the conversation for the spec to carry.

Explore the area of the codebase the idea touches before the first round, so the questions and recommendations are grounded in what is there.

When the user has only a vague idea rather than a plan, open with one question that gets them describing a concrete moment ("What's the moment you find yourself wishing this existed?") before computing the first frontier.

When the frontier is empty and the user confirms the shared understanding, say that the next step is `/flow:spec`, and keep this context window: spec and tickets build on the same thinking.
