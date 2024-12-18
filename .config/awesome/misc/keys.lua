local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")

local public = {}
public.modkey = "Mod4"

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

-- Called when the modkey is pressed
local function modkey_pressed(widgets)
	widgets.tags:open()
end

-- Called when the modkey is released
local function modkey_released(widgets)
	widgets.tags:close()
	if not other_key_was_pressed then
		widgets.menu:toggle()
	else
		other_key_was_pressed = false
	end
end

function public.setup(widgets)
	local windows = public.modkey
	local windows_key_code = "#133"

	local global_keys = gears.table.map(function(keybinding)
		local mods = {}
		if keybinding.modifiers then
			mods = gears.table.map(function(modifier)
				local modifiers = {
					windows = windows,
					shift = "Shift",
					control = "Control"
				}

				return modifiers[modifier]
			end, keybinding.modifiers)
		end

		return awful.key(mods, keybinding.key, f(function() keybinding.run(widgets) end))
	end, preferences.keys)

	public.globalkeys = gears.table.join(
		awful.key({}, windows_key_code, function() modkey_pressed(widgets) end, function() end),
		awful.key({ windows }, windows_key_code, function() end, function() modkey_released(widgets) end),
		table.unpack(global_keys)
	)

	-- Client keys (These generally use mod + ctrl)
	public.clientkeys = gears.table.join(
		awful.key({ windows, "Control" }, "f", f(function(c) c.fullscreen = not c.fullscreen end)),
		awful.key({ windows, "Control" }, "q", function(c) c:kill() end),
		awful.key({ windows, "Control" }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end)
	)

	-- Tags
	for tag_number = 1, 9 do
		public.globalkeys = gears.table.join(
			public.globalkeys,

			-- Move client to tag.
			awful.key({ public.modkey, "Shift" }, "#" .. tag_number + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[tag_number]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end, { description = "move focused client to tag #" .. tag_number, group = "tag" })
		)
	end
end

return public
