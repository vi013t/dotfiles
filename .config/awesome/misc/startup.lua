local awful = require("awful")
local naughty = require("naughty") -- Notification library

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
			title = "Oops, an error happened!",
			text = tostring(err)
		})

		in_error = false
	end)
end

-- Startup programs
awful.spawn.with_shell("picom -b --backend glx --config ~/.config/picom/picom.conf")                    -- Compositor
awful.spawn.with_shell("feh --no-fehbg --bg-fill ~/.config/awesome/assets/images/wallpaper.jpg")        -- Wallpaper
awful.spawn.with_shell('xinput set-prop "VEN_04F3:00 04F3:320F Touchpad" "libinput Tapping Enabled" 1') -- Enable touchpad tapping
