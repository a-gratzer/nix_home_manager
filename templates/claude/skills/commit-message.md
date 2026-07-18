---
description: Create conventional git commit messages from staged changes. Analyzes diffs, classifies commit type, supports optional gitmoji, and handles branching — with user approval at each step.
tools: Read, Bash, Glob
triggers:
  - "create (a |the )?commit message"
  - "generate (a |the )?commit message"
  - "write (a |the )?commit message"
  - "make (a |the )?commit"
  - "commit (my |the |these |this )?changes?"
  - "commit (with |using )?(git)?moji"
  - "/commit-message"
  - "suggest (a |the )?commit"
  - "what should (I |we )?commit"
  - "prepare (a |the )?commit"
  - "draft (a |the )?commit"
  - "stage and commit"
  - "git commit"
---

# Git Commit Message Skill

Use this skill whenever you need to generate a semantic git commit message from staged changes. The skill handles staging, branch management, commit generation, and pushing — all with explicit user approval at each step.

## Step 1: Check for Staged Changes

```bash
git status
```

- If output contains **`Changes not staged for commit`** or **`Untracked files`**: prompt the user to stage them first (ask: *"You have unstaged changes. Would you like me to stage them?"*). Stage with `git add <files>` or `git add -A` depending on their preference.
- If output contains **`nothing to commit, working tree clean`**: respond with *"No changes found. Please make changes to your files before trying to commit."* and exit.

Only proceed once all intended changes are staged and there are no remaining unstaged changes.

## Step 2: Review Staged Changes

```bash
# Full diff of staged changes
git diff --cached

# Summary with file names and line counts
git diff --cached --stat
```

Analyze the diff output to understand:
- Which files were modified, added, or deleted
- What functionality changed
- The purpose and impact of the changes
- Scope: which area of the codebase is affected (e.g., auth, api, ui, config, ci, docs)

## Step 3: Check Current Branch

```bash
git branch --show-current
```

- If the current branch is **`main`**, **`master`**, **`dev`**, or **`development`**:
  1. Determine an appropriate branch type and short task description from the changes
  2. Generate a branch name in the format `<type>/<task-description>` (see branch naming below)
  3. Prompt: *"You're on the `<branch>` branch. Would you like me to create the branch `<suggested-branch-name>` for this commit?"*
  4. If confirmed, create and switch: `git switch -c <branch-name>`
  5. If declined, continue committing on the current branch (with an extra confirmation below)

### Branch Naming Format

```
<type>/<task-description>
```

| Type     | Usage                                          |
|----------|------------------------------------------------|
| feature  | New feature for the user                       |
| fix      | Bug fix for the user                           |
| docs     | Documentation changes                          |
| style    | Formatting, missing semicolons, etc.           |
| refactor | Refactoring production code                    |
| test     | Adding missing tests, refactoring tests        |
| chore    | Build tooling, deps, nothing user-facing       |

Examples: `feature/add-user-auth`, `fix/null-response-handling`, `docs/update-install-guide`, `refactor/simplify-data-logic`

Be specific rather than generic: prefer `feature/switch-to-branch` over `feature/update-commit-skill`.

## Step 4: Determine Emoji Usage

Scan the user's original request for keywords: **"emoji"**, **"gitmoji"**, **"with emoji"**, **"use emoji"**.

- **Default (no keywords found)**: Generate the commit message in standard format WITHOUT emojis.
- **Explicitly requested**: Prepend the matching emoji before the commit type.

## Step 5: Generate Commit Message

Follow the conventional commits format:

```
[emoji] type(scope): subject

body

footer
```

### Commit Types

| Type     | Description                                   | Emoji |
|----------|-----------------------------------------------|-------|
| feat     | A new feature                                 | ✨    |
| fix      | A bug fix                                     | 🐛    |
| docs     | Documentation changes                         | 📚    |
| style    | Code formatting, no logic changes             | 💄    |
| refactor | Code restructuring, no feature or fix         | ♻️    |
| perf     | Performance improvements                      | ⚡    |
| test     | Adding or updating tests                      | ✅    |
| chore    | Build process, dependencies, tooling          | 🔨    |
| ci       | CI/CD changes                                 | 👷    |
| build    | Build system or external dependencies         | 📦    |
| revert   | Reverting a previous commit                   | ⏮️    |
| security | Security fixes                                | 🔒    |
| deps     | Dependency updates                            | 📦    |

### Guidelines

- **Subject line under 50 characters**, all lowercase
- **Imperative mood**: "add feature" not "added feature"
- **Include scope when relevant** to identify the affected codebase area
- **Body**: bulleted list, explain why/what in more detail, max 6 bullet points, one item per line
- **Footer**: reference issues when applicable (`Closes #123`, `Fixes #456`)
- **Be descriptive rather than technical**: explain what changed from a functional perspective
- Do **NOT** add `Co-Authored-By` trailers — commits should only show the user as the author

### Examples

**Without emoji:**
```
feat(auth): add two-factor authentication

- Enables TOTP-based 2FA for enhanced security
- Users can enable in account settings
- Compatible with any authenticator app

Closes #234
```

**With emoji:**
```
✨ feat(auth): add two-factor authentication

- Enables TOTP-based 2FA for enhanced security
- Users can enable in account settings

Closes #234
```

## Step 6: Present for Review

Display the generated commit message in this format:

````markdown
Here's the suggested commit message based on your staged changes:

```
<generated commit message>
```
````

Prompt: *"Would you like me to create this commit?"*

## Step 7: Final Branch Check

Before committing, run `git branch --show-current` one final time.

- If still on **`main`**, **`master`**, **`dev`**, or **`development`**: prompt *"You are about to commit directly to `<branch>`. Are you sure?"* If declined, exit.
- If on a feature/fix branch: proceed.

## Step 8: Create the Commit

Once approved, create the commit:

```bash
git commit -m "<subject>" -m "<body with footer>"
```

Do **not** run this command without user approval.

## Step 9: Offer to Push

Prompt: *"Would you like me to push this to the remote?"*

Upon confirmation:
```bash
git push
```

## Important Rules

- **Always ask for approval** before `git commit` and `git push` — never execute them automatically.
- **Never add Co-Authored-By trailers**. Commits should only show the user as the author.
- **Analyze all staged files**. If many files are staged, review each one to ensure the commit message accurately reflects all changes.
- **If changes span multiple concerns**, suggest splitting into multiple commits rather than one large commit.
