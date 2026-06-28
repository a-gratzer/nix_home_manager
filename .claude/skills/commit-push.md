---
description: Stage all changes, create a short commit message summarizing changes, and push after confirmation
---

## Commit & Push

1. Run `git add -A` to stage all changes.
2. Run `git diff --cached --stat` to see what's staged.
3. **Security check:** Scan all staged diffs (`git diff --cached`) for patterns that look like secrets:
   - `sk-...` (API keys like `sk-ant`, `sk-your-key`, etc.)
   - `-----BEGIN.*PRIVATE KEY-----` (private keys)
   - `password`/`passwd`/`PASSWORD` in context that suggests a literal secret (not a config key name)
   - `secret`/`SECRET` in value context
   - `token`/`TOKEN` in value context
   - `auth`/`AUTH` containing credential-like values
   - Credential files (`.env`, `.pem`, `.key`, `credentials`, `secrets`)
   - Any file in a path matching `no_git/` or `ignore/` or `secrets/`
   
   If any secrets are detected:
   - List the exact filenames and the types of secrets found
   - **Abort the commit** — do NOT proceed
   - Tell the user: *"Commit aborted: potential secrets detected in the staged files above. Please remove them and try again."*
   
4. Based on the staged changes, write a short one-line commit message that summarizes the changes (like `"feat: add XYZ"` or `"fix: correct ABC"`).
5. Present the commit message to the user and ask for confirmation before committing.
6. Once confirmed, commit with `git commit -m "<message>"`.
7. Then ask the user: **"Push to remote?"** — wait for explicit confirmation.
8. If confirmed, run `git push`.
9. If declined, just print `"Push skipped."`
