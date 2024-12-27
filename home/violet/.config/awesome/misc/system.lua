local awful = require("awful")
local naughty = require("naughty")

--- Information about the device, such as wifi information, battery information, etc.
local system = {}

--- Information about the current battery status, such as percentage, whether it's
--- charging, an appropriate icon based on percentage, etc.
system.battery = {

	--- Watches the system's battery percent and keeps the given texbox widget updated to
	--- reflect that percent.
	---
	---@param base_widget any The widget to update with the battery percent
	---@param format nil | fun(percent: string, icon: string): string A function to format the output,
	--- taking the battery percent and icon as arguments. If `nil`, the widget will be updated to just
	--- show the percent number.
	keep_updated = function(base_widget, format)
		return awful.widget.watch("cat /sys/class/power_supply/BAT0/capacity", 1, function(widget, stdout)
			local success, error_message = pcall(function()
				local percent = tonumber(stdout:match("(%d+)"))
				local icon = system.battery.icon(percent)
				widget:set_text(format and format(tostring(percent), icon) or tostring(percent))
			end)

			if not success then
				naughty.notify({
					title = "Error updating battery",
					text = tostring(error_message),
					preset = naughty.config.presets.critical,
				})
			end
		end, base_widget)
	end,

	--- Returns the current battery percentage as a number.
	---
	---@return number percent The battery percentage.
	percent = function()
		return assert(tonumber(io.open("/sys/class/power_supply/BAT0/capacity"):read("a")))
	end,

	-- Returns an icon for the battery based on the current state.
	--
	---@return string icon The battery icon.
	icon = function(percent)
		local battery_icons = {
			"󰂎", -- 00% - 10%
			"󰁻", -- 10% - 20%
			"󰁼", -- 20% - 30%
			"󰁽", -- 30% - 40%
			"󰁾", -- 40% - 50%
			"󰁿", -- 50% - 60%
			"󰂀", -- 60% - 70%
			"󰂁", -- 70% - 80%
			"󰂂", -- 80% - 90%
			"󰁹", -- 90% - 100%
			"󰁹", -- 100%
		}

		local charging_icons = {
			"󰢜", -- 00% - 10%
			"󰂆", -- 10% - 20%
			"󰂇", -- 20% - 30%
			"󰂈", -- 30% - 40%
			"󰢝", -- 40% - 50%
			"󰂉", -- 50% - 60%
			"󰢞", -- 60% - 70%
			"󰂊", -- 70% - 80%
			"󰂋", -- 80% - 90%
			"󰂅", -- 90% - 100%
			"󰂅", -- 100%
		}

		local icon_set = battery_icons
		if system.battery.is_charging() then
			icon_set = charging_icons
		end

		return icon_set[math.floor((percent or system.battery.percent()) / 10.0) + 1]
	end,

	--- Returns whether the battery is currently charging.
	---
	---@return boolean is_charging Whether the battery supply is currently charging.
	is_charging = function()
		return io.open("/sys/class/power_supply/BAT0/status"):read("a"):match("%s*([^%s]+)%s*") == "Charging"
	end
}

