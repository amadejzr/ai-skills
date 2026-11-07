# Principles every generated file obeys

`/flow:setup` checks each file it writes against these rules before it shows or writes it.
They are distilled from Matt Pocock's skills, obra's superpowers, Anthropic's official plugins and Claude Code docs, and the workflow articles in the epic's research note.

## Size and shape

1. Every SKILL.md, agent file and reference stays under 20,000 bytes.
   Compaction truncates a re-attached skill at that size, and Claude Code never re-reads a skill body on a later turn.
2. Put the rules that must survive compaction at the top of the skill: what it never does, where it stops, what done means.
3. Move step material into a sibling file the skill reads at the step that needs it, linked relatively (`[template.md](./template.md)`), and say "read it again before every round" when the step repeats.
4. One full sentence per line in Markdown.
   No em dashes; use a plain dash.
5. No comments in code or scripts and no narrative in skill text: names, steps and completion criteria carry the meaning.
6. A skill gives steps first, then in-file reference, then disclosed reference files; it ends each step with a completion criterion an agent can check.

## Invocation

7. A user-only skill has `disable-model-invocation: true` and a one-line description for a human.
   In the generated set these are flow, grill, spec, tickets, implement, implement-spec and retro.
8. A model-invoked skill has no flag, and its description says only when to use it, with the trigger phrases, never what it does step by step.
   In the generated set these are review, fix, pr and research, and the verbatim grilling, tdd and domain-modeling.
9. A user-only skill never calls another user-only skill.
10. A skill calls another by bare name: "Call the Skill tool with review."
    Only the plugin's own skill uses `${CLAUDE_PLUGIN_ROOT}`; generated files never point back into the plugin.

## Agents and context

11. Every dispatched agent starts with a fresh context window.
12. Communicate through context pointers: pass paths, refs and ids, never pasted summaries of files the agent can read itself.
    An agent writes its result to a file when the result is longer than a short report, and returns the path.
13. Name the model on every dispatch; turn count beats token price, so the implementer and the builder check get the strongest model, mechanical work the cheapest.
14. Facts are found by agents, decisions are made by the user; never ask the user for something a read or a command can answer.
15. Reviewers and verifiers never dispatch further agents, and no chain of dispatches goes deeper than Claude Code's three nested layers.
16. Parallel agents never touch the same files: two tickets run together only when their Touches do not overlap, and only one agent at a time runs the build or the test suite in one checkout.
17. Explorers return the 5 to 10 files that matter with one line each; the dispatcher reads those files itself.

## Building

18. Spec first, seams agreed with the user before tickets, tests written at those seams.
19. Red, green, refactor; one commit per green cycle, in the repo's commit style.
20. Standards are enforced at review, not at implementation: the implementer carries the most context pressure, the reviewer the least.
21. Every ticket says what it touches and how it is verified, so it can be built in a fresh context and scheduled safely.
22. A loop has a stop rule: the final review-fix loop runs at most three rounds, then reports every open finding and stops.
23. A blocker counts as done when its branch has merged into the integration branch, not when the tracker says so.

## Reviewing

24. A reviewer reads the change, its own file and its inputs, nothing else; it is read-only.
25. Every finding has an id, a severity, a confidence from 0 to 100, a file and line, and a concrete fix; findings below the contract's threshold are not reported.
26. A must-fix finding is checked by a fresh verifier before it reaches the user; an unverified must-fix is dropped or downgraded.
27. Review writes its findings to a file and applies nothing; fix applies them.
28. Review never converges; do not loop until a reviewer is silent.

## Keeping it the repo's own

29. Every generated file is the repo's own afterwards, edited like code; nothing reads a config at run time.
30. Behaviour that differs between repos is written into the text at setup time, never left as a variable or a lookup.
31. The environment improves on request: a mechanical mistake becomes a check, a judgement call a reviewer rule or standards line, a lost search a navigation pointer in the instruction file.
