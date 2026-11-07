# Tracker: other

The shape setup fills when the repo tracks work anywhere but plain local files, GitHub or GitLab: Jira, Linear, Azure Boards, a team wiki, or a hybrid of several.
Setup asks the user to describe the tracker in their own words, reads what the session offers for it (a tracker skill, an MCP server's tools, a CLI on `PATH`), fills one block per verb below, shows the filled shape to the user, and writes each verb's text into the tracker span of the skill that needs it.
A generated skill never links this file, and never says "use the tracker" without naming the exact skill, tool or command.

## How to fill it

- Every verb names one mechanism: a skill (`Call the Skill tool with <name>`), an MCP tool by its full name, or a shell command with its flags.
  Prefer what the session already has over a raw HTTP call.
- Every verb says what it takes and what it returns, including where the identifier of a new item is read from.
- Each verb may live on a different system; that is what a hybrid is.
  Name the system at the start of each block.
- When the tracker cannot do a verb, write what stands in for it (a line in the description, a label, a local file), never a blank.
- Copy commands from `local.md`, `github.md` or `gitlab.md` for any verb that lives on one of those systems.
- Ask about required fields once (issue type, project key, component, team, priority) and write them into the publish verbs; add the ones every ticket needs to the ticket template.
- Ask for the identifier pattern (`PROJ-123`, `ENG-42`) so commit footers and fetch know a ticket reference when they see one.

## The shape

```markdown
## Systems

- <system>: <what lives there> (<the skill, MCP server or CLI used>)

## ticket-folder

<what `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/ticket.md` holds: the ticket itself when tickets are local, otherwise a stub with the remote identifier, URL and epic identifier>

## publish-epic

<system>: <the exact call, its fields, where the new identifier comes from, and what goes at the top of `spec.md`>

## publish-ticket

<system>: <the exact call, its fields, how the parent link to the epic is set, how each blocking edge is set, which template lines it drops because the tracker carries them natively>

## fetch

<system>: <how to read a ticket with its comments from any reference form, and how to find and read its epic>

## mark-ready

<system>: <the status, label or column that means ready-for-agent, and the call that sets it>

## comment

<system>: <the call that appends text to a ticket or the epic, and how to edit the ticket's own text>

## close

<system>: <the comment with the criteria met and the review file path, then the transition to done; name the transition when the workflow has several>

## blocker-done

<system>: <how to list a ticket's blockers and the state that counts as done>

## fetch-review-comments

<system where PRs or MRs live>: <how to fetch review summaries and inline comments with file and line for a PR or MR reference>
```

## Example: hybrid, spec local, tickets in Jira

```markdown
## Systems

- Local files: the epic, `.claude/flow/<epic-slug>/spec.md`.
- Jira, project `PAY`: tickets, through the Atlassian MCP server's Jira tools.
- GitHub: pull requests, through `gh`.

## ticket-folder

A stub `ticket.md`: `# <NN>: <title>`, then `Jira: PAY-<n> <url>` and `Epic: .claude/flow/<epic-slug>/spec.md`.

## publish-epic

Local files: write `.claude/flow/<epic-slug>/spec.md`; nothing is created in Jira.

## publish-ticket

Jira: create an issue of type Story in project PAY with the filled template as the description, dropping the status line, and label `epic-<epic-slug>` as the parent link.
The new key is in the tool's response.
Each blocker becomes an issue link of type "Blocks" from the blocker to the new issue.

## fetch

Jira: read the issue by key with its comments and links; the epic is the stub's `Epic:` line.

## mark-ready

Jira: transition the issue to "Ready for Dev".

## comment

Jira: add a comment to the issue; edit the description for changes to the ticket itself.

## close

Jira: add a comment with the criteria met and the review file path, then transition to "Done".

## blocker-done

Jira: the issue's "is blocked by" links; a blocker is done when its status category is Done.

## fetch-review-comments

GitHub: as in `github.md`, `gh pr view <pr> --json reviews,comments` and `gh api --paginate repos/{owner}/{repo}/pulls/<pr>/comments`.
```

Implement-spec ignores blocker-done for its frontier and counts a blocker as done only when its branch has merged into the integration branch, whatever the tracker.