--- Information about the currently connected wifi network, such as connection strength,
--- SSID name, etc.
system.wifi = {

	--- Returns the SSID name of the currently connected wifi.
	---
	---@return string | nil ssid The name of the current wifi network, or `nil` if the device isn't connected.
	name = function()
		local output = io.popen("iwgetid -r"):read("a"):gsub("\n$", "")
		if output == "" then return nil end
		if system.wifi.__is_hidden then return "Hidden" end
		return output
	end,

	--- Returns whether this system is currently connected to wifi.
	---
	---@return boolean connected Whether the system is connected to wifi.
	is_connected = function()
		return system.wifi.name() ~= nil
	end,

	--- Returns an icon for the wifi based off of whether it's connected and if so,
	--- the strength of the connection.
	---
	---@return string icon The wifi icon
	icon = function()
		local strength = system.wifi.signal_strength()
		local icon = "󰤯"
		if strength > 0.9 then
			icon = "󰤨"
		elseif strength > 0.8 then
			icon = "󰤥"
		elseif strength > 0.65 then
			icon = "󰤢"
		elseif strength > 0.5 then
			icon = "󰤟"
		elseif strength == 0 then
			icon = "󰤭"
		end

		return icon
	end,

	--- Returns the strength of the current wifi connection as a percentage between 0 and 1.
	--- More specifically, divides the current network's link quality by 70.
	---
	--- If there is no connected wifi network, returns 0.
	---
	---@return number strength The strength of the current wifi connection.
	signal_strength = function()
		local quality = io.popen("iwconfig wlan0"):read("a"):match("Link Quality=(%d+)")
		if not quality then return 0 end
		return tonumber(quality) / 70.0
	end,

	--- Watches the system's wifi connection and keeps the given texbox widget updated to
	--- reflect the wifi name (or icon)
	---
	---@param widget_to_watch any The widget to update with the wifi name
	---@param format nil | fun(percent: string, icon: string): string A function to format the output,
	--- taking the wifi name and icon as arguments. If `nil`, the widget will be updated to just
	--- show the wifi name.
	keep_updated = function(widget_to_watch, format)
		return awful.widget.watch("iwgetid -r", 1, function(widget, stdout)
			local success, error_message = pcall(function()
				local network_name = stdout:gsub("\n$", "")
				if system.wifi.__is_hidden then network_name = "Hidden" end
				local icon = system.wifi.icon()
				widget:set_text(format and format(network_name, icon) or network_name)
			end)

			if not success then
				naughty.notify({
					title = "Error updating wifi",
					text = tostring(error_message),
					preset = naughty.config.presets.critical,
				})
			end
		end, widget_to_watch)
	end,

	__is_hidden = false,

	toggle_hidden = function()
		system.wifi.__is_hidden = not system.wifi.__is_hidden
	end
}

--- Information about the currently focused screen, such as dimensions.
system.screen = {

	--- The height of the currently focused screen.
	---
	---@return number height The height of the currently focused screen, in pixels.
	height = function()
		return awful.screen.focused().workarea.height
	end,

	--- The width of the currently focused screen.
	---
	---@return number width The width of the currently focused screen, in pixels.
	width = function()
		return awful.screen.focused().workarea.width
	end,

	--- The dimensions of the currently focused screen.
	---
	---@return number, number dimensions The dimensions of the currently focused screen, in pixels.
	dimensions = function()
		return system.screen.width(), system.screen.height()
	end
}

--- Information about the disk usage of the system.
system.disk = {

	--- Returns the percent of space that the `/home` folder is using, relative to how much
	--- space it has available in total.
	---
	---@return number usage The percent full that `/home` is.
	home_usage = function()
		return tonumber(io.popen("df"):read("a"):match("(%d+)%% /home")) / 100.0
	end
}

--- Information about the system's volume.
system.volume = {

	--- Returns the current volume of the system as a number in `[0, 100]`
	---
	---@return number volume The system's current volume.
	amount = function()
		return assert(tonumber(io.popen("pamixer --get-volume"):read("a")))
	end,

	--- Returns the current volume of the system as a percent between 0 and 1.
	---
	---@return number percent The system's current volume as a percent.
	percent = function()
		return system.volume.amount() / 100
	end,

	keep_updated_with = function(widget_to_watch, callback)
		return awful.widget.watch("pamixer --get-volume", 0.1, function(_, stdout)
			local success, error_message = pcall(function()
				local output = tonumber(stdout)
				callback(output)
			end)

			if not success then
				naughty.notify({
					title = "Error updating volume",
					text = tostring(error_message),
					preset = naughty.config.presets.critical,
				})
			end
		end, widget_to_watch)
	end,

}

