local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")
local system = require("misc.system")

--- The brightness widget. This is the little bar that appears when you change the screen's
--- brightness.
local brightness_bar = wibox({
	visible = false,
	ontop = true,
	type = "dock",
	screen = screen.primary,
	width = 300,
	height = 50,
	bg = preferences.theme.primary_background
})

awful.placement.top_right(
	brightness_bar,
	{ honor_workarea = true, margins = { right = preferences.theme.default_margin, top = preferences.theme.default_margin } }
)

local brightness = system.brightness.amount()
local max_brightness = system.brightness.max()
local brightness_percent = brightness / max_brightness

local brightness_icon = wibox.widget.textbox("󰃠" .. "    ")
brightness_icon.font = preferences.theme.font_size(20)

local brightness_widget = wibox.widget.slider({
	maximum = max_brightness,
	value = brightness,
	minimum = 0,
	bar_height = 10,
	forced_height = 10,
	handle_color = preferences.theme.primary_foreground,
	bar_color = gears.color({
		type = "linear",
		from = { 0, 0 },
		to = { 200, 0 },
		stops = {
			{ 0,                         preferences.theme.primary_foreground },
			{ brightness_percent - 0.01, preferences.theme.primary_foreground },
			{ brightness_percent,        preferences.theme.secondary_background },
			{ 1,                         preferences.theme.secondary_background },
		},
	}),
	handle_shape = gears.shape.circle,
	bar_shape = gears.shape.rounded_bar,
	forced_width = 300,
})

brightness_widget = system.brightness.keep_updated_with(brightness_widget, function(amount)
	brightness_widget.value = amount
	local percent = amount / system.brightness.max()
	brightness_widget.bar_color = gears.color({
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

brightness_bar:setup({
	{
		{
			brightness_icon,
			brightness_widget,
			brightness_icon,
			layout = wibox.layout.fixed.horizontal,
		},
		widget = wibox.container.margin,
		right = 25,
		left = 25,
	},
	layout = wibox.layout.flex.vertical,
})

function brightness_bar:toggle()
	if brightness_bar.visible then
		brightness_bar:hide()
	else
		brightness_bar:show()
	end
end

function brightness_bar:show()
	brightness_bar.visible = true

	-- Timer already exists - Restart it
	if brightness_bar.timer then
		brightness_bar.timer:again()

		-- No timer yet - create one and start it
	else
		brightness_bar.timer = gears.timer({
			timeout = 2,
			autostart = true,
			callback = function()
				brightness_bar:hide()
			end,
		})
	end
end

function brightness_bar:hide()
	brightness_bar.visible = false
end

return {
	widget = brightness_bar,
}
