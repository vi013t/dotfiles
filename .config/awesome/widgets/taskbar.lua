local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local preferences = require("misc.preferences")
local system = require("misc.system")

local function get_app_icon(app_name)
	local dirs_to_check = {
		"scalable",
		"512x512",
		"384x384",
		"256x256",
		"192x192",
		"128x128",
		"96x96",
		"72x72",
		"48x48",
		"36x36",
		"32x32",
		"24x24",
		"22x22",
		"16x16",
	}

	for _, dir in ipairs(dirs_to_check) do
		local path_to_directory = "/usr/share/icons/hicolor/" .. dir .. "/apps/"
		for file in io.popen("ls " .. path_to_directory):lines() do
			if file:match("%f[%a]" .. app_name .. "%f[%A]") then
				return path_to_directory .. file
			end
		end
	end
end

local taskbar = awful.wibar({ visible = true, height = 65, position = "bottom", bg = "#111122", ontop = true })

client.connect_signal("property::fullscreen", function(c)
	if c.fullscreen then
		taskbar.visible = false
		taskbar:refresh()
	else
		taskbar.visible = true
		taskbar:refresh()
	end
end)

local date = wibox.widget.textclock("%m/%d")
date.font = "OpenSans 15"
date.align = "center"

local clock = wibox.widget.textclock("%H:%M")
clock.font = "OpenSans 15"
clock.align = "center"

local battery = wibox.widget.textbox(system.battery:get_icon() .. " " .. system.battery:percent() .. "%")
battery.font = "OpenSans 16"
battery.align = "center"

local wifi = wibox.widget.textbox("󰖩 " .. system.wifi:name())
wifi.font = "OpenSans 16"
wifi.align = "center"

local gap = 25

local clients = {
	layout = wibox.layout.flex.horizontal,
}

local volume = tonumber(io.popen("pamixer --get-volume"):read("a"))
local volume_widget = wibox.widget.textbox("󰕾 " .. tostring(volume) .. "%")
volume_widget.font = "OpenSans 16"
awful.widget.watch("pamixer --get-volume", 1, function(widget, stdout)
	widget:set_text("󰕾 " .. stdout:gsub("\n+$", "") .. "%")
end, volume_widget)

function taskbar:refresh()
	clients = { layout = wibox.layout.fixed.horizontal }

	-- local logo = wibox.widget.imagebox("/home/violet/.config/awesome/images/arch.png")
	-- logo:connect_signal("button::press", function()
	-- 	awful.spawn.with_shell("rofi -show run -show-icons")
	-- end)
	--
	-- table.insert(clients, {
	-- 	widget = wibox.container.margin,
	-- 	top = 22,
	-- 	bottom = 20,
	-- 	left = 0,
	-- 	right = gap / 2,
	-- 	logo,
	-- })

	-- Pinned apps
	for _, app in ipairs(preferences.pinned_apps) do
		local widget = wibox.widget.imagebox(get_app_icon(app:match("^(%S+)")))
		widget:connect_signal("button::press", function()
			for _, c in ipairs(client.get()) do
				if c.class:match(app .. "$") == app then
					client.focus = c
					c.first_tag:view_only()
					c:raise()
					return
				end
			end
			awful.spawn(app)
		end)

		-- Focused pinned app
		if client.focus and client.focus.class:lower():match(app:match("^(%S+)")) then
			table.insert(clients, {
				{
					{
						widget,
						widget = wibox.container.margin,
						top = 12,
						bottom = 7,
						right = 12,
						left = 12,
					},
					widget = wibox.container.background,
					bg = "#FFFFFF10",
					shape = gears.shape.rounded_rect,
				},
				widget = wibox.container.margin,
				right = gap / 2 - 12,
				top = 3,
				bottom = 3,
			})

			-- Not selected
		else
			local exists = false
			for _, c in ipairs(client.get()) do
				if c.class and c.class:match(app .. "$") == app then
					exists = true
				end
			end

			if exists then
				table.insert(clients,
					wibox.widget({
						widget = wibox.container.margin,
						left = gap / 2,
						bottom = -40,
						{
							widget = wibox.layout.stack,
							spacing = 0,
							{
								widget,
								widget = wibox.container.margin,
								top = 18,
								bottom = 50,
							},
							{
								widget = wibox.container.margin,
								top = 60,
								bottom = 40,
								{
									widget = wibox.container.background,
									bg = "#8888AA",
									shape = gears.shape.circle
								}
							}
						}
					})
				)
			else
				table.insert(clients, {
					widget,
					widget = wibox.container.margin,
					top = 15,
					bottom = 10,
					left = gap / 2,
					right = gap / 2,
				})
			end
		end
	end

	local done_clients = {}

	-- Not pinned apps
	for index, c in ipairs(client.get()) do
		local client_widget = awful.widget.clienticon(c)
		client_widget.forced_height = 40

		local already_done = false
		for _, dc in ipairs(done_clients) do
			if c.class == dc.class then
				already_done = true
				break
			end
		end

		if not already_done then
			for _, app in ipairs(preferences.pinned_apps) do
				if c.class:lower():match(app:match("^(%S+)")) then
					already_done = true
					break
				end
			end
		end

		table.insert(done_clients, c)

		if not already_done then
			-- Focused unpinned app
			if client.focus and client.focus.class == c.class then
				client_widget = {
					{
						{
							client_widget,
							widget = wibox.container.margin,
							top = 12,
							bottom = 12,
							right = 12,
							left = 12,
						},
						widget = wibox.container.background,
						bg = "#FFFFFF10",
						shape = gears.shape.rounded_rect,
					},
					widget = wibox.container.margin,
					right = gap / 2 - 12,
					top = 3,
					bottom = 3,
				}

				-- Unfoucsed unpinned app
			else
				local right = gap
				if clients[index + 1] == client.focus then
					right = right - 12
				end
				client_widget = wibox.widget({
					widget = wibox.container.margin,
					left = 7,
					bottom = -40,
					{
						widget = wibox.layout.stack,
						spacing = 0,
						{
							client_widget,
							widget = wibox.container.margin,
							top = 18,
							bottom = 50,
						},
						{
							widget = wibox.container.margin,
							top = 60,
							bottom = 40,
							{
								widget = wibox.container.background,
								bg = "#8888AA",
								shape = gears.shape.circle
							}
						}
					}
				})


				client_widget:connect_signal("button::press", function()
					client.focus = c
					c.first_tag:view_only()
					c:raise()
				end)
			end

			table.insert(clients, client_widget)
		end
	end

	-- Set up the taskbar
	taskbar:setup({
		{
			{
				battery,
				volume_widget,
				layout = wibox.layout.fixed.horizontal,
				spacing = 20,
			},
			widget = wibox.container.margin,
			left = 20,
		},
		{
			clients,
			widget = wibox.container.margin,
			left = 1600 / 2 - (#clients * (64 + gap)) / 2,
		},
		{
			{
				{
					clock,
					widget = wibox.container.margin,
					top = 6,
				},
				date,
				layout = wibox.layout.fixed.vertical,
			},
			widget = wibox.container.margin,
			left = 800,
		},
		layout = wibox.layout.fixed.horizontal,
	})
end

client.connect_signal("manage", function()
	taskbar:refresh()
end)

client.connect_signal("unmanage", function()
	taskbar:refresh()
end)

client.connect_signal("focus", function()
	taskbar:refresh()
end)

client.connect_signal("unfocus", function()
	taskbar:refresh()
end)

function taskbar:toggle()
	self.visible = not self.visible
	taskbar:refresh()
end

taskbar:refresh()

return {
	widget = taskbar,
}
