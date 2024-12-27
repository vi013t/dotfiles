local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")
local system = require("misc.system")

-- Sidebar
local sidebar = wibox({
	visible = false,
	ontop = true,
	type = "dock",
	screen = screen.primary,
	width = 400,
	height = awful.screen.focused().workarea.height - (2 * preferences.theme.default_margin),
	bg = preferences.theme.primary_background,
	border_width = preferences.theme.border_width,
	border_color = preferences.theme.primary_foreground,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 15)
	end,
})

--- Offset from this month, from pressing the arrows
local month_override = 0

local is_moving = false

-- Name
local name = wibox.widget.textbox()
name.markup = ("<b>%s</b>"):format(preferences.name)
name.align = "center"
name.font = preferences.theme.font_size(24)

-- Username
local username = wibox.widget.textbox()
username.markup = ('<span color="%s">%s</span>'):format(preferences.theme.secondary_foreground, preferences.username)
username.align = "center"
username.font = preferences.theme.font_size(22)

-- Profile picture
local profile = wibox.widget.imagebox(preferences.assets.images.profile_picture)
profile.clip_shape = function(cr, width, height)
	gears.shape.circle(cr, width, height, 150)
end

-- Wifi
local wifi = wibox.widget.textbox("")
wifi.align = "center"
wifi.font = preferences.theme.font_size(20)
wifi = system.wifi.keep_updated(wifi, function(wifi_name, icon) return icon .. "  " .. wifi_name end)

-- Calendar
local today = os.date("*t")
if month_override then
	local year = today.year
	if today.month + month_override > 12 then
		year = year + 1
	elseif today.month + month_override < 1 then
		year = year - 1
	end
	local month = (today.month + month_override - 1) % 12 + 1
	local specifiedDate = os.time({
		year = year,
		month = month,
		day = today.day,
	})
	today = os.date("*t", specifiedDate)
end
local first_of_month = (today.wday - today.day + 1) % 7

local months = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
}

local days = {
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday",
}

local calendar_title = wibox.widget.textbox()
local this_month_number = today.month
local this_month = months[this_month_number]
calendar_title.markup = ('<span color="%s">%s</span>'):format(preferences.theme.primary_foreground, this_month)
calendar_title.font = preferences.theme.font_size(20)
calendar_title.align = "center"

local function days_in_month(month_number, year)
	local day_counts = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
	local amount = day_counts[month_number]

	-- Leap year
	if month_number == 2 then
		if year % 400 == 0 or year % 100 ~= 0 and year % 4 == 0 then
			amount = 29
		end
	end

	return amount
end

local month = { layout = wibox.layout.fixed.vertical, spacing = 15 }

local week_days = { layout = wibox.layout.flex.horizontal }
for index, week_day in ipairs(days) do
	-- This week?
	local color = preferences.theme.primary_foreground
	if today.wday == index and month_override == 0 then
		color = "#FFFFFF"
	end

	-- Create the individual day widget
	local day_widget = wibox.widget.textbox()
	day_widget.markup = ('<span color="%s">%s</span>'):format(color, week_day:sub(1, 2))
	day_widget.font = preferences.theme.font_size(14)
	day_widget.align = "center"
	table.insert(week_days, day_widget)
end
table.insert(month, week_days)

for week_number = 1, 6 do
	local week = { layout = wibox.layout.flex.horizontal }
	for day = 1, 7 do
		local day_number = (week_number - 1) * 7 + day - first_of_month + 1
		local color = preferences.theme.primary_foreground

		-- Last month
		if day_number < 1 then
			local last_month = { this_month_number - 1, today.year }
			if this_month_number == 1 then
				last_month = { 12, today.year - 1 }
			end
			day_number = days_in_month(last_month[1], last_month[2]) - math.abs(day_number)
			color = preferences.theme.secondary_foreground

			-- Next month
		elseif day_number > days_in_month(this_month_number, today.year) then
			day_number = day_number - days_in_month(this_month_number, today.year)
			color = preferences.theme.secondary_foreground
		end

		local is_today = false
		if color == preferences.theme.primary_foreground and day_number == today.day and month_override == 0 then
			color = preferences.theme.primary_background
			is_today = true
		end

		local day_widget = wibox.widget.textbox()
		day_widget.markup = ('<span color="%s">%d</span>'):format(color, day_number)
		day_widget.font = preferences.theme.font_size(12)
		day_widget.align = "center"
		day_widget.bg = preferences.theme.primary_background

		local bg = preferences.theme.primary_background
		if is_today then
			bg = preferences.theme.primary_foreground
		end

		day_widget = {
			widget = wibox.container.background,
			bg = bg,
			shape = gears.shape.circle,
			{
				day_widget,
				widget = wibox.container.margin,
				left = 10,
				top = 10,
				bottom = 10,
				right = 10,
			},
		}

		day_widget[1][1]:connect_signal("mouse::enter", function()
			day_widget[1][1].markup = ('<span color="%s">%d</span>'):format("#FFFFFF", day_number)
			day_widget.bg = "#FF0000"
		end)
		day_widget[1][1]:connect_signal("mouse::leave", function()
			day_widget[1][1].markup = ('<span color="%s">%d</span>'):format(color, day_number)
			day_widget.bg = bg
		end)

		table.insert(week, day_widget)
	end
	table.insert(month, week)
end

local calendar = month

local calendar_left = wibox.widget.textbox()
calendar_left.markup = ('<span color="%s">    󰍞</span>'):format(preferences.theme.primary_foreground)
calendar_left.font = preferences.theme.font_size(30)
calendar_left:connect_signal("button::press", function()
	month_override = month_override - 1
end)

