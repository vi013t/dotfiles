local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")

local keys = {}
keys.modkey = "Mod4"

local other_key_was_pressed = false

-- Returns a function that notes that an action was done, and then calls the action given to it.
-- Used to make sure the start menu doesn't open when other actions are called.
--
---@param action function
--
---@return function
local function f(action)
	return function(...)
		other_key_was_pressed = true
		return action(...)
	end
end

--- Called when the windows key is pressed. Opens the tag widget.
---
---@param widgets any The widgets.
local function on_windows_key_press(widgets)
	widgets.tags:show()
end

--- Called when the windows key is released. Closes the tag and alt-tab widgets,
--- and opens te menu if no other key was pressed.
---
---@param widgets any The widgets.
local function on_windows_key_released(widgets)
	widgets.tags:hide()
	widgets.alttab:hide()
	if not other_key_was_pressed then
		widgets.menu:toggle()
	else
		other_key_was_pressed = false
	end
end

function keys.setup(widgets)
	local windows = keys.modkey
	local windows_key_code = "#133"

	local global_keys = gears.table.map(function(keybinding)
		local mods = {}
		if keybinding.modifiers then
			mods = gears.table.map(function(modifier)
				local modifiers = {
					windows = windows,
					shift = "Shift",
					control = "Control",
					alt = "Alt_L",
				}

				return modifiers[modifier]
			end, keybinding.modifiers)
		end

		return awful.key(mods, keybinding.key, f(function() keybinding.run(widgets) end), keybinding.on_release)
	end, preferences.keys)

	keys.globalkeys = gears.table.join(
		awful.key({}, windows_key_code, function() on_windows_key_press(widgets) end, function() end),
		awful.key({ windows }, windows_key_code, function() end, function() on_windows_key_released(widgets) end),
		awful.key({ windows }, "Tab", f(function()
			widgets.alttab:cycle()
			widgets.tags:hide()
		end)),
		table.unpack(global_keys)
	)

	-- Client keys (These generally use mod + ctrl)
	keys.clientkeys = gears.table.join(
		awful.key({ windows, "Control" }, "f", f(function(c) c.fullscreen = not c.fullscreen end)),
		awful.key({ windows, "Control" }, "q", function(c) c:kill() end),
		awful.key({ windows, "Control" }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end)
	)
end

return keys
