local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")

--- The main alt tab wibox widget.
local alt_tab_widget = wibox({
	visible = false,
	ontop = true,
	type = "popup_menu",
	screen = screen.primary,
	width = 600,
	height = 250,
	bg = "#ff000000",
})

--- A log kept of focused clients. This array contains, in order, the list of clients that have recieved
--- focus (in order of recency). For example, the first element in this list is always the currently
--- focused client (assuming there is one). The second element is the previously focused client, and so on.
---
--- This is used when displaying the alt-tab widget because we want to display it in order of focus-recency.
local focus_history = {}
client.connect_signal("focus", function(c)
	table.insert(focus_history, 1, c)
	for i = #focus_history, 2, -1 do
		if focus_history[i] == c then
			table.remove(focus_history, i)
		end
	end
end)

local selected_client_index = 1
local clients = {}

--- Refreshes the alt-tab widget to be up-to-date with all currently open clients.
function alt_tab_widget:refresh()
	alt_tab_widget.width = 400 * math.min(#client.get(), 4)
	alt_tab_widget.height = 250 * (math.floor((#client.get() - 1) / 4) + 1)

	-- The main widget, which stacks rows of client previews.
	local all_widgets = { layout = wibox.layout.flex.vertical, spacing = 20 }

	-- A single row of the alt-tab screen.
	local client_widgets = { layout = wibox.layout.flex.horizontal }

	-- Add all clients into a new list
	clients = {}
	for _, window in ipairs(client.get()) do
		table.insert(clients, window)
	end

	-- Sort by focus recency
	table.sort(clients, function(first, other)
		local first_index = 9999
		local other_index = 9999

		for index, value in ipairs(focus_history) do
			if value == first then first_index = index end
			if value == other then other_index = index end
		end

		return first_index < other_index
	end)

	-- Loop over all clients and add them
	for index, window in ipairs(clients) do
		local title = wibox.widget.textbox()
		local max_characters = 35
		local name = window.name:match((".?"):rep(max_characters))
		local color = preferences.theme.primary_foreground
		local tag = window.first_tag.index
		if index == selected_client_index then color = "#FFFFFF" end
		title.markup = ('<span color="%s">[%d] %s</span>'):format(color, tag, name)
		title.font = "opensans 12"

		local icon = awful.widget.clienticon(window)
		icon.forced_height = 30
		icon.forced_width = 30

		local preview = awful.widget.clienticon(window)

		-- Add the widget for the individual client
		table.insert(client_widgets, {
			widget = wibox.container.margin,
			left = 10,
			right = 10,
			{
				widget = wibox.container.background,
				bg = preferences.theme.primary_background,
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

		-- Wrap at 4 clients
		if #client_widgets == 4 then
			table.insert(all_widgets, client_widgets)
			client_widgets = { layout = wibox.layout.flex.horizontal }
		end
	end

	-- Add any left over clients
	if #client_widgets ~= 0 then
		table.insert(all_widgets, {
			widget = wibox.container.margin,
			left = alt_tab_widget.width / 2 - (#client_widgets * 400 / 2),
			right = alt_tab_widget.width / 2 - (#client_widgets * 400 / 2),
			client_widgets
		})
	end

	-- Place the widget
	awful.placement.align(alt_tab_widget,
		{ position = "centered", honor_workarea = true, margins = { top = preferences.theme.default_margin } }
	)

	-- Add the inner widgets
	alt_tab_widget:setup(all_widgets)
end

--- Moves the selected client on the alt-tab widget to the next client, or the first client
--- if the last one was selected. If the alt-tab widget is hidden, it will be shown.
function alt_tab_widget:cycle()
	selected_client_index = ((selected_client_index) % #client.get()) + 1
	self:refresh()
	self.visible = true
end

--- Hides the alt-tab widget, and resets the widget's "selected client" to the first one. The
--- currently selected client will be focused.
function alt_tab_widget:hide()
	if not self.visible then return end

	-- Focus the selected client
	local confirmed_client = clients[selected_client_index]
	if confirmed_client then
		confirmed_client.first_tag:view_only()
		client.focus = confirmed_client
		confirmed_client:raise()
	end

	-- Reset & Hide
	selected_client_index = 1
	self.visible = false
end

--- Shows the alt-tab widget, refreshing to update it with all current client information.
function alt_tab_widget:show()
	self:refresh()
	self.visible = true
end

--- Toggles the visibility of the Alt-Tab widget. If it was hidden and is now being shown,
--- it will be refreshed to show all current clients.
function alt_tab_widget:toggle()
	if not self.visible then
		self:show()
	else
		self:hide()
	end
end

-- Return the widget
return { widget = alt_tab_widget }
