# Tracker: GitLab

Epics and tickets are GitLab issues: the epic is one issue, each ticket an issue whose description starts with `Part of #<epic>`, and blocking edges are GitLab's native `is_blocked_by` issue links where the tier has them.
Use `glab` from inside the clone; it infers the project from the remote, and `:id` in a `glab api` path is filled in the same way.
GitLab calls comments notes and PRs merge requests (MRs); issues and MRs are numbered separately, so `#12` is an issue and `!12` an MR.
Setup writes the text of each verb below into the tracker span of the skill that needs it, with this repo's tier settled; a generated skill never links this file.

## Requirements

- `glab` authenticated with `glab auth status`.
- Blocking links (`blocks`, `is_blocked_by`) are a Premium and Ultimate feature; on the free tier every edge is a `Blocked by: #<n>, #<n>` line at the top of the description instead.
  Setup asks the tier once, or tries one link on a scratch issue, and writes only the form that works.
- A `ready-for-agent` label; create it once with `glab label create --name ready-for-agent` when `glab label list` lacks it.

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
glab issue create --title "<epic title>" --description-file .claude/flow/<epic-slug>/spec.md --yes
```

`glab issue create` prints the new issue's URL; its number is the last path segment.
Add the `Issue:` line to the top of `spec.md`.
On a Premium group with epics, the user may prefer a GitLab epic; setup then writes that tracker as `other.md` describes.

## publish-ticket

Publish in dependency order, blockers first, so every edge names an issue that exists.
Write the filled template to a temporary file with `Part of #<epic>` as its first line, dropping the spec line (the parent line carries it) and the status line (the label carries it), then:

```sh
glab issue create --title "<NN>: <ticket title>" --description-file <ticket-file> --label ready-for-agent --linked-issues <blocker>,<blocker> --link-type is_blocked_by --yes
```

Leave out `--linked-issues` and `--link-type` for a ticket with no blockers.
On the free tier, drop those two flags and keep the template's blocked-by line as `Blocked by: #<n>, #<n>` under the `Part of` line.
To add an edge after publishing: `glab issue note <child> --message "/blocked_by #<blocker>"`.
Then write the stub `ticket.md` into the ticket folder.

## fetch

```sh
glab issue view <number> --comments
```

Add `-F json` for machine-readable output.
A reference is `#<n>`, `<n>`, an issue URL, or a ticket folder whose stub names the issue.
The epic is the `Part of #<n>` line at the top of the description; fetch it the same way.
Read `grill.md` and the latest `review-NN.md` in the ticket folder when they exist.

## mark-ready

```sh
glab issue update <number> --label ready-for-agent
```

publish-ticket already sets the label on a new ticket.

## comment

```sh
glab issue note <number> --message "<text>"
```

To change the ticket itself, as grill does with what it settled, rewrite the description with `glab issue update <number> --description-file <file>` from the fetched one, keeping the `Part of` and `Blocked by` lines, and add a note saying what changed.

## close

`glab issue close` takes no comment, so note first, then close:

```sh
glab issue note <number> --message "<the acceptance criteria met, and the review file path>"
glab issue close <number>
```

## blocker-done

A blocker is done when its issue is closed: `glab issue view <blocker> -F json` has `"state": "closed"`.
A ticket's native blockers are the entries of `glab api projects/:id/issues/<number>/links` whose `link_type` is `is_blocked_by`; each one is done when its `state` is `closed`.
On the free tier, read the `Blocked by:` line and check each issue's state.
Implement-spec ignores this and counts a blocker as done only when its branch has merged into the integration branch.

## fetch-review-comments

For an MR number or URL:

```sh
glab mr view <mr> --comments
glab api --paginate projects/:id/merge_requests/<mr>/discussions
```

The first gives the conversation; `--unresolved` keeps only open discussions.
The second gives every discussion as JSON, with inline notes carrying `position.new_path` and `position.new_line`, and `resolved` on each note.
