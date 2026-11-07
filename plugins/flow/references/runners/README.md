# Runners

A runner script lets a reviewer run on another CLI and model family instead of the generic Claude `reviewer` agent.
Setup copies `runners/<cli>.sh` to `.claude/skills/review/runners/<cli>.sh` for every reviewer whose `runner` names that CLI, and copies nothing when no reviewer does.
The scripts are the repo's own afterwards, edited like code.

## How review calls a runner

Review writes the change to a temporary diff file (untracked files appended with `git diff --no-index /dev/null <file>`) and runs, from the repository root, in the background:

```sh
bash .claude/skills/review/runners/<cli>.sh <diff-file> .claude/skills/review/reviewers/<name>.md .claude/skills/review/CONTRACT.md <output-file> [input-file...]
```

- The first four arguments are fixed; any further arguments are the reviewer's resolved `inputs` (the ticket, its epic spec, standards documents, glossary), each appended to the prompt under its path.
- The script reads `model:` from the reviewer file's frontmatter; it is the CLI's own model name, not a Claude alias.
- The prompt is one instruction paragraph, the contract, the reviewer file's body without its frontmatter, the inputs, and the diff: inline between `BEGIN DIFF` and `END DIFF` lines for codex, gemini and claude, attached as a file for opencode.
- The CLI runs non-interactively and read-only, and its final message is written to `<output-file>`.

Exit codes:

| Code | Meaning |
| --- | --- |
| 0 | The report is at the output path and has the contract's `## Declined to judge` list. |
| 2 | Wrong arguments, a missing file, no `model:` in the reviewer file, or a model in the wrong form for the CLI. |
| 3 | The CLI answered, the answer is at the output path, but it does not follow the contract. |
| other | The CLI is missing or failed; its last output lines and message are on stderr, and the code is the CLI's own when it gave one. |

Review reports any non-zero exit as `failed: <name> (<message>)`, never as a clean review.

## The runners

| Script | Command | Read-only by | Report taken from |
| --- | --- | --- | --- |
| `codex.sh` | `codex exec -s read-only -m <model> --ephemeral --color never -o <file> -` with the prompt on stdin | the `read-only` sandbox; `exec` never asks for approval | the `-o` file, the agent's last message |
| `opencode.sh` | `opencode run --format json -m <provider/model> -f <diff-file>` with the prompt on stdin | `OPENCODE_CONFIG_CONTENT` denying `edit`, `webfetch`, `websearch`, `task` and every `bash` command except `git diff`, `git log`, `git show`, `git ls-files`, `git grep`; `run` auto-rejects anything that would ask | the last `text` event's `part.text` |
| `gemini.sh` | `gemini -p "<instruction>" --output-format json -m <model> --approval-mode default` with the prompt on stdin | default approval mode, where every tool that would ask the user is denied in headless mode | `.response` |
| `claude.sh` | `env -u CLAUDECODE claude --bare -p --output-format json --model <model> --tools Read,Grep,Glob --allowedTools Read,Grep,Glob --permission-mode dontAsk --no-session-persistence` with the prompt on stdin | only `Read`, `Grep` and `Glob` exist in the session | `.result`, failing when `.is_error` is true |

## Environment each CLI needs

- All but codex need `jq` on `PATH`.
- codex: `npm install -g @openai/codex`, then `codex login` or `OPENAI_API_KEY`.
  Run from inside a git repository; `codex exec` refuses to run outside one.
  `model` is a model name `codex exec -m` accepts.
- opencode: installed from opencode.ai and signed in to the provider with `opencode auth login`, or that provider's API key in the environment.
  `model` must be `provider/model` as `opencode models` lists it; the script exits 2 otherwise.
- gemini: `npm install -g @google/gemini-cli`, signed in once interactively or with `GEMINI_API_KEY` set.
  The repository must be a trusted folder: trust it once in an interactive session, or export `GEMINI_CLI_TRUST_WORKSPACE=true`; otherwise headless gemini exits with an untrusted-workspace error.
  `model` is a Gemini model name or an alias such as `pro` or `flash`.
