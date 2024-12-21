--[[

AwesomeWM configuration

--]]

pcall(require, "luarocks.loader") -- Check luarocks packages if luarocks is installed

-- Standard awesome libraries
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful") -- Theme handling library
local menubar = require("menubar")
require("awful.autofocus")
require("awful.hotkeys_popup.keys")

-- Preferences
local preferences = require("preferences")

-- Startup programs
require("misc.startup")

-- Initialize theme
beautiful.init(os.getenv("HOME") .. "/.config/awesome/misc/theme.lua")

-- Initialize widgets
local sidebar = require("widgets.sidebar")
local tags = require("widgets.tags")
local volume_bar = require("widgets.volume")
local brightness_bar = require("widgets.brightness")
local launcher = require("widgets.launcher")
local menu = require("widgets.menu").setup(launcher.widget)
local taskbar = require("widgets.taskbar")
local alttab = require("widgets.alttab")

-- Style notifications
require("widgets.notification")

-- Initialize hotkeys
local keys = require("misc.keys")
keys.setup({
	sidebar = sidebar.widget,
	menu = menu.widget,
	tags = tags.widget,
	volume = volume_bar.widget,
	brightness = brightness_bar.widget,
	launcher = launcher.widget,
	taskbar = taskbar.widget,
	search = menu.search,
	alttab = alttab.widget,
})

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
}

-- Menubar configuration
menubar.utils.terminal = preferences.apps.terminal -- Set the terminal for applications that require it

--- Sets the wallpaper to the given file.
local function set_wallpaper(file_name)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(file_name)
		end
		gears.wallpaper.maximized(wallpaper, file_name, true)
	end
end
screen.connect_signal("property::geometry", set_wallpaper)

-- Tags
awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end)

-- Set keys
--root.buttons(gears.table.join(awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))
root.keys(keys.globalkeys)

require("misc.window")

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c) -- Prevent clients from being unreachable after screen count changes.
	end
	awful.placement.centered(c)
end)
