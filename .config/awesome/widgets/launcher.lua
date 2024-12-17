local wibox = require("wibox")
local awful = require("awful")
local theme = require("misc.theme")
local gears = require("gears")

local launcher = wibox({ visible = false, ontop = true, type = "dock", screen = screen.primary })
launcher.width = 500
launcher.height = 500
launcher.bg = theme.custom.primary_background
launcher.border_width = 2
launcher.border_color = theme.custom.primary_foreground
launcher.shape = function(cr, width, height)
	gears.shape.rounded_rect(cr, width, height, 15)
end

local apps = {}

local function get_app_icon(app_name, icon_name)
	awful.spawn.easy_async_with_shell(
		('find /usr/share/icons -name %s.png | sort --version-sort -r | head -n 1'):format(icon_name),
		function(path)
			path = path:match("([^\r\n]+)[\r\n]*$")
			if path then
				table.insert(apps, { name = app_name, icon = path })
			end
		end
	)
end

awful.placement.top_right(
	launcher,
	{ honor_workarea = true, margins = { right = theme.custom.default_margin * 2 + 500, top = theme.custom.default_margin } }
)

awful.spawn.easy_async_with_shell("ls /usr/share/applications -1", function(applications)
	for app in applications:gmatch("([^\n]+)") do
		local file = assert(io.open("/usr/share/applications/" .. app, "r"))
		local info = file:read("*a")
		local icon = info:match("Icon=([^\r\n]+)")
		local name = info:match("Name=([^\r\n]+)")
		file:close()
		get_app_icon(name, icon)
	end
end)

local function levenshtein(a, b)
	a = a:lower()
	b = b:lower()

	if a == b then
		return -2
	end
	if b:sub(1, #a) == a then
		return -1
	end

	local dummy
	local m = #a
	local n = #b

	local v0 = {}
	local v1 = {}

	for i = 0, #b do
		v0[i] = i
	end

	for i = 0, m - 1 do
		v1[0] = i + 1
		for j = 0, n - 1 do
			local deletion_cost = v0[j + 1]
			local insertion_cost = v1[j] + 1

			local substitution_cost = v0[j] + 1
			if a:sub(i + 1, i + 1) == b:sub(j + 1, j + 1) then
				substitution_cost = v0[j]
			end

			v1[j + 1] = math.min(deletion_cost, insertion_cost, substitution_cost)
		end

		dummy = v0
		v0 = v1
		v1 = dummy
	end

	return v0[n]
end

local app_widgets

function launcher:refresh_numbers()
	app_widgets = { layout = wibox.layout.fixed.vertical }

	for _, app in ipairs(apps) do
		local icon_widget = wibox.widget.imagebox(app.icon)
		icon_widget.forced_width = 70
		icon_widget.forced_height = 70

		local name_widget = wibox.widget.textbox()
		name_widget.markup = ('<span color="%s">%s</span>'):format(theme.custom.primary_foreground, app.name)
		name_widget.font = "OpenSans 20"

		local app_widget = {
			{
				icon_widget,
				widget = wibox.container.margin,
				top = 15,
				left = 15,
				right = 15,
				bottom = 15,
			},
			name_widget,
			layout = wibox.layout.fixed.horizontal,
		}
		table.insert(app_widgets, app_widget)
	end

	launcher:setup({
		{
			app_widgets,
			widget = wibox.container.background,
			clip = true,
			spacing = 25,
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.align.vertical,
	})
end

function launcher:sort(search_text)
	local sorted = {}
	for _, app in ipairs(apps) do
		table.insert(sorted, app)
	end
	table.sort(sorted, function(a, b)
		local a_text = a.name
		local b_text = b.name
		local a_distance = levenshtein(a_text, search_text)
		local b_distance = levenshtein(b_text, search_text)
		return a_distance < b_distance
	end)

	launcher.apps = sorted

	local sorted_widgets = { layout = wibox.layout.fixed.vertical }

	for _, app in ipairs(sorted) do
		local icon_widget = wibox.widget.imagebox(app.icon)
		icon_widget.forced_width = 70
		icon_widget.forced_height = 70

		local name_widget = wibox.widget.textbox()
		name_widget.markup = ('<span color="%s">%s</span>'):format(theme.custom.primary_foreground, app.name)
		name_widget.font = "OpenSans 20"

		local app_widget = {
			{
				icon_widget,
				widget = wibox.container.margin,
				top = 15,
				left = 15,
				right = 15,
				bottom = 15,
			},
			name_widget,
			layout = wibox.layout.fixed.horizontal,
		}
		table.insert(sorted_widgets, app_widget)
	end

	sorted_widgets[1] = {
		sorted_widgets[1],
		widget = wibox.container.background,
		bg = "#2C2C4C",
	}

	launcher:setup({
		{
			sorted_widgets,
			widget = wibox.container.background,
			clip = true,
			spacing = 25,
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.align.vertical,
	})
end

function launcher:toggle()
	self.visible = not self.visible
	if self.visible then
		launcher:refresh_numbers()
	end
end

function launcher:show()
	self.visible = true
	launcher:refresh_numbers()
end

function launcher:hide()
	self.visible = false
end

return {
	widget = launcher,
}
