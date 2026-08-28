---
description: Run the adversarial review board (security, correctness, tests, framework) over a diff
argument-hint: "[branch | commit range | repo path]  (default: uncommitted changes in CWD's repo)"
allowed-tools: Bash, Read, Grep, Glob, Task, Agent
---

Run the adversarial review board over a diff. Four read-only reviewers run in
parallel, each handling one lane and one output heading.

## 1. Resolve the target and capture the diff

Target: `$ARGUMENTS` — if empty, review the uncommitted changes in the repo
containing the current working directory.

This is a multi-repo workspace of independent git checkouts. First determine the
repo under review (`git rev-parse --show-toplevel`); every command below runs
with `git -C <repo>`.

Choose the diff command to match the target:
- no argument → `git -C <repo> diff HEAD`
- a branch name → `git -C <repo> diff $(git -C <repo> merge-base HEAD <branch>)..HEAD`
- a commit range → `git -C <repo> diff <range>`
- a repo path → resolve that path to its own toplevel and diff its uncommitted changes

Write the diff to `<repo>/.git/claude-review/diff.patch` (inside `.git`, so it is
never committed and never tracked — `mkdir -p` it first). Also record the list of
changed files.

If the diff is empty, stop and say so. Do not spawn agents against an empty diff.

## 3. Fan out — one message, parallel Task calls

Spawn the selected agents in a **single message with multiple subagent calls** so
they run concurrently. Give each one:
- the absolute path to `diff.patch`
- the absolute path to the repo root to read for context
- the changed-file list
- the target description (branch, range, or "uncommitted")

Do not summarize the diff for them or pre-filter what to look at — they read it
themselves. Do not share one agent's findings with another; independent judgment
is the whole point of a board.

## 4. Assemble the report

The four headings do not collide (`## Security`, `## Correctness`,
`## Tests & Coverage`, `## Framework & State`) — concatenate them in that order
under a short preamble naming the target, the repo, and the changed-file count.

Then add a `## Board verdict` section:
- Count findings by severity across all lanes.
- List every CRITICAL and HIGH finding as a single line each, most severe first.
- Note where two lanes flagged the same file:line from different angles — that
  convergence is the strongest signal the board produces.
- Give one recommendation: block, fix-then-merge, or merge as-is.

Do not drop or soften a finding because another agent disagreed, and do not add
findings of your own — you are the chair, not a fifth member. Report a clean
lane as clean; an empty board verdict is a real result.

## 5. Do not fix anything

The board is read-only, and so are you for this command. Present findings and
stop. If the user wants the findings applied, they will ask — at that point,
hand the fixes to `evo-developer`, `legacy-developer`, or `devops-engineer`.