- claude: Claude Code with `ANTHROPIC_API_KEY` set, because `--bare` never reads the OAuth login or the keychain (Bedrock, Vertex and Foundry use their own credentials).
  `--bare` also skips hooks, plugins and CLAUDE.md, so the reviewer sees only the contract, its file, its inputs and the repository through the three read tools.
  The script unsets `CLAUDECODE` so a review started inside Claude Code can start a nested session.
  `model` is a Claude model alias such as `opus` or `sonnet`, or a full model id.

## Adding a runner

1. Copy the script closest to the new CLI to `runners/<cli>.sh`; keep `usage`, `fail`, `frontmatter_value`, `reviewer_body`, `build_prompt`, the argument checks and the final contract check unchanged.
2. Write `diff_section`: inline the diff when the CLI takes the prompt on stdin, or name the attached file when it attaches files.
3. Replace the CLI block: check the CLI and `jq` are on `PATH` with an install hint, run it non-interactively and read-only with the prompt from `$work_dir/prompt.md`, capture stdout and stderr in `$work_dir`, fail with the CLI's message and status on error, and write only the final answer to `$work_dir/report.md`.
4. Use only flags the CLI's `--help` or vendor docs show, and record here which ones you checked and how.
5. Run `bash -n`, `shellcheck` when installed, the script with no arguments (usage, exit 2), and once against a fake CLI on `PATH` that prints a canned answer, before a real review.
6. Add the CLI to the `runner` values in `reviewers/README.md` and to the runners list in `workflow.md`.

## Flags and how they were checked

Checked on 2026-11-04 without running any reviewer against a model.

- claude 2.1.318 installed: `claude --help` lists `-p`, `--bare`, `--output-format` (`text`, `json`, `stream-json`), `--model`, `--tools`, `--allowedTools`, `--permission-mode` (including `dontAsk`) and `--no-session-persistence`.
  `claude.sh` was run without `ANTHROPIC_API_KEY`; the CLI accepted every flag and returned `is_error: true` with "Not logged in", which the script reported with exit 1.
- codex, not installed: the developer commands reference at developers.openai.com (now learn.chatgpt.com/docs/developer-commands) documents `exec` with `-s`/`--sandbox read-only`, `-m`, `--ephemeral`, `-o`/`--output-last-message`, `--color never`, and `-` as the prompt to read stdin.
- opencode, not installed: opencode.ai/docs/cli documents `run` with `-m provider/model`, `-f`, `--format json`; opencode.ai/docs/permissions documents the `permission` keys, `allow`/`ask`/`deny` and `bash` patterns; opencode.ai/docs/config lists `OPENCODE_CONFIG_CONTENT` as inline runtime config.
  The source of `packages/cli/src/run/` in anomalyco/opencode (the renamed sst/opencode) shows that `run` appends piped stdin to the message, emits `{"type":"text","part":{"text":...}}` and `{"type":"error","error":...}` lines, exits 1 on error, and rejects every permission request it would have to ask about unless `--auto` is given.
- gemini, not installed: docs/cli/cli-reference.md in google-gemini/gemini-cli documents `-p` (appended to stdin input), `-m`, `--output-format json` and `--approval-mode` (`default`, `auto_edit`, `yolo`, `plan`); docs/cli/headless.md documents the `response` and `error` fields and the exit codes; docs/reference/policy-engine.md says an `ask_user` decision is treated as `deny` in non-interactive mode; docs/cli/trusted-folders.md documents the untrusted-workspace exit and `GEMINI_CLI_TRUST_WORKSPACE`.
  `--approval-mode plan` was not used: its docs say executing a plan switches the session to YOLO mode.
- Every script was run against fake `codex`, `opencode` and `gemini` binaries on `PATH` for a passing report, a CLI failure, a report without the declined list, a missing model, a missing file and a missing CLI.
