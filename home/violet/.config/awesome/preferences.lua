local actions = require("misc.actions")

--[[

The preferences file. This file contains loads of customizable preferences that the code will reference.
It's the only file you should really edit unless you really know what you're doing.

--]]

--- Preference and settings for this Awesome configuration.
local preferences = {

	-- Name to show on start menu and sidebar
	name = os.getenv("USER"):upper(),

	-- Username to show on start menu and sidebar
	username = os.getenv("USER") .. "@" .. io.open("/etc/hostname"):read("l"),
}

--- Assets used by the configuration, such as images and sounds.
preferences.assets = {

	--- Image assets.
	images = {

		-- Profile picture to show on start menu and sidebar
		profile_picture = os.getenv("HOME") .. "/.config/awesome/assets/images/profile.jpeg",

		-- Desktop wallpaper
		wallpaper = os.getenv("HOME") .. "/.config/awesome/assets/images/wallpaper_cave.png",
	},

	--- Audio assets.
	sounds = {

		--- The sound played when the volume is changed; Set to `nil` for no sound.
		volume_change = os.getenv("HOME") .. "/.config/awesome/assets/sounds/volume_change.mp3",
	}
}

--- Preferred applications.
preferences.apps = {

	--- The default file explorer app. It's pinned to the taskbar by default (see `preferences.taskbar_pinned_apps`).
	file_explorer = "nemo",

	--- The web browser app to use. It's pinned to the taskbar by default (see `preferences.taskbar_pinned_apps`).
	browser = "firefox",

	--- The calendar app to use. This is what's run when clicking the calendar icon
	--- on the sidebar.
	---
	--- If you change this, you'll likely also want to change `preferences.actions.open_calendar_at`.
	calendar = "firefox --new-tab 'https://calendar.google.com/calendar/u/0/r'",

	--- The chat app to use. It's pinned to the taskbar by default (see `preferences.taskbar_pinned_apps`).
	chat = "discord",

	--- The chat app to use. It's pinned to the taskbar by default (see `preferences.taskbar_pinned_apps`)
	--- and acts as the default terminal for things run by AwesomeWM (see `menubar.utils.terminal` from Awesome)
	terminal = "wezterm",

	--- The default music app. It's pinned to the taskbar by default (see `preferences.taskbar_pinned_apps`)
	music = "spotify-launcher",

	--- The default calculator app. It's opened when clicking the calculator button on the sidebar.
	calculator = "silico-calculator",
}

--- Apps that are pinned to the taskbar, in order.
preferences.taskbar_pinned_apps = {
	preferences.apps.terminal,
	preferences.apps.browser,
	preferences.apps.chat,
	preferences.apps.file_explorer,
	preferences.apps.music,
}

---@alias Keybinding { modifiers?: ("windows" | "shift" | "control" | "alt")[]; key: string; run: fun(widgets: any): nil }

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
	{ modifiers = { "windows" },          key = "Left",                      run = actions.view_previous_tag() },
	{ modifiers = { "windows" },          key = "Right",                     run = actions.view_next_tag() },

	-- Misc
	{ modifiers = { "windows" },          key = "h",                         run = actions.toggle_privacy_mode() },
}

--- Icon overrides
preferences.icon_overrides = {

	--- The default Nemo icon in my icon pack is ugly :(
	nemo = os.getenv("HOME") .. "/.config/awesome/assets/images/file_explorer.png"
}

-- Colors and styling
preferences.theme = {

	--- The primary background color on widgets
	primary_background = "#11111b",

	--- The primary color of text and borders on widgets
	primary_foreground = "#b4befe",

	--- The secondary foreground color for dimmed text
	secondary_foreground = "#6c7086",

	--- The secondary background color for slider backgrounds and such on widgets
	secondary_background = "#1e1e2e",

	--- The color for the maximize button on window titlebars.
	maximize_button = "#a6e3a1",

	--- The color for the minimize button on window titlebars.
	minimize_button = "#f9e2af",

	--- The color for the close button on window titlebars.
	close_button = "#f38ba8",

	--- The background color of the taskbar
	taskbar_background = "#11111b",

	--- The position of the taskbar
	taskbar_position = "bottom",

	--- The margin between widgets and the edge of the screen
	default_margin = 12,

	--- The font to use when displaying text. Note that different fonts can seemingly
	--- display at different sizes and with different spacing; Changing this may require
	--- manually changing some font sizes and spacing numbers throughout the config.
	font = "SF Pro Display",

	--- The border width for widgets and windows. Set to 0 for no borders.
	border_width = 2,

	--- The border color for widgets and windows. To disable borders, set `preferences.theme.border_width = 0`.
	border_color = "#b4befe",

	--- Returns a font using the default font family specified by `preferences.theme.font`, using the
	--- given number as the font size.
	---
	---@param size integer The font size, in pixels.
	---
	---@return string font The font with the given size.
	font_size = function(size)
		return preferences.theme.font .. " " .. tostring(size)
	end,
}

--- Personalizable actions called when certain things are clicked or hotkeys are pressed.
preferences.actions = {

	--- Opens the calendar at the given date. This is called when a day is clicked on the sidebar.
	---
	--- If you wan't to do nothing when clicking a day (i.e. because your calendar doesn't support it)
	--- then just return `nil`.
	---
	---@param year integer The date year
	---@param month integer The date month, in `[1, 12]`
	---@param day integer The date day, in `[1, 31]`
	---
	---@return string | nil command The command to run to open the calendar at the given date.
	open_calendar_at = function(year, month, day)
		return ("firefox --new-tab 'https://calendar.google.com/calendar/u/0/r/day/%s/%s/%s'"):format(year, month, day)
	end,

	--- Screenshots the entire screen.
	screenshot =
		'flameshot full --path "' ..
		os.getenv("HOME") ..
		'/Pictures/Screenshots/' ..
		tostring(os.date("%x")):gsub("/", "_") ..
		" at " ..
		tostring(os.date("%X")):gsub(":|%s", "_") ..
		'"',

	--- Screenshots a section of the screen. This is called when `Windows + Shift + S` is pressed
	--- (unless it's rebound).
	screenshot_section = "flameshot gui",
}

return preferences
