local awful = require("awful")
local system = require("misc.system")

local actions = {}

--- Returns a function that when called, will raise the volume by the given amount.
---
---@param amount number The amount to raise the volume by.
---
---@return fun(widgets): nil function The function to lower the volume
function actions.raise_volume(amount)
	return function(widgets)
		awful.spawn.easy_async("pamixer --increase " .. amount, function()
			widgets.volume:show()

			-- NOTE: Preferences has to be imported here instead of at the top-level to avoid circular
			-- import dependencies.
			local preferences = require("preferences")

			if preferences.assets.sounds.volume_change then
				awful.spawn.easy_async(
					("ffplay %s -nodisp -autoexit"):format(preferences.assets.sounds.volume_change),
					function() end
				)
			end
		end)
	end
end

--- Returns a function that when called, will lower the volume by the given amount.
---
---@param amount number The amount to lower the volume by.
---
---@return fun(widgets): nil function The function to lower the volume
function actions.lower_volume(amount)
	return function(widgets)
		awful.spawn.easy_async("pamixer --decrease " .. amount, function()
			widgets.volume:show()

			-- NOTE: Preferences has to be imported here instead of at the top-level to avoid circular
			-- import dependencies.
			local preferences = require("preferences")

			if preferences.assets.sounds.volume_change then
				awful.spawn.easy_async(
					("ffplay %s -nodisp -autoexit"):format(preferences.assets.sounds.volume_change),
					function() end
				)
			end
		end)
	end
end

--- Returns a function that when called, will mute the volume.
---
---@return fun(widgets): nil function The function to run
function actions.mute()
	return function(widgets)
		awful.spawn.easy_async("pamixer --set-volume 0", function()
			widgets.volume:show()
		end)
	end
end

--- Returns a function that when called, will raise the brightness by the given amount.
---
---@param amount number The amount to lower the brightness by.
---
---@return fun(widgets): nil function The function to run
function actions.raise_brightness(amount)
	return function(widgets)
		awful.spawn.easy_async("brightnessctl set +" .. tostring(amount) .. "%", function()
			widgets.brightness:show()
		end)
	end
end

--- Returns a function that when called, will lower the brightness by the given amount.
---
---@param amount number The amount to lower the brightness by.
---
---@return fun(widgets): nil function The function to run
function actions.lower_brightness(amount)
	return function(widgets)
		awful.spawn.easy_async("brightnessctl set " .. tostring(amount) .. "%-", function()
			widgets.brightness:show()
		end)
	end
end

--- Returns a function that when called, will run the given command (synchronously).
---
---@param command string The command to run
---
---@return fun(): nil function The function to run
function actions.open(command)
	return function()
		-- NOTE: This *cannot* use awful.easy_async(). For some reason
		-- (unknown to me) it causes errors with certain programs. For example,
		-- Discord would repeatedly crash with "write EPIPE" errors. I don't know the
		-- specifics but using awful.spawn() seems to work; So just as a note to future
		-- me and anyone else wondering why this is synchronous, that's why.
		awful.spawn(command)
	end
end

--- Returns a function that toggles the visibility of the given widget, by name.
---
---@param widget_name "sidebar" | "taskbar" | "alttab"
---
---@return fun(widgets): nil function The function that will toggle visibility for the given widget
function actions.toggle_widget(widget_name)
	return function(widgets)
		widgets[widget_name]:toggle()
	end
end

--- Returns a function that will open the next tag incrementally.
---
---@return fun(widgets): nil function The function to open the next tag.
function actions.view_next_tag()
	return function()
		awful.tag.viewnext()
	end
end

--- Returns a function that will open the previous tag incrementally.
---
---@return fun(widgets): nil function The function to open the previous tag.
function actions.view_previous_tag()
	return function()
		awful.tag.viewprev()
	end
end

--- Returns a function that when called will open the given tag.
---
--- @param tag_number integer The tag number to view
---
--- @return fun(widgets): nil function The function that will view the given tag.
function actions.view_tag(tag_number)
	return function(widgets)
		local screen = awful.screen.focused()
		local tag = screen.tags[tag_number]
		if tag then
			tag:view_only()
			widgets.tags:refresh()
		end
	end
end

--- Returns a function that when called, will move the currently focused client
--- to the given tag number.
---
--- @param tag_number integer The tag to move the client to
---
--- @return fun(): nil function The function to move the client with
function actions.move_client_to_tag(tag_number)
	return function()
		if client.focus then
			local tag = client.focus.screen.tags[tag_number]
			if tag then
				client.focus:move_to_tag(tag)
			end
		end
	end
end

--- Returns a function that will take a screenshot of the entire screen and
--- save it to `~/Pictures/Screenshots/`
---
---@return fun(): nil function The function to take a screenshot
function actions.screenshot()
	return function()
		-- NOTE: Preferences has to be imported here instead of at the top-level to avoid circular
		-- import dependencies.
		awful.spawn(require("preferences").actions.screenshot)
	end
end

--- Returns a function that will take a screenshot of a rectangular section of
--- the screen.
---
---@return fun(widgets): nil function The function to take a screenshot
function actions.screenshot_section()
	return function(widgets)
		widgets.tags.visible = false
		-- NOTE: Preferences has to be imported here instead of at the top-level to avoid circular
		-- import dependencies.
		awful.spawn(require("preferences").actions.screenshot_section)
	end
end

--- Returns a function that toggles "protection mode". This hides various location-specific
--- things, such as wifi SSID name, weather, etc., so that screenshots can be taken and shared
--- publicly without risk of giving away location information.
---
--- @return fun(): nil function The function to toggle wifi hiding.
function actions.toggle_privacy_mode()
	return function()
		system.wifi.toggle_hidden()
	end
end

return actions
