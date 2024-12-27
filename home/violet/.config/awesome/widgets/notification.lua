local ruled = require("ruled")
local awful = require("awful")
local naughty = require("naughty")
local preferences = require("preferences")
local gears = require("gears")


-- Style notifications
naughty.config.spacing = preferences.theme.default_margin
naughty.config.padding = preferences.theme.default_margin
naughty.config.defaults.border_color = preferences.theme.primary_foreground
naughty.config.defaults.border_width = 2
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.screen = awful.screen.preferred
naughty.config.defaults.implicit_timeout = 5
naughty.config.defaults.margin = 25
naughty.config.defaults.border_radius = 6
naughty.config.defaults.bg = preferences.theme.primary_background
naughty.config.defaults.font = preferences.theme.font_size(14)
naughty.config.defaults.icon_size = 60
naughty.config.defaults.shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, 10)
end

-- Errors
naughty.config.presets.critical.bg = preferences.theme.primary_background
naughty.config.presets.critical.border_color = "#FF0000"

-- Not sure why this is needed but it is
ruled.notification.connect_signal("request::rules", function() end)

-- Go to the client when clicking the notification
naughty.connect_signal("destroyed", function(n, reason)
	if not n.clients then
		return
	end
	if reason == require("naughty.constants").notification_closed_reason.dismissed_by_user then
		local jumped = false
		for _, c in ipairs(n.clients) do
			c.urgent = true
			if jumped then
				c:activate({ context = "client.jumpto" })
			else
				c:jump_to()
				jumped = true
			end
		end
	end
end)

local status
awful.widget.watch("cat /sys/class/power_supply/BAT0/status", 1, function(_, stdout)
	if status ~= stdout then
		naughty.notify({
			title = "Battery",
			text = "Now " .. stdout:lower():gsub("\n", ""),
		})
		status = stdout
	end
end)

--- Whether or not the warning that 20% battery is remaining has been shown yet
local gave_20_warning = false

--- Whether or not the warning that 10% battery is remaining has been shown yet
local gave_10_warning = false

awful.widget.watch("cat /sys/class/power_supply/BAT0/capacity", 1, function(_, stdout)
	if not gave_20_warning and tonumber(stdout) <= 20 then
		naughty.notify({
			title = "Battery",
			text = "Warning: Battery is low (" .. stdout:gsub("\n$", "") .. "%)",
			preset = naughty.config.presets.critical,
		})
		gave_20_warning = true
	end

	if not gave_10_warning and tonumber(stdout) <= 10 then
		naughty.notify({
			title = "Battery",
			text = "Warning: Battery is critical (" .. stdout:gsub("\n$", "") .. "%)",
			preset = naughty.config.presets.critical,
		})
		gave_10_warning = true
	end

	if tonumber(stdout) > 10 then
		gave_10_warning = false
	end

	if tonumber(stdout) > 20 then
		gave_20_warning = false
	end
end)
