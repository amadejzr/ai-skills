# 03: Recipes for implement, implement-spec, review and fix

## What to build

`references/recipes/implement.md`, `implement-spec.md`, `review.md`, `fix.md` in the contract's recipe format.
`implement` is Matt Pocock's implement (fetch ticket, tdd at agreed seams, checks, conventional commit per green cycle, checkpoint before commits when on, then call review; a clean review closes the ticket).
`implement-spec` is Matt Pocock's implement-spec with the four changes from the spec: merge-based frontier, Touches overlap rule for parallelism, a three-round cap on the final review-fix loop, checkpoint pause after each merge; worktrees created by the orchestrator from the integration branch under an ignored directory, the main checkout's `.claude` linked into each worktree when it is not tracked; herdr delegates dispatch to the user's `orchestrate` skill. The recipe carries the implementer and merger agent texts as sibling files.
`review` resolves the range (since a ref, staged, working, codebase), finds the ticket and epic, selects reviewers from `reviewers/<name>.md` by paths and condition and says why or takes the named set, dispatches Claude reviewers through the generic `reviewer` agent with the model from the file and external ones through `runners/<cli>.sh`, verifies each must-fix finding with a fresh verifier agent, writes `review-NN.md` into the ticket folder (ids `<reviewer>-<n>`, severity, confidence, file, fix, `## Recommendation`), ends with the path, the `/fix` hint and a one-line retro candidate, applies nothing.
`fix` resolves findings (latest review of a ticket, a review path, a PR whose comments it fetches via the tracker recipe, or pasted text normalised into a new review file), selects the recommendation, named ids or all, works like implement per finding, re-runs the raising reviewers on the fix commits, runs checks, marks each finding fixed with its commit or declined with a reason in the review file, closes the ticket when no must-fix remains.

## Blocked by

None (can start immediately). Reads `reviewers/CONTRACT.md` and the tracker recipes only by their contract paths.

## Touches

`plugins/flow/references/recipes/{implement,implement-spec,review,fix}.md`.

## Verify

Every recipe under 20000 bytes; each has the six sections of the recipe format in order; review and fix name the contract path and the runner scripts exactly as the contract does.

## Status

ready-for-agent

## Acceptance criteria

- [ ] When implement-spec computes the frontier, then a blocker counts as done only when its branch has merged into the integration branch.
- [ ] When two ready tickets declare overlapping Touches, then implement-spec queues one behind the other.
- [ ] When the final review-fix loop reaches three rounds, then implement-spec reports every open finding and stops.
- [ ] When review runs, then it writes the numbered review into the ticket folder and stops without applying anything.
- [ ] When fix is given pasted findings, then it writes them as a new review file in the contract's shape before fixing.
- [ ] When implement and implement-spec are read, then they are user-only; review and fix are model-invoked and also typed by the user.
