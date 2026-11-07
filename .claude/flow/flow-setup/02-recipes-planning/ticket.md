# 02: Recipes for the planning skills

## What to build

`references/recipes/flow.md`, `grill.md`, `spec.md`, `tickets.md`, `pr.md`, `research.md`, `retro.md` in the contract's recipe format.
Start from the current generator templates under `plugins/flow/generator/skills/` (the Matt Pocock text with setting lines) and turn each into a recipe: finished skill text with `{setup: ...}` spans where the tracker recipe, the domain decision, the templates, the research sources or the models go.
`grill` takes an optional ticket argument: fetch it the tracker's way, grill it, write the result back as the tracker allows and into the ticket folder as `grill.md`.
`spec` keeps seams first, the builder check on the builder model, approval, and publishes through the tracker recipe into `.claude/flow/<epic-slug>/spec.md` and the tracker.
`tickets` adds a Touches line, a Verify line and when-then acceptance criteria to the ticket template and publishes in dependency order with blocking edges.
`flow` names the step and the next command and stops.
`retro` is Matt Pocock's retro aimed at the generated files (reviewer files, standards, checks, navigation).

## Blocked by

None (can start immediately).

## Touches

`plugins/flow/references/recipes/{flow,grill,spec,tickets,pr,research,retro}.md`.

## Verify

Every recipe under 20000 bytes; each has the six sections of the recipe format in order; `grep -c '{setup:' ` is at least one per recipe that varies.

## Status

ready-for-agent

## Acceptance criteria

- [ ] When a recipe is read by the composing agent, then it can write the skill without reading anything else but the setup answers and the named tracker recipe.
- [ ] When grill gets a ticket argument, then the recipe says how to fetch, grill, and write back, and where `grill.md` goes.
- [ ] When tickets publishes, then each ticket carries Touches, Verify and when-then criteria, and the ticket folder `<NN>-<slug>/ticket.md` exists for local trackers or holds a stub naming the remote issue otherwise.
- [ ] When the invocation modes are read, then flow, grill, spec, tickets and retro are user-only and pr and research are model-invoked with trigger-only descriptions.
