local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")
local system = require("misc.system")

-- Main volume bar widget
local volume_bar = wibox({ visible = false, ontop = true, type = "dock", screen = screen.primary })
volume_bar.width = 300
volume_bar.height = 50
volume_bar.bg = preferences.theme.primary_background
awful.placement.top_right(volume_bar,
	{ honor_workarea = true, margins = { right = preferences.theme.default_margin, top = preferences.theme.default_margin } })

-- Number
local volume = system.volume.amount()
local volume_percent = volume / 100

-- Icon
local volume_icon = wibox.widget.textbox((volume > 0 and "󰕾" or "󰝟") .. "    ")
volume_icon.font = preferences.theme.font_size(20)

-- Slider
local volume_widget = wibox.widget.slider({
	maximum = 100,
	value = volume,
	minimum = 0,
	bar_height = 10,
	forced_height = 10,
	handle_color = preferences.theme.primary_foreground,
	bar_color = gears.color({
		type = "linear",
		from = { 0, 0 },
		to = { 200, 0 },
		stops = {
			{ 0,                     preferences.theme.primary_foreground },
			{ volume_percent - 0.01, preferences.theme.primary_foreground },
			{ volume_percent,        preferences.theme.secondary_background },
			{ 1,                     preferences.theme.secondary_background },
		},
	}),
	handle_shape = gears.shape.circle,
	bar_shape = gears.shape.rounded_bar,
	forced_width = 300,
})
volume_widget = system.volume.keep_updated_with(volume_widget, function(amount)
	volume_widget.value = amount
	local percent = amount / 100
	volume_widget.bar_color = gears.color({
		type = "linear",
		from = { 0, 0 },
		to = { 200, 0 },
		stops = {
			{ 0,              preferences.theme.primary_foreground },
			{ percent - 0.01, preferences.theme.primary_foreground },
			{ percent,        preferences.theme.secondary_background },
			{ 1,              preferences.theme.secondary_background },
		},
	})
end)

-- Text
local volume_text = wibox.widget.textbox("    " .. tostring(volume) .. "%%")
volume_text.font = preferences.theme.font_size(20)
volume_text.align = "center"

-- Add widgets
volume_bar:setup({
	{
		widget = wibox.container.margin,
		right = 25,
		left = 25,
		{
			volume_icon,
			volume_widget,
			volume_text,
			layout = wibox.layout.fixed.horizontal,
		},
	},
	layout = wibox.layout.flex.vertical,
})

function volume_bar:toggle()
	self.visible = not self.visible
end

function volume_bar:show()
	volume_bar.visible = true
	if volume_bar.timer then
		volume_bar.timer:again()
	else
		volume_bar.timer = gears.timer({
			timeout = 2,
			autostart = true,
			callback = function()
				volume_bar:hide()
			end,
		})
	end
end

function volume_bar:hide()
	volume_bar.visible = false
end

return {
	widget = volume_bar,
}