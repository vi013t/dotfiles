local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")
local actions = require("misc.actions")
local system = require("misc.system")
local animate = require("misc.animate")

local public = {}

local search

function public.setup(launcher)
	local is_hiding = false
	local is_showing = false

	-- Main menu widget
	local menu = wibox({
		visible = false,
		ontop = true,
		type = "dock",
		screen = screen.primary,
		width = 500,
		height = 820,
		bg = preferences.theme.primary_background,
		border_width = preferences.theme.border_width,
		border_color = preferences.theme.border_color,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, 15)
		end
	})

	-- Time widget
	local time = wibox.widget.textclock("%H:%M")
	time.font = preferences.theme.font_size(85)
	time.align = "center"

	-- Date widget
	local today = os.date("*t")
	local days = {
		"Sunday",
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday",
	}
	local today_day = days[today.wday]
	local months = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"Septemeber",
		"October",
		"November",
		"December",
	}
	local suffixes = { "st", "nd", "rd" }
	local today_suffix = suffixes[today.day % 10] or "th"
	local today_month = months[today.month]
	local date_widget = wibox.widget.textbox()
	date_widget.markup = ('<span color="%s">%s, %s %s<sup>%s</sup></span>'):format(
		preferences.theme.secondary_foreground,
		today_day,
		today_month,
		today.day,
		today_suffix
	)
	date_widget.font = preferences.theme.font_size(20)
	date_widget.align = "center"

	-- Weather widget
	local weather_widget = wibox.widget.textbox("")
	weather_widget.font = preferences.theme.font_size(20)
	weather_widget.align = "center"
	weather_widget = system.weather.keep_updated_with(
		weather_widget,
		function(weather)
			return weather.condition .. weather.temperature .. " " .. weather.condition_name
		end,
		function(widget, output)
			widget:set_markup(('<span color="%s">%s</span>'):format(preferences.theme.primary_foreground, output))
		end
	)

	-- Profile picture widget
	local profile = wibox.widget.imagebox(preferences.assets.images.profile_picture)
	profile.forcd_width = 200
	profile.forced_height = 200
	profile.clip_shape = function(cr, width, height)
		gears.shape.circle(cr, width, height, 80)
	end

	-- Name widget
	local name = wibox.widget.textbox()
	name.markup = ("<b>%s</b>"):format(preferences.name)
	name.align = "center"
	name.font = preferences.theme.font_size(20)

	-- Username widget
	local username = wibox.widget.textbox()
	username.markup = ('<span color="%s">%s\n</span>'):format(preferences.theme.secondary_foreground,
		preferences.username)
	username.align = "center"
	username.font = preferences.theme.font_size(20)

	-- Launcher search widget
	search = awful.widget.prompt({
		prompt = "   ",
		bg_cursor = preferences.theme.secondary_background,
		font = preferences.theme.font_size(15),
		keypressed_callback = function(_, key, _)
			if key == "Super_L" then
				menu:toggle()
				awful.keygrabber.stop()
			elseif key == "Print" then
				actions.screenshot()()
			end
		end,
		changed_callback = function(search_term)
			if search_term ~= "" and not is_hiding then
				launcher:show()
				launcher:sort(search_term)
			else
				launcher:hide()
			end
		end,
		exe_callback = function(_)
			awful.spawn(launcher.apps[1].command)
			menu:toggle()
		end,
		autoexec = false
	})
	local search_widget = {
		widget = wibox.container.margin,
		left = 130,
		right = 130,
		top = -10,
		bottom = 20,
		{
			{
				search,
				widget = wibox.container.margin,
				top = 10,
				left = 10,
				right = 10,
				bottom = 10
			},
			widget = wibox.container.background,
			shape = function(cr, width, height)
				gears.shape.rounded_bar(cr, width, height)
			end,
			bg = preferences.theme.secondary_background,
		}
	}

	-- Volume widget
	local volume = system.volume.amount()
	local volume_percent = volume / 100
	local volume_icon = wibox.widget.textbox("    " .. (volume > 0 and "󰕾" or "󰝟") .. "    ")
	volume_icon.font = preferences.theme.font_size(20)
	local volume_widget = wibox.widget.slider({
		maximum = 100,
		value = volume,
		minimum = 0,
		bar_height = 20,
		forced_height = 60,
		handle_color = "#FFFFFF",
		bar_color = gears.color({
			type = "linear",
			from = { 0, 0 },
			to = { 300, 0 },
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
	local volume_text = wibox.widget.textbox("    " .. tostring(volume) .. "%")
	volume_text.font = preferences.theme.font_size(20)
	volume_text.align = "center"

	-- Brightness widget
	local brightness = system.brightness.amount()
	local max_brightness = system.brightness.max()
	local brightness_percent = brightness / max_brightness
	local brightness_icon = wibox.widget.textbox("    " .. "󰃠" .. "    ")
	brightness_icon.font = preferences.theme.font_size(20)
	local brightness_widget = wibox.widget.slider({
		maximum = max_brightness,
		value = brightness,
		minimum = 0,
		bar_height = 20,
		forced_height = 60,
		handle_color = "#FFFFFF",
		bar_color = gears.color({
			type = "linear",
			from = { 0, 0 },
			to = { 300, 0 },
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
	local brightness_text = wibox.widget.textbox("    " .. tostring(math.floor(brightness_percent * 100)) .. "%")
	brightness_text.font = preferences.theme.font_size(20)
	brightness_text.align = "center"

	-- Power button widgets
	local function power_button(text, command)
		local power_button_widget = wibox.widget.textbox()
		power_button_widget.markup = ('<span color="%s">%s</span>'):format("white", text)
		power_button_widget.font = preferences.theme.font_size(32)
		power_button_widget.align = "center"
		power_button_widget:connect_signal("button::press", function() command() end)

		power_button_widget = {
			{
				power_button_widget,
				widget = wibox.container.margin,
				top = 25,
				bottom = 25,
				right = 25,
				left = 25,
			},
			widget = wibox.container.background,
			shape = gears.shape.circle,
		}

		return power_button_widget
	end
	local restart_awesome = power_button("", awesome.restart)
	local shutdown = power_button("󰐥", function() awful.spawn("shutdown") end)
	local restart = power_button("󰜉", function() awful.spawn("reboot") end)
	local logout = power_button("󰍃", awesome.quit)

	-- Place the widgets in the menu
	menu:setup({
		{
			{

				-- Clock
				{
					time,
					top = 20,
					widget = wibox.container.margin,
				},

				-- Date
				date_widget,

				-- Weather
				{
					widget = wibox.container.margin,
					top = 10,
					bottom = 15,
					weather_widget,
				},

				-- Profile picture
				{
					profile,
					widget = wibox.container.margin,
					left = 150,
				},

				-- Name
				name,

				-- Username
				username,

				-- Launcher search
				search_widget,

				-- Volume
				{
					volume_icon,
					volume_widget,
					volume_text,
					layout = wibox.layout.fixed.horizontal,
				},

				-- Brightness
				{
					brightness_icon,
					brightness_widget,
					brightness_text,
					layout = wibox.layout.fixed.horizontal,
				},

				-- Power buttons
				{
					{
						shutdown,
						restart,
						logout,
						restart_awesome,
						layout = wibox.layout.flex.horizontal,
					},
					widget = wibox.container.margin,
					top = 5,
				},

				layout = wibox.layout.fixed.vertical,
			},
			widget = wibox.container.background,
			clip = true,
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.align.vertical,
	})

	--- Toggles visibility of the menu.
	function menu:toggle()
		if is_hiding or is_showing then return end

		if not self.visible then
			animate.slide_in({
				from = "top",
				widget = menu,
				thickness = 820,
				placement = "top_right",
				time = 1,
				margins = { right = preferences.theme.default_margin, top = preferences.theme.default_margin }
			})
			search:run()
		else
			animate.slide_out({
				from = "top",
				widget = menu,
				thickness = 820,
				placement = "top_right",
				time = 1,
				margins = { right = preferences.theme.default_margin, top = preferences.theme.default_margin }
			})
			launcher:hide()
		end
	end

	return { widget = menu, search = search }
end

return public