--- Information about the system's brightness.
system.brightness = {

	--- Returns the current brightness of the system as a number between 0 and the maximum
	--- specified by `system.brightness.max()`.
	---
	---@return number max The system's max brightness.
	amount = function()
		return assert(tonumber(io.popen("brightnessctl get"):read("a")))
	end,

	--- Returns the max brightness of the system as a number.
	---
	---@return number max The system's max brightness.
	max = function()
		return assert(tonumber(io.popen("brightnessctl max"):read("a")))
	end,

	--- Returns the current brightness as a percent between 0 and 1.
	---
	---@return number percent The current brightness percent.
	percent = function()
		return system.brightness.amount() / system.brightness.max()
	end,

	keep_updated_with = function(widget_to_watch, callback)
		return awful.widget.watch("brightnessctl get", 0.1, function(_, stdout)
			local success, error_message = pcall(function()
				local output = tonumber(stdout)
				callback(output)
			end)

			if not success then
				naughty.notify({
					title = "Error updating brightness",
					text = tostring(error_message),
					preset = naughty.config.presets.critical,
				})
			end
		end, widget_to_watch)
	end,
}

---@class Weather
---@field condition string
---@field condition_name string
---@field condition_symbol string
---@field humidity string
---@field temperature string
---@field wind string
---@field location string
---@field moon_phase string
---@field moon_day string
---@field precipitation string
---@field pressure string
---@field uv_index string
---@field dawn string
---@field sunrise string
---@field zenith string
---@field sunset string
---@field dusk string
---@field time string
---@field timezone string

system.weather = {

	--- Returns the current weather, with the specified format.
	---
	--- The given format function should take a single weather table as arguments, which contains
	--- formatting codes that can be used to format the output. For example:
	---
	--- ```lua
	--- local weather = system.weather.get(function(weather)
	---     return weather.temperature .. " with " .. weather.humidity
	--- end)
	--- ```
	---
	---@param format fun(weather: Weather): string The formatting function to use
	get = function(format)
		local codes = {
			condition = "%c",
			condition_name = "%C",
			condition_symbol = "%x",
			humidity = "%h",
			temperature = "%f",
			wind = "%w",
			location = "%l",
			moon_phase = "%m",
			moon_day = "%M",
			precipitation = "%p",
			pressure = "%P",
			uv_index = "%u",
			dawn = "%D",
			sunrise = "%S",
			zenith = "%z",
			sunset = "%s",
			dusk = "%d",
			time = "%T",
			timezone = "%Z"
		}

		return io.popen('curl wttr.in/?format="' .. format(codes) .. '"'):read("a")
	end,

	--- Keeps a widget updated by modifying it the current weather, with the given format.
	---
	--- The given format function should take a single weather table as arguments, which contains
	--- formatting codes that can be used to format the output. For example:
	---
	--- ```lua
	--- local weather = system.weather.keep_updated(weather_widget, function(weather)
	---     return weather.temperature .. " with " .. weather.humidity
	--- end)
	--- ```
	---
	--- The second parameter is a function that modifies the weather with the formatted output.
	---
	---@param base_widget any The base widget to update
	---@param format fun(weather: Weather): string The formatting function to use
	---@param setter fun(widget: any, output: string): nil The widget modification function
	---
	---@return any widget
	keep_updated_with = function(base_widget, format, setter)
		local codes = {
			condition = "%c",
			condition_name = "%C",
			condition_symbol = "%x",
			humidity = "%h",
			temperature = "%t",
			temperature_feels_like = "%f",
			wind = "%w",
			location = "%l",
			moon_phase = "%m",
			moon_day = "%M",
			precipitation = "%p",
			pressure = "%P",
			uv_index = "%u",
			dawn = "%D",
			sunrise = "%S",
			zenith = "%z",
			sunset = "%s",
			dusk = "%d",
			time = "%T",
			timezone = "%Z"
		}

		return awful.widget.watch('curl wttr.in/?format="' .. format(codes):gsub(" ", "%%20") .. '"', 10,
			function(widget, stdout)
				local success, error_message = pcall(function()
					local output = stdout:gsub("\n$", ""):gsub("%+", "")
					setter(widget, output)
				end)

				if not success then
					naughty.notify({
						title = "Error updating weather",
						text = tostring(error_message),
						preset = naughty.config.presets.critical,
					})
				end
			end, base_widget)
	end,
}

return system
