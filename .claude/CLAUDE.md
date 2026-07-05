# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Apply config changes after editing any .nix or template file
./scripts/hm_switch.sh

# Update nixpkgs & home-manager to latest, then apply
./scripts/hm-update.sh

# List generations / rollback
./scripts/list_generations.sh
./scripts/list_generations.sh --rollback        # go back 1
./scripts/list_generations.sh --rollback 3      # go back N

# Free up disk space (dry-run by default)
./scripts/cleanup.sh --doit

# First-time setup on a new machine
./scripts/install_hm.sh
```

`hm_switch.sh` runs `home-manager switch --flake . --show-trace --impure`. The `--impure` flag is required because `home.nix` reads `no_git/.env` at Nix evaluation time via `builtins.readFile`.

## Architecture

### Evaluation flow

```
flake.nix  →  home.nix  →  apps/*.nix
                        →  templates/*  (deployed as home.file entries)
```

**`flake.nix`** defines a single `homeConfigurations."ag"` output pointing to `home.nix`. Uses `nixpkgs-unstable` + `home-manager/master`.

**`home.nix`** does three things:
1. Pulls the DeepSeek API key out of `no_git/.env` **at evaluation time** and injects it into the Claude settings template via `builtins.replaceStrings`. If `no_git/.env` is missing, `home-manager switch` will fail.
2. Imports each app module via `pkgs.callPackage` (not the standard `imports = [...]` pattern). Each module returns an attrset, and `home.nix` picks only the relevant sub-key: `programs.git = (pkgs.callPackage ./apps/git.nix {}).programs.git`.
3. Deploys template files with `home.file`.

### API key injection

`no_git/.env` must contain exactly `DEEPSEEK_API_KEY=<value>` on the first line. The key is parsed with `lib.splitString` and substituted into `templates/claude-deepseek-settings.json` before deployment to `~/.config/claude-deepseek-settings.json` and `~/.claude/settings.json` (with `force = true`, so home-manager overwrites manual edits on every switch).

### Claude Code settings

`templates/claude-deepseek-settings.json` configures Claude Code to route through DeepSeek's Anthropic-compatible API (`https://api.deepseek.com/anthropic`). Current model mapping:
- Opus/Sonnet → `deepseek-v4-pro`
- Haiku → `deepseek-v4-flash`

To switch to native Claude models, set `ANTHROPIC_BASE_URL` to `""` and use an Anthropic key. For a one-off override: `claude --model deepseek-reasoner` or `ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-reasoner claude`.

The `claude` alias (from `templates/.aliases`) runs:
```bash
claude --bare --settings ~/.config/claude-deepseek-settings.json --model sonnet
```

MCP servers configured: `context7` and `web-fetch` (both via `npx`).

### Adding/removing packages

All packages are declared in the `home.packages` list in `home.nix`. Add a package name from nixpkgs, then run `./scripts/hm_switch.sh`.

### Adding a new app module

1. Create `apps/myapp.nix` returning `{ programs.myapp = { ... }; }`.
2. In `home.nix`, add: `programs.myapp = (pkgs.callPackage ./apps/myapp.nix {}).programs.myapp;`

## Secrets & gitignored files

`no_git/` is gitignored. It must contain:
- `.env` — `DEEPSEEK_API_KEY=...` (required for `home-manager switch`)
- `.smbcredentials` — SMB credentials
- `.ssh/` — SSH keys (copied to `~/.ssh/` via `scripts/install_files.sh`)

## Skills

`/commit-push` — stages all changes, scans for secrets, proposes a commit message, and optionally pushes (defined in `.claude/skills/commit-push.md`).
