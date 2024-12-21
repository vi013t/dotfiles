local actions = require("misc.actions")

local preferences = {

	-- Profile picture to show on start menu and sidebar
	profile_picture = os.getenv("HOME") .. "/.config/awesome/assets/images/profile.jpeg",

	-- Name to show on start menu and sidebar
	name = os.getenv("USER"):upper(),

	-- Username to show on start menu and sidebar
	username = os.getenv("USER") .. "@" .. io.open("/etc/hostname"):read("a"):gsub("\n$", ""),

}

-- Applications
preferences.apps = {
	file_explorer = "nemo",
	browser = "firefox",
	calendar = "firefox --new-tab 'https://calendar.google.com/calendar/u/0/r'",
	chat = "discord",
	terminal = "wezterm",
	editor = "nvim",
	calculator = "silico-calculator"
}

-- Apps that are pinned to the taskbar, in order.
preferences.pinned_apps = {
	preferences.apps.terminal,
	preferences.apps.browser,
	preferences.apps.chat,
	preferences.apps.file_explorer,
}

---@alias Modifier "windows" | "shift" | "control" | "alt"
---@alias Keybinding { modifiers?: Modifier[]; key: string; run: fun(widgets: any): nil }

--- Global keybindings.
---
--- Fields:
--- - `modifiers` - modifiers for the key.
--- - `key` - The main key pressed
--- - `run` - Function to call when the key was pressed.
---
---@type Keybinding[]
preferences.keys = {

	-- AwesomeWM Core
	{ modifiers = { "windows" },          key = "r",                         run = awesome.restart },
	{ modifiers = { "windows" },          key = "q",                         run = awesome.quit },
	{ modifiers = { "windows" },          key = "Left",                      run = actions.previous_tag() },
	{ modifiers = { "windows" },          key = "Right",                     run = actions.next_tag() },

	-- Widgets
	{ modifiers = { "windows" },          key = "`",                         run = actions.toggle_widget("sidebar") },
	{ modifiers = { "windows" },          key = "b",                         run = actions.toggle_widget("taskbar") },

	-- Programs
	{ modifiers = { "windows" },          key = "Return",                    run = actions.open(preferences.apps.terminal) },
	{ modifiers = { "windows", "shift" }, key = "f",                         run = actions.open(preferences.apps.browser) },
	{ modifiers = { "windows", "shift" }, key = "d",                         run = actions.open(preferences.apps.chat) },
	{ modifiers = { "windows", "shift" }, key = "e",                         run = actions.open(preferences.apps.file_explorer) },
	{ modifiers = { "windows", "shift" }, key = "s",                         run = actions.screenshot_section() },
	{ key = "Print",                      run = actions.screenshot() },

	-- Volume
	{ key = "XF86AudioRaiseVolume",       run = actions.raise_volume(10) },
	{ key = "XF86AudioLowerVolume",       run = actions.lower_volume(10) },
	{ key = "XF86AudioMute",              run = actions.mute() },
	{ modifiers = { "shift" },            key = "XF86AudioLowerVolume",      run = actions.lower_volume(3) },
	{ modifiers = { "shift" },            key = "XF86AudioRaiseVolume",      run = actions.raise_volume(3) },

	-- Brightness
	{ key = "XF86MonBrightnessUp",        run = actions.raise_brightness(10) },
	{ key = "XF86MonBrightnessDown",      run = actions.lower_brightness(10) },
	{ modifiers = { "shift" },            key = "XF86MonBrightnessUp",       run = actions.raise_brightness(3) },
	{ modifiers = { "shift" },            key = "XF86MonBrightnessDown",     run = actions.lower_brightness(3) },

	-- Tags
	{ modifiers = { "windows" },          key = "1",                         run = actions.view_tag(1) },
	{ modifiers = { "windows" },          key = "2",                         run = actions.view_tag(2) },
	{ modifiers = { "windows" },          key = "3",                         run = actions.view_tag(3) },
	{ modifiers = { "windows" },          key = "4",                         run = actions.view_tag(4) },
	{ modifiers = { "windows" },          key = "5",                         run = actions.view_tag(5) },
	{ modifiers = { "windows", "shift" }, key = "1",                         run = actions.move_client_to_tag(1) },
	{ modifiers = { "windows", "shift" }, key = "2",                         run = actions.move_client_to_tag(2) },
	{ modifiers = { "windows", "shift" }, key = "3",                         run = actions.move_client_to_tag(3) },
	{ modifiers = { "windows", "shift" }, key = "4",                         run = actions.move_client_to_tag(4) },
	{ modifiers = { "windows", "shift" }, key = "5",                         run = actions.move_client_to_tag(5) },
}

-- Taskbar icon overrides
preferences.icon_overrides = {
	nemo = os.getenv("HOME") .. "/.config/awesome/assets/images/file_explorer.png"
}

return preferences
