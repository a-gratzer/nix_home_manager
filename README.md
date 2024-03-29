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

# bash
Add to <code>.bashrc</code>:

    source $HOME/.aliases

# Installs

    sudo dnf install gnome-tweaks 
    sudo dnf install wireguard-tools
    # download and set sdkman_zshrc to tmp file
    # copy stuff to managed zshrc file 
    curl -s "https://get.sdkman.io" | bash

# Terminal
    sdk install java xyz
    sdk install maven xyz
    sdk install visualvm

# Software-Center
    
    RESP.app

# AppAmages

## Lens
    Download: https://github.com/MuhammedKalkan/OpenLens/releases
    copy to /opt/lens/OpenLens.AppImage
    chmod +x /opt/lens/OpenLens.AppImage
