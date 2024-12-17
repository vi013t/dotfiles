local actions = require("misc.actions")
local awful = require("awful")

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
}

-- Apps that are pinned to the taskbar, in order.
preferences.pinned_apps = {
	preferences.apps.terminal,
	preferences.apps.browser,
	preferences.apps.chat,
	preferences.apps.file_explorer,
}

---@alias Modifier "windows" | "shift" | "control"
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
	{ modifiers = { "windows" },          key = "Left",                      run = awful.tag.viewprev },
	{ modifiers = { "windows" },          key = "Right",                     run = awful.tag.viewnext },

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
}

return preferences
