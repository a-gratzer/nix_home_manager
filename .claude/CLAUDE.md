# nix_home_manager

Home-manager configuration for user **ag** (Andreas Gratzer).

## Architecture

### Entry Point
- **`flake.nix`** — Flake entry point using `github:NixOS/nixpkgs/nixpkgs-unstable` and `github:nix-community/home-manager/master`. Handles `allowUnfree = true` and `allowInsecure = true`.
- **`home.nix`** — Main Nix module that imports all app modules and declares home-manager state (username `ag`, home directory `/home/ag`, state version `25.05`). Also injects the DeepSeek API key into the Claude Code settings template.

### Nix Version
- Nix: **2.34.7** (upgraded from 2.15.0)
- Flakes enabled with `experimental-features = nix-command flakes`

### App Modules (`apps/`)
Each file returns a Nix module consumed by `home.nix`:

| File | Manages |
|---|---|
| `zsh.nix` | ZSH shell with oh-my-zsh (theme `gnzh`), zsh-syntax-highlighting, zsh-autosuggestions, fzf-tab, broot |
| `git.nix` | Git: user name/email, aliases (`st`, `co`, `br`, `f`, `m`, `lg`), meld as difftool/mergetool, Chrome as web browser, vim as editor |
| `tmux.nix` | Tmux: prefix `C-a`, mouse on, base-index 1, `|`/`-` for splits, alt-arrows for pane switching |
| `neovim/defaults.nix` | Neovim: vi/vim aliases, LSP servers (pyright, lua-lsp, rnix-lsp, bash-language-server, etc.), ~30+ plugins (mostly commented out). Loads `init.lua` |
| `neovim/plugins.nix` | Custom vim plugin derivations: `neoscroll-nvim`, `indent-blankline-nvim` |
| `direnv.nix` | Direnv with nix-direnv + ZSH integration |
| `ssh.nix` | SSH program enable (host configs are in `templates/ssh/config`) |

### Templates (`templates/`)
Files deployed to `~/.config/` or `~/`:

| File | Destination |
|---|---|
| `claude-deepseek-settings.json` | `~/.config/claude-deepseek-settings.json` (DeepSeek API key injected from `no_git/.env`) |
| `ssh/config` | `~/.ssh/config` |
| `.aliases` | `~/.aliases` (sourced by ZSH) |
| `neofetch/config.conf` | `~/.config/neofetch/config.conf` |
| `neofetch/terminal-ascii.txt` | `~/.config/neofetch/terminal-ascii.txt` |

### Scripts (`scripts/`)
Scripts organized by purpose (numbered 1–5):

| # | Script | Purpose |
|---|---|---|
| 1 | `install_hm.sh` | **Initial setup** on a new computer — checks Nix, flakes, installs home-manager, symlinks repo, activates |
| 2 | `hm-update.sh` | **Update all software** — updates flake lockfile (nixpkgs + home-manager) then applies |
| 3 | `hm_switch.sh` | **Apply config changes** — runs `home-manager switch --flake .` after editing configs |
| 4 | `list_generations.sh` | **Show generations & rollback** — `--rollback [N]` to go back N generations |
| 5 | `cleanup.sh` | **Free up disk space** — expires old HM generations (>30d), runs `nix store gc`; dry-run by default, use `--doit` to execute |
| - | `install_files.sh` | Utility: copy SSH keys from `no_git/.ssh` to `~/.ssh` |

### Secrets (`no_git/` — gitignored)
- `no_git/.env` — Contains `DEEPSEEK_API_KEY` (injected into `claude-deepseek-settings.json`)
- `no_git/.smbcredentials` — SMB credentials (deployed to `~/.smbcredentials`)
- SSH keys are expected at `no_git/.ssh/`

### Packages
Key packages installed globally:
- **Utils**: openssl, pwgen, btop-rocm, jq, yq, bat, eza, fd, ripgrep, fzf, tldr, tree
- **K8s/Cloud**: kubectl, kubelogin-oidc, kubectl-cnpg, helm, kustomize, talosctl, cilium-cli, hubble, argocd, argo, k9s, cloudflared, awscli2
- **Dev**: git, just, gnumake, go-protobuf, nodejs_20, protobuf_21
- **Virtualization**: podman, docker-compose
- **GUI**: sublime4, discord, flameshot, kazam, remmina, charles
- **Other**: mongodb-tools, wireguard-tools, ansible_2_17, postgresql_17_jit, k6, gnome-browser-connector

## Workflow

### 1. Initial setup (new computer)
```bash
git clone https://github.com/a-gratzer/nix_home_manager.git ~/workspace/nix_home_manager
cd ~/workspace/nix_home_manager
./scripts/install_hm.sh
```

### 2. Update all software
```bash
./scripts/hm-update.sh
```

### 3. Apply config changes (after editing)
```bash
./scripts/hm_switch.sh
```

### 4. List & rollback generations
```bash
./scripts/list_generations.sh          # list
./scripts/list_generations.sh --rollback     # go back 1 generation
./scripts/list_generations.sh --rollback 3   # go back 3 generations
```

### 5. Free up disk space
```bash
./scripts/cleanup.sh                   # dry run
./scripts/cleanup.sh --doit            # actually clean
```

## ZSH Environment
- Default shell with oh-my-zsh (theme `gnzh`)
- Plugins: git, aws, docker, npm, pip, python, sudo, systemd, vi-mode, colorize, colored-man-pages
- SDKMAN loaded for Java/Maven/VisualVM management
- Vault integration (`VAULT_ADDR=https://vault.gratzer.cloud`)
- Neofetch runs on terminal start (using custom ASCII art)
- Custom aliases sourced from `~/.aliases`

## Git Configuration
- User: Andreas Gratzer `<gratzer.andreas@gmail.com>`
- Diff/Merge tool: meld
- Web browser for git: Chrome
- Editor: vim

## Claude Code (DeepSeek)
Claude Code is configured to route through DeepSeek's Anthropic-compatible API endpoint (`https://api.deepseek.com/anthropic`). The API key is injected from `no_git/.env` via Nix string replacement.

### Switching models
- **DeepSeek Chat**: set `ANTHROPIC_DEFAULT_OPUS_MODEL` to `"deepseek-chat"`
- **DeepSeek Reasoner (R1)**: set `ANTHROPIC_DEFAULT_OPUS_MODEL` to `"deepseek-reasoner"`
- **Claude models**: point `ANTHROPIC_BASE_URL` to `""` and use an Anthropic API key

### One-off model override
```bash
claude --model deepseek-reasoner
# or
ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-reasoner claude
```

## Tmux
- Prefix: `C-a` (rebound from `C-b`)
- Pane splits: `|` (horizontal), `-` (vertical)
- Pane navigation: `Alt + arrow keys`
- Sync panes: `prefix + e` (on), `prefix + E` (off)
- Default shell: ZSH
- History limit: 5000

## Neovim
- Leader key: Space
- Relative line numbers
- Tabs/shiftwidth: 4
- Color scheme: desert
- Colorizer plugin active

## SSH Config
Multiple hosts configured with port 2222, user `ag`, identity file `~/.ssh/ag`:
- `contabo01` → `156.67.31.241`
- `contabo01_wg` → `10.99.0.2`
- `homelab01` → `192.168.68.100`
- `homelab01_wg` → `10.99.0.3`
- Various IP-based hosts (194.163.*, 192.168.*, 10.99.*, 10.50.*)
- GitHub/Bitbucket use `~/.ssh/id_ag_laptop`
