# nix_home_manager

	export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
	export XDG_DATA_DIRS="/home/your_user/.nix-profile/share:$XDG_DATA_DIRS"

# Set default shell

    command -v zsh | sudo tee -a /etc/shells
    sudo chsh -s $(which zsh) $USER

# Install sdkman

    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"

# Fedora - dnf conf
    sudo nano /etc/dnf/dnf.conf

```text
# see `man dnf.conf` for defaults and possible options

[main]
gpgcheck=True
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
# Custom
fastestmirror=True
max_parallel_downloads=15
keepcache=True
defaulttypes=True
color_list_available_upgrade=True
color_search_match=True
color_update_installed=True

```

# Installs

    sudo dnf install gnome-tweaks 