local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local theme = require("misc.theme")

local alt_tab_widget = wibox({ visible = false, ontop = true, type = "popup_menu", screen = screen.primary })
alt_tab_widget.width = 600
alt_tab_widget.height = 250
alt_tab_widget.visible = true
alt_tab_widget.bg = "#ff000000"

awful.placement.align(alt_tab_widget,
	{ position = "centered", honor_workarea = true, margins = { top = theme.custom.default_margin } }
)

local selected_client_index = 1

local focus_history = {}

client.connect_signal("focus", function(c)
	table.insert(focus_history, 1, c)
	for i = #focus_history, 2, -1 do
		if focus_history[i] == c then
			table.remove(focus_history, i)
		end
	end
end)

local clients = {}

function alt_tab_widget:refresh()
	local all_widgets = { layout = wibox.layout.flex.vertical, spacing = 20 }

	local client_widgets = { layout = wibox.layout.flex.horizontal }
	clients = {}

	alt_tab_widget.width = 400 * math.min(#client.get(), 4)
	alt_tab_widget.height = 250 * (math.floor((#client.get() - 1) / 4) + 1)

	for _, window in ipairs(client.get()) do
		table.insert(clients, window)
	end

	table.sort(clients, function(first, other)
		local first_index = 9999
		local other_index = 9999

		for index, value in ipairs(focus_history) do
			if value == first then first_index = index end
			if value == other then other_index = index end
		end

		return first_index < other_index
	end)

	for index, window in ipairs(clients) do
		local title = wibox.widget.textbox()
		local max_characters = 35
		local name = window.name:match((".?"):rep(max_characters))
		local color = theme.custom.primary_foreground
		local tag = window.first_tag.index
		if index == selected_client_index then color = "#FFFFFF" end
		title.markup = ('<span color="%s">[%d] %s</span>'):format(color, tag, name)
		title.font = "opensans 12"

		local icon = awful.widget.clienticon(window)
		icon.forced_height = 30
		icon.forced_width = 30

		local preview = awful.widget.clienticon(window)

		table.insert(client_widgets, {
			widget = wibox.container.margin,
			left = 10,
			right = 10,
			{
				widget = wibox.container.background,
				bg = theme.custom.primary_background,
				border_color = color,
				border_width = 2,
				shape = function(cr, width, height)
					gears.shape.rounded_rect(cr, width, height, 8)
				end,
				{
					layout = wibox.layout.fixed.vertical,
					{
						layout = wibox.layout.fixed.horizontal,
						{
							icon,
							widget = wibox.container.margin,
							right = 10,
							top = 10,
							bottom = 10,
							left = 10,
						},
						title
					},
					{
						widget = wibox.container.margin,
						top = 25,
						left = 120,
						bottom = 40,
						preview
					}
				},
			},
		})

		if #client_widgets == 4 then
			table.insert(all_widgets, client_widgets)
			client_widgets = { layout = wibox.layout.flex.horizontal }
		end
	end

	if #client_widgets ~= 0 then
		table.insert(all_widgets, {
			widget = wibox.container.margin,
			left = alt_tab_widget.width / 2 - (#client_widgets * 400 / 2),
			right = alt_tab_widget.width / 2 - (#client_widgets * 400 / 2),
			client_widgets
		})
	end

	awful.placement.align(alt_tab_widget,
		{ position = "centered", honor_workarea = true, margins = { top = theme.custom.default_margin } }
	)

	alt_tab_widget:setup(all_widgets)
end

function alt_tab_widget:cycle()
	selected_client_index = ((selected_client_index) % #client.get()) + 1
	self:refresh()
	self.visible = true
end

function alt_tab_widget:hide()
	if not self.visible then return end

	local confirmed_client = clients[selected_client_index]
	if confirmed_client then
		confirmed_client.first_tag:view_only()
		client.focus = confirmed_client
		confirmed_client:raise()
	end

	selected_client_index = 1
	self.visible = false
end

function alt_tab_widget:toggle()
	if not self.visible then
		self:refresh()
		self.visible = true
	else
		self:hide()
	end
end

return { widget = alt_tab_widget }
