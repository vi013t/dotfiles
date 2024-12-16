local preferences = {
	terminal = "wezterm",
	editor = "nvim",
	profile_picture = "/home/violet/.config/awesome/images/profile.jpeg",
	name = os.getenv("USER"):upper(),
	username = os.getenv("USER") .. "@" .. io.open("/etc/hostname"):read("a"):gsub("\n$", ""),
	apps = {
		calculator = "/home/neph/Documents/Coding/Desktop\\ Apps/honey/src-tauri/target/release/honey",
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
