local awful = require("awful")
local naughty = require("naughty")

-- Handle runtime errors after startup
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Error During Startup",
			text = tostring(err)
		})

		in_error = false
	end)
end

-- Startup programs
awful.spawn.with_shell("picom -b --backend glx --config ~/.config/picom/picom.conf")             -- Compositor
awful.spawn.with_shell("feh --no-fehbg --bg-fill ~/.config/awesome/assets/images/wallpaper.jpg") -- Wallpaper

awful.spawn.easy_async_with_shell("xinput list --name-only | grep -i touchpad --color=none", function(touchpad)
	touchpad = touchpad:match("([^\r\n]+)[\r\n]*")
	if touchpad then
		require("naughty").notify({
			title = "Enabling Touchpad",
			text = "Enabling tapping for touchpad \"" .. touchpad .. "\""
		})
		awful.spawn.with_shell(('xinput set-prop "%s" "libinput Tapping Enabled" 1'):format(touchpad))
	end
end)