local calendar_right = wibox.widget.textbox()
calendar_right.markup = ('<span color="%s">󰍟   </span>'):format(preferences.theme.primary_foreground)
calendar_right.font = preferences.theme.font_size(30)
calendar_right.align = "right"
calendar_right:connect_signal("button::press", function()
	month_override = month_override + 1
end)

-- Battery meter
local battery_icon = wibox.widget.textbox("")
battery_icon.font = preferences.theme.font_size(20)
battery_icon = system.battery.keep_updated(battery_icon,
	function(_, icon) return (" "):rep(system.battery.is_charging() and 4 or 5) .. icon end
)
local battery_slider = wibox.widget({
	max_value = 100,
	value = system.battery.percent(),
	forced_height = 20,
	forced_width = 290,
	color = preferences.theme.primary_foreground,
	margins = { right = 25, left = 25 },
	shape = gears.shape.rounded_bar,
	background_color = preferences.theme.secondary_background,
	widget = wibox.widget.progressbar,
	bar_shape = gears.shape.rounded_bar,
})
local battery_text = wibox.widget.textbox("")
battery_text.font = preferences.theme.font_size(15)
battery_text = system.battery.keep_updated(battery_text, function(percent) return percent .. "%" end)

-- Disk Usage meter
local disk_icon = wibox.widget.textbox("    ")
disk_icon.font = preferences.theme.font_size(20)
local disk_usage = math.floor(system.disk.home_usage() * 100)
local disk_usage_slider = wibox.widget({
	max_value = 100,
	value = disk_usage,
	forced_height = 20,
	forced_width = 290,
	margins = { right = 25, left = 25 },
	color = preferences.theme.primary_foreground,
	shape = gears.shape.rounded_bar,
	background_color = preferences.theme.secondary_background,
	widget = wibox.widget.progressbar,
	bar_shape = gears.shape.rounded_bar,
})
local disk_text = wibox.widget.textbox(tostring(disk_usage) .. "%")
disk_text.font = preferences.theme.font_size(15)

-- Calculator widget
local calculator_icon = wibox.widget.textbox("󰃬")
calculator_icon.font = preferences.theme.font_size(32)
calculator_icon:connect_signal("button::press", function()
	awful.spawn(preferences.apps.calculator)
	sidebar:toggle()
end)

-- Storage widget
local files_icon = wibox.widget.textbox("")
files_icon.font = preferences.theme.font_size(32)
files_icon:connect_signal("button::press", function()
	awful.spawn(preferences.apps.file_explorer)
	sidebar:toggle()
end)

-- Calendar widget
local calendar_icon = wibox.widget.textbox("")
calendar_icon.font = preferences.theme.font_size(32)
calendar_icon:connect_signal("button::press", function()
	awful.spawn(preferences.apps.calendar)
	sidebar:toggle()
end)

-- Mail widget
local mail_icon = wibox.widget.textbox("󰇮")
mail_icon.font = preferences.theme.font_size(32)

-- App widgets
local apps = {
	{
		calculator_icon,
		files_icon,
		calendar_icon,
		mail_icon,
		spacing = 70,
		layout = wibox.layout.fixed.horizontal,
	},
	widget = wibox.container.margin,
	left = 35,
}

-- Set up the sidebar
sidebar:setup({
	{
		{
			profile,
			{
				widget = wibox.container.margin,
				top = -15,
				name,
			},
			username,
			layout = wibox.layout.fixed.vertical,
		},
		{
			{
				{
					calendar_left,
					calendar_title,
					calendar_right,
					layout = wibox.layout.flex.horizontal,
				},
				calendar,
				{
					widget = wibox.container.margin,
					top = 10,
					bottom = 10,
					wifi,
				},
				layout = wibox.layout.fixed.vertical,
				spacing = 15,
			},
			{
				{
					battery_icon,
					battery_slider,
					battery_text,
					layout = wibox.layout.fixed.horizontal,
				},
				{ disk_icon, disk_usage_slider, disk_text, layout = wibox.layout.fixed.horizontal },
				layout = wibox.layout.fixed.vertical,
				spacing = 25,
			},
			layout = wibox.layout.fixed.vertical,
			spacing = 25,
		},
		{
			apps,
			widget = wibox.container.margin,
			top = 10,
		},
		widget = wibox.container.background,
		forced_width = 400,
		clip = true,
		spacing = 25,
		layout = wibox.layout.fixed.vertical,
	},
	layout = wibox.layout.align.vertical,
})

-- Sliding animation

local slide_speed = 100
local left = -400

local function slide_in()
	is_moving = true
	awful.placement.top_left(sidebar, {
		honor_workarea = true,
		margins = { left = left, top = preferences.theme.default_margin }
	})
	left = left + slide_speed
	if left < 10 then
		awful.spawn.easy_async("sleep 0.001", function()
			slide_in()
		end)
	else
		is_moving = false
		left = 10
		awful.placement.top_left(sidebar, {
			honor_workarea = true,
			margins = { left = left, top = preferences.theme.default_margin }
		})
	end
end

local function slide_out()
	is_moving = true
	awful.placement.top_left(sidebar, {
		honor_workarea = true,
		margins = { left = left, top = preferences.theme.default_margin }
	})
	left = left - slide_speed
	if left > -400 then
		awful.spawn.easy_async("sleep 0.001", function()
			slide_out()
		end)
	else
		is_moving = false
		left = -400
		awful.placement.top_left(sidebar, {
			honor_workarea = true,
			margins = { left = left, top = preferences.theme.default_margin }
		})
		sidebar.visible = false
	end
end

function sidebar:toggle()
	if is_moving then return end

	if not self.visible then
		self.visible = true
		slide_in()
	else
		slide_out()
		month_override = 0
		self.visible = false
	end
end

return {
	widget = sidebar,
}
