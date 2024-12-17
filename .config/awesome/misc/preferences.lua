local preferences = {
	terminal = "wezterm",
	editor = "nvim",
	profile_picture = os.getenv("HOME") .. "/.config/awesome/assets/images/profile.jpeg",
	name = os.getenv("USER"):upper(),
	username = os.getenv("USER") .. "@" .. io.open("/etc/hostname"):read("a"):gsub("\n$", ""),
	apps = {
		calculator = "honey",
		file_explorer = "nemo --geometry=1000x650",
		browser = "firefox",
		chat = "discord",
	},
}

preferences.editor_cmd = preferences.terminal .. " -e " .. preferences.editor
preferences.apps.calendar = preferences.apps.browser .. " --new-tab 'https://calendar.google.com/calendar/u/0/r'"

preferences.pinned_apps = {
	preferences.terminal,
	preferences.apps.browser,
	preferences.apps.chat,
	preferences.apps.file_explorer,
}

return preferences
