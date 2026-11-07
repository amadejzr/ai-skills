# Tracker: GitHub

Epics and tickets are GitHub issues: the epic is a parent issue, each ticket a sub-issue of it, and blocking edges are GitHub's native issue dependencies.
Use `gh` from inside the clone; it infers the repository from the remote, and `{owner}/{repo}` in a `gh api` path is filled in the same way.
Setup writes the text of each verb below into the tracker span of the skill that needs it, keeping only the commands this repo's `gh` supports; a generated skill never links this file.

## Requirements

- `gh` authenticated with `gh auth status`.
- `gh` 2.94 or later for `--parent`, `--blocked-by`, `--add-blocked-by` and `--add-sub-issue`; check with `gh --version`.
  On an older `gh`, every verb below gives the `gh api` fallback, and setup writes the fallback instead.
- A `ready-for-agent` label; create it once with `gh label create ready-for-agent --description "Ready for an agent to pick up"` when `gh label list` lacks it.

## ticket-folder

The ticket folder `.claude/flow/<epic-slug>/<NN>-<ticket-slug>/` holds a stub, `ticket.md`, naming the remote issue, written once the issue exists:

```markdown
# <NN>: <ticket title>

Issue: #<number> <issue url>
Epic: #<epic number>

The issue is the ticket; fetch it before working on it.
```

`grill.md` and `review-NN.md` sit next to the stub.
The epic's `spec.md` keeps the full spec with `Issue: #<number> <issue url>` as its first line under the title.

## publish-epic

Write the spec to `.claude/flow/<epic-slug>/spec.md`, then create the epic issue from it:

```sh
gh issue create --title "<epic title>" --body-file .claude/flow/<epic-slug>/spec.md
```

`gh issue create` prints the new issue's URL; its number is the last path segment.
Add the `Issue:` line to the top of `spec.md`.

## publish-ticket

Publish in dependency order, blockers first, so every edge names an issue that exists.
Write the filled template to a temporary file, dropping the spec line (the parent link carries it), the status line (the label carries it) and the blocked-by line (the native edge carries it), then:

```sh
gh issue create --title "<NN>: <ticket title>" --body-file <ticket-file> --parent <epic-number> --blocked-by <blocker>,<blocker> --label ready-for-agent
```

Leave out `--blocked-by` for a ticket with no blockers.
Then write the stub `ticket.md` into the ticket folder.

Fallback on a `gh` without these flags: create the issue with `gh issue create --title ... --body-file ... --label ready-for-agent`, then

```sh
child_id=$(gh api repos/{owner}/{repo}/issues/<child> --jq .id)
gh api --method POST repos/{owner}/{repo}/issues/<epic>/sub_issues -F sub_issue_id="$child_id"
blocker_id=$(gh api repos/{owner}/{repo}/issues/<blocker> --jq .id)
gh api --method POST repos/{owner}/{repo}/issues/<child>/dependencies/blocked_by -F issue_id="$blocker_id"
```

The ids are database ids (`.id`), never the issue number or `node_id`.
Where sub-issues or dependencies are not enabled, keep `Part of #<epic>` and `Blocked by: #<n>, #<n>` as the first lines of the body instead.
To add an edge after publishing: `gh issue edit <child> --add-blocked-by <blocker>`.

## fetch

```sh
gh issue view <number> --json number,title,body,state,labels,parent,blockedBy,comments,url
```

A reference is `#<n>`, `<n>`, an issue URL, or a ticket folder whose stub names the issue.
The epic is the issue's `parent`; fetch it the same way.
On a `gh` without the `parent` and `blockedBy` fields, drop them from `--json`; the epic is then the `Epic:` line of the stub in the ticket folder, or the `Part of #<n>` line in the body.
Read `grill.md` and the latest `review-NN.md` in the ticket folder when they exist.

## mark-ready

```sh
gh issue edit <number> --add-label ready-for-agent
```

publish-ticket already sets the label on a new ticket.

## comment

```sh
gh issue comment <number> --body-file <file>
```

Use `--body "<text>"` for one line.
To change the ticket itself, as grill does with what it settled, edit the body with `gh issue edit <number> --body-file <file>` from the fetched body and add a comment saying what changed.

## close

Comment first, then close:

```sh
gh issue comment <number> --body "<the acceptance criteria met, and the review file path>"
gh issue close <number> --reason completed
```

## blocker-done

A blocker is done when its issue is closed: `gh issue view <blocker> --json state --jq .state` prints `CLOSED`.
A ticket's open blockers are counted by `gh api repos/{owner}/{repo}/issues/<number> --jq .issue_dependencies_summary.blocked_by`; zero means every blocker is closed.
Without native dependencies, read the `Blocked by:` line and check each issue's state.
Implement-spec ignores this and counts a blocker as done only when its branch has merged into the integration branch.

## fetch-review-comments

For a PR number or URL:

```sh
gh pr view <pr> --json number,title,url,reviews,comments
gh api --paginate repos/{owner}/{repo}/pulls/<pr>/comments --jq '.[] | {path, line, body, user: .user.login, in_reply_to_id}'
```

The first gives the review summaries and the conversation; the second gives the inline review comments with their file and line.
GitHub shares one number space for issues and PRs, so resolve a bare `#<n>` with `gh pr view <n>` first and fall back to `gh issue view <n>`.
