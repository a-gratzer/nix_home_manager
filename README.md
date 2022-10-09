# nix_home_manager

	export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
	export XDG_DATA_DIRS="/home/your_user/.nix-profile/share:$XDG_DATA_DIRS"

# WireGui
Download wiregui from
https://github.com/WireGuard/wireguard-tools
and extract the AppImage to
```/opt/wireguard/wiregui.AppImage```
