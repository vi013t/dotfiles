local actions = {}

local awful = require("awful")

function actions.raise_volume(amount)
	return function(widgets)
		os.execute("pamixer --increase " .. amount)
		widgets.menu:refresh_numbers()
		widgets.volume:show()
		awful.spawn.easy_async_with_shell(
			"ffplay ~/.config/awesome/assets/sounds/volume_change.mp3 -nodisp -autoexit",
			function() end
		)
	end
end

function actions.lower_volume(amount)
	return function(widgets)
		os.execute("pamixer --decrease " .. amount)
		widgets.menu:refresh_numbers()
		widgets.volume:show()
		awful.spawn.easy_async_with_shell(
			"ffplay ~/.config/awesome/assets/sounds/volume_change.mp3 -nodisp -autoexit",
			function() end
		)
	end
end

function actions.mute()
	return function(widgets)
		os.execute("pamixer --set-volume 0")
		widgets.menu:refresh_numbers()
		widgets.volume:show()
	end
end

function actions.raise_brightness(amount)
	return function(widgets)
		os.execute("brightnessctl set +" .. tostring(amount) .. "%")
		widgets.menu:refresh_numbers()
		widgets.brightness:show()
	end
end

function actions.lower_brightness(amount)
	return function(widgets)
		os.execute("brightnessctl set " .. tostring(amount) .. "%-")
		widgets.menu:refresh_numbers()
		widgets.brightness:show()
	end
end

function actions.open(command)
	return function(_)
		awful.spawn.easy_async_with_shell(command, function() end)
	end
end

---@param widget_name "sidebar" | "taskbar"
function actions.toggle_widget(widget_name)
	return function(widgets)
		widgets[widget_name]:toggle()
	end
end

function actions.screenshot()
	return function(_)
		awful.spawn.with_shell(
			'flameshot full --path "' ..
			os.getenv("HOME") ..
			'/Pictures/Screenshots/' ..
			tostring(os.date("%x")):gsub("/", "_") ..
			" at " ..
			tostring(os.date("%X")):gsub(":|%s", "_") ..
			'"'
		)
	end
end

function actions.screenshot_section()
	return function(widgets)
		widgets.tags.visible = false
		awful.spawn("flameshot gui")
	end
end

return actions
