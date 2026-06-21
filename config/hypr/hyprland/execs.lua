-- ~/.config/hypr/hyprland/execs.lua
hl.on("hyprland.start", function()
	local startup = {
		"awww-daemon",
		"wal --theme catppuccin-mocha-pink -n -q",
		"systemctl --user start hypridle",
		"kitty",
		"brave",
		"obsidian",
		"wl-paste --type text --watch cliphist store",
		"wl-paste --type image --watch cliphist store",
		"/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1",
		"sleep 1 && QS_DROP_EXPENSIVE_FONTS=1 quickshell -p /home/s4m8/.config/quickshell",
		"~/.config/scripts/random-wallpaper.sh",
	}
	for _, cmd in ipairs(startup) do
		hl.exec_cmd(cmd)
	end
end)
