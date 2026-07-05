# nix_home_manager

Home-manager configuration using Nix flakes.

## Prerequisites

- Nix 2.17+ with flakes enabled (`experimental-features = nix-command flakes`)
- This repo cloned

## Setup

```bash
# Clone the repo and symlink it
ln -s "$PWD" ~/.config/home-manager

# Or use the install script
./scripts/install_hm.sh
```

## Usage

```bash
# Apply changes
home-manager switch --flake ~/workspace/nix_home_manager

# Or use the helper script
./scripts/hm_switch.sh

# Update nixpkgs & home-manager
nix flake update ~/workspace/nix_home_manager
home-manager switch --flake ~/workspace/nix_home_manager

# List generations
home-manager generations

# Clean up old generations
./scripts/cleanup.sh
```

## Claude Code alias

Typing `claude` runs:
```bash
claude --bare --settings ~/.config/claude-deepseek-settings.json --model sonnet
```

## Zsh Cheatsheet

### Directory Navigation

| Command | Description |
|---------|-------------|
| `z <partial>` | Jump to a frequently-visited directory by fuzzy name (zoxide). e.g. `z nix` → `~/workspace/nix_home_manager` |
| `zi <partial>` | Like `z` but uses fzf for interactive selection |
| `<dirname>` | `autocd` is enabled — just type a directory name to cd into it |
| `..` / `...` | Go up 1 / 2 directories (OMZ `..` / `...` aliases) |
| `l` | `eza` — modern ls |
| `ll` | `eza -alhF` — detailed listing with sizes |
| `la` | `eza -a` — show hidden files |
| `lt` | `eza -T --level=3` — tree view, 3 levels deep |
| `take <dir>` | `mkdir -p <dir> && cd <dir>` (OMZ built-in) |

### File Operations

| Command | Description |
|---------|-------------|
| `cat <file>` | `bat` — syntax-highlighted file viewer with line numbers |
| `fd <pattern>` | Find files/dirs by name (replaces `find`). e.g. `fd config` |
| `rg <pattern>` | Search file contents (ripgrep, replaces `grep -r`). e.g. `rg TODO` |
| `extract <archive>` | Auto-detects format and extracts `.tar.gz`, `.zip`, `.rar`, `.7z`, `.bz2`, etc. |
| `open <file>` | `xdg-open` — open file with default GUI app |
| `tree` | Display directory tree |

### History

| Feature | Description |
|---------|-------------|
| `Ctrl-R` | FZF-powered history search (fuzzy! type any part of the command) |
| `↑` / `↓` | Scroll through history. Type a prefix first to filter (e.g. `ssh` ↑ → cycle through ssh commands) |
| `<space>cmd` | Commands starting with a space are **not** saved to history |
| 50,000 entries | History size, shared across all sessions, timestamps preserved |

### FZF Shortcuts (OMZ fzf plugin)

| Shortcut | Context | Description |
|----------|---------|-------------|
| `Ctrl-T` | Anywhere | Search files, insert selected path at cursor |
| `Ctrl-R` | Anywhere | Search command history, paste selected command |
| `Alt-C` | Anywhere | Search directories, cd into selected |
| `**` + `Tab` | After a path | Trigger fzf completion. e.g. `vim **<Tab>` |

### Kubernetes / Cloud

| Command | Description |
|---------|-------------|
| `k` | `kubectl` (alias) |
| `kgp` | `kubectl get pods` (OMZ kubectl plugin) |
| `kgd` | `kubectl get deployments` |
| `kgs` | `kubectl get services` |
| `kaf <file>` | `kubectl apply -f <file>` |
| `kdf <file>` | `kubectl delete -f <file>` |
| `h` | `helm` (alias) |
| `k9s` | Terminal UI for cluster management |
| `kubectx` / `kubens` | Switch context/namespace (if installed) |

### Git (from OMZ git plugin + custom aliases)

| Shortcut | Git equivalent |
|----------|---------------|
| `gst` | `git status` |
| `gco` | `git checkout` |
| `gbr` | `git branch` |
| `gcm` | `git commit -m` |
| `gcam` | `git commit -a -m` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `glg` | `git log --oneline --graph` |
| `lg` | Pretty git log (custom: colored, graph, relative dates) |
| `grb` | `git rebase` |
| `gsta` | `git stash push` |
| `gstp` | `git stash pop` |

### Vi-Mode (default keymap: viins)

| Shortcut | Description |
|----------|-------------|
| `Esc` / `Ctrl-[` | Switch to **normal** mode |
| `i` / `a` | Enter **insert** mode |
| `h` `j` `k` `l` | Move left/down/up/right (normal mode) |
| `w` / `b` | Jump forward/backward by word |
| `0` / `$` | Jump to start/end of line |
| `/search` | Search history forward |
| `?search` | Search history backward |
| `n` / `N` | Next/previous search match |
| `v` | Open current command in `$EDITOR` (nano) |
| `dd` | Delete entire line |
| `cw` / `dw` | Change/delete word |
| `u` | Undo |
| `Ctrl-R` | Redo |

### Tmux (prefix: `Ctrl-a`)

| Shortcut | Description |
|----------|-------------|
| `Prefix \|` | Split pane vertically |
| `Prefix -` | Split pane horizontally |
| `Prefix e` | Synchronize panes (type in all at once) |
| `Prefix E` | Stop synchronizing panes |
| `Alt-←→↑↓` | Switch between panes |
| `Prefix r` | Reload tmux config |
| `Ctrl-k` | Clear current pane + scrollback |
| `mux` | `tmuxinator` — layout manager |

### Nix / Home-Manager

| Command | Description |
|---------|-------------|
| `reload` | `home-manager switch && source ~/.zshrc` — apply config changes |
| `szsh` | `source ~/.zshrc` — reload shell without rebuild |
| `garbage` | `nix-collect-garbage -d && docker image prune --force` — free disk space |
| `installed` | List all nix-installed packages |

### Other Useful Aliases

| Command | Description |
|---------|-------------|
| `cht <topic>` | [cht.sh](https://cht.sh) — cheat sheets for any language/tool |
| `chts <topic>` | cht.sh with shell-specific examples |
| `claude` | Claude Code with DeepSeek backend |
| `htop` / `top` | `btop` — beautiful resource monitor |
| `pwgen <len>` | Generate random password |

### OMZ Convenience Plugins

| Plugin | What it gives you |
|--------|-------------------|
| `sudo` | Press `Esc` twice to prepend `sudo` to the current/full command |
| `colorize` | `cat`/`less` get automatic syntax highlighting for common formats |
| `colored-man-pages` | Man pages rendered with color-coded sections |
| `extract` | `extract <file>` auto-detects archive format (tar/zip/rar/7z/bz2/…) |
| `z` | `z <partial>` fuzzy-jumps to frequent directories |
| `copyfile` | `copyfile <file>` copies file contents to clipboard |
| `copypath` | `copypath` copies current working directory path to clipboard |
