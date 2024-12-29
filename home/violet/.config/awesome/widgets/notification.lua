local ruled = require("ruled")
local awful = require("awful")
local naughty = require("naughty")
local preferences = require("preferences")
local gears = require("gears")
local system = require("misc.system")

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

-- Notify when battery starts/stops charging
system.battery.on_status_change(function(status)
	naughty.notify({
		title = "Battery",
		text = "Now " .. status:lower(),
	})
end)


-- Notify when battery reaches 10% or 20%
local gave_20_warning = false
local gave_10_warning = false
system.battery.on_percent_change(function(percent)
	if not gave_20_warning and percent <= 20 then
		naughty.notify({
			title = "Battery Low",
			text = "Warning: Battery is low (" .. tostring(percent) .. "%)",
			preset = naughty.config.presets.critical,
		})
		gave_20_warning = true
	end

	if not gave_10_warning and percent <= 10 then
		naughty.notify({
			title = "Battery Critical",
			text = "Warning: Battery is critical (" .. tostring(percent) .. "%)",
			preset = naughty.config.presets.critical,
		})
		gave_10_warning = true
	end

	if percent > 10 then
		gave_10_warning = false
	end

	if percent > 20 then
		gave_20_warning = false
	end
end)
