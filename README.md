# nix_home_manager

If gui programs are not showing up in gnome-search, then add 

	export XDG_DATA_DIRS="/home/your_user/.nix-profile/share:$XDG_DATA_DIRS"

to .profile or .bashrc pr .zshrc.

Restart your machine afterwards!