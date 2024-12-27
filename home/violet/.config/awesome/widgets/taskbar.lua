local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")
local system = require("misc.system")

local pinned_apps = {}

-- Main taskbar widget
local taskbar = awful.wibar({
	visible = true,
	height = 65,
	position = preferences.theme.taskbar_position,
	bg = preferences.theme.taskbar_background,
	--ontop = true,
})

local function get_app_icon(app_name)
	local override = preferences.icon_overrides[app_name]
	if override then
		pinned_apps[app_name] = { icon = override, command = app_name }
		local app_count = 0
		for _, _ in pairs(pinned_apps) do
			app_count = app_count + 1
		end

		if app_count == #preferences.taskbar_pinned_apps then
			taskbar:refresh()
		end
		return
	end

	local ripgrep = ("rg -l --color=never --no-ignore-vcs --follow ^Exec=.*\\\\b%s\\\\b /usr/share/applications"):format(
		app_name)
	awful.spawn.easy_async(ripgrep,
		function(path)
			path = path:match("([^\r\n]+)[\r\n]*$")
			local file, error = io.open(path, "r")
			if error then
				require("naughty").notify({
					title = "Error opening desktop file",
					text = error
				})
			end
			file = assert(file)
			local info = file:read("*a")
			local icon = info:match("Icon=([^\r\n]+)")
			local command = info:match("Exec=([^\r\n]+)")
			file:close()
			awful.spawn.easy_async_with_shell(
				('find /usr/share/icons -name %s.png | sort --version-sort -r | head -n 1'):format(icon),
				function(icon_path)
					icon_path = icon_path:match("([^\r\n]+)[\r\n]*$")
					pinned_apps[app_name] = { icon = icon_path, command = command }

					local app_count = 0
					for _, _ in pairs(pinned_apps) do
						app_count = app_count + 1
					end

					if app_count == #preferences.taskbar_pinned_apps then
						taskbar:refresh()
					end
				end
			)
		end)
end

local gap = 25

local clients = {
	layout = wibox.layout.flex.horizontal,
}

for _, app in ipairs(preferences.taskbar_pinned_apps) do
	get_app_icon(app)
end

function taskbar:refresh()
	local date = wibox.widget.textclock("%m/%d")
	date.font = preferences.theme.font_size(15)
	date.align = "center"

	local clock = wibox.widget.textclock("%H:%M")
	clock.font = preferences.theme.font_size(15)
	clock.align = "center"

	-- Battery widget
	local battery = wibox.widget.textbox("")
	battery.font = preferences.theme.font_size(16)
	battery.align = "center"
	battery = system.battery.keep_updated(battery, function(percent, icon) return icon .. " " .. percent .. "%" end)

	-- Volume widget
	local volume = system.volume.amount()
	local volume_widget = wibox.widget.textbox("󰕾 " .. tostring(volume) .. "%")
	volume_widget.font = preferences.theme.font_size(16)
	volume_widget = system.volume.keep_updated_with(volume_widget, function(widget, output, icon)
		widget:set_text(icon .. " " .. tostring(output) .. "%")
	end)

	clients = { layout = wibox.layout.fixed.horizontal }

	-- Pinned apps
	for _, app in ipairs(preferences.taskbar_pinned_apps) do
		if not pinned_apps[app] then
			goto continue
		end

		local widget = wibox.widget.imagebox(pinned_apps[app].icon)
		widget:connect_signal("button::press", function()
			for _, c in ipairs(client.get()) do
				if c.class:match(app .. "$") == app then
					client.focus = c
					c.first_tag:view_only()
					c:raise()
					return
				end
			end
			awful.spawn(pinned_apps[app].command)
		end)

		-- Focused pinned app
		if client.focus and client.focus.class and client.focus.class:lower():match(app:match("^(%S+)")) then
			table.insert(clients, {
				widget = wibox.layout.stack,
				{
					widget = wibox.container.margin,
					right = gap / 2 - 12,
					top = 3,
					bottom = 3,
					{
						widget = wibox.container.background,
						bg = "#FFFFFF10",
						shape = gears.shape.rounded_rect,
						{
							top = 12,
							bottom = 7,
							right = 12,
							left = 12,
							widget = wibox.container.margin,
							widget,
						},
					},
				},
				-- Open Circle
				{
					widget = wibox.container.margin,
					top = 62,
					bottom = 0,
					{
						widget = wibox.container.margin,
						left = 15,
						right = 15,
						{
							widget = wibox.container.background,
							bg = "#FFFFFF70",
							shape = gears.shape.rounded_rect
						}
					}
				},
			})
			-- Pinned unfocused app
		else
			local client_is_open = false
			for _, c in ipairs(client.get()) do
				if c.class and c.class:lower():match(app:lower() .. "$") == app:lower() then
					client_is_open = true
				end
			end

			if client_is_open then
				table.insert(clients,
					wibox.widget({
						widget = wibox.container.margin,
						left = gap / 2,
						right = gap / 2,
						bottom = -40,
						{
							widget = wibox.layout.stack,
							spacing = 0,
							{
								widget,
								widget = wibox.container.margin,
								top = 15,
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

		::continue::
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
			for _, app in ipairs(preferences.taskbar_pinned_apps) do
				if c.class and c.class:lower():match(app:match("^(%S+)")) then
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
					widget = wibox.layout.stack,
					{
						{
							{
								client_widget,
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
					},
					-- Open Circle
					{
						widget = wibox.container.margin,
						top = 62,
						bottom = 0,
						{
							widget = wibox.container.margin,
							left = 15,
							right = 15,
							{
								widget = wibox.container.background,
								bg = "#FFFFFF70",
								shape = gears.shape.rounded_rect
							}
						}
					},
				}
				-- Unfoucsed unpinned app
			else
				local right = gap
				if clients[index + 1] == client.focus then
					right = right - 12
				end

				client_widget = wibox.widget({
					widget = wibox.container.margin,
					left = gap / 2,
					right = gap / 2,
					bottom = -40,
					{
						widget = wibox.layout.stack,
						spacing = 0,
						{
							client_widget,
							widget = wibox.container.margin,
							top = 15,
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

	local wifi = wibox.widget.textbox("")
	wifi.font = preferences.theme.font_size(20)
	wifi = system.wifi.keep_updated(wifi, function(_, icon) return icon end)

	-- Set up the taskbar
	taskbar:setup({
		layout = wibox.layout.stack,

		-- Left widgets
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

		-- Client icons
		{
			clients,
			widget = wibox.container.margin,
			left = system.screen.width() / 2 - (#clients * 47 + (#clients - 1) * gap) / 2
		},

		-- Right widgets
		{
			widget = wibox.container.margin,
			left = system.screen.width() - 110,
			{
				layout = wibox.layout.fixed.horizontal,
				{
					widget = wibox.container.margin,
					right = 20,
					wifi,
				},
				{
					layout = wibox.layout.fixed.vertical,
					{
						widget = wibox.container.margin,
						top = 6,
						clock,
					},
					date,
				},
			}
		},
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

return {
	widget = taskbar,
}
