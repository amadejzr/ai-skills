# 05: Tracker recipes and runner scripts

## What to build

`references/trackers/local.md`, `github.md`, `gitlab.md`, `other.md`: each says how to publish an epic, publish a ticket under it with blocking edges, fetch a ticket and its epic, mark ready, close, tell when a blocker is done, and fetch PR or MR review comments, and what the ticket folder holds (the ticket itself for local, a stub naming the remote issue otherwise).
Start from the generator's inlined tracker lines and the 0.2.2 `skills/config/tracker-*.md`; GitHub uses native dependencies (`gh issue create --blocked-by`, `gh issue edit --add-blocked-by`, gh 2.94+, with the API fallback) and sub-issues; close is a comment then `gh issue close`.
`other.md` is the shape setup fills from the user's description, including hybrids such as a local spec with remote tickets.
`references/runners/README.md` and `codex.sh`, `opencode.sh`, `gemini.sh`, `claude.sh`: each script takes the diff file, the reviewer file, the contract file and an output path, runs the CLI read-only and non-interactively with the model from the reviewer file, and writes the report in the contract's markdown shape to the output path; it exits non-zero with the CLI's message when the CLI is missing or fails.
Use the flags from the research note: `codex exec -s read-only -m <model> --ephemeral`, `opencode run --format json -m <model> -f <diff>`, `gemini -p --output-format json -m <model>`, `claude --bare -p --output-format json --allowedTools "Read,Grep,Glob" --model <model>` (unset `CLAUDECODE` first).
README.md says how review calls a runner, the environment each CLI needs, and how to add a runner.

## Blocked by

None (can start immediately).

## Touches

`plugins/flow/references/trackers/**`, `plugins/flow/references/runners/**`.

## Verify

`bash -n plugins/flow/references/runners/*.sh` passes; `shellcheck` passes when installed; every file under 20000 bytes; each runner prints usage and exits 2 when called with no arguments.

## Status

ready-for-agent

## Acceptance criteria

- [ ] When a runner is called with a diff, a reviewer file, the contract and an output path, then it writes a report in the contract's shape or exits non-zero with the CLI's error.
- [ ] When a tracker recipe is read, then every verb the recipes need (publish epic, publish ticket with edges, fetch, mark ready, close, blocker done, fetch review comments) is there.
- [ ] When the tracker is a hybrid, then `other.md` shows how to describe which verbs go where.
