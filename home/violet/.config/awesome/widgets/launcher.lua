local wibox = require("wibox")
local awful = require("awful")
local preferences = require("preferences")
local gears = require("gears")

-- Launcher
local launcher = wibox({ visible = false, ontop = true, type = "dock", screen = screen.primary })
launcher.width = 500
launcher.height = 500
launcher.bg = preferences.theme.primary_background
launcher.border_width = 2
launcher.border_color = preferences.theme.primary_foreground
launcher.shape = function(cr, width, height)
	gears.shape.rounded_rect(cr, width, height, 15)
end
awful.placement.top_right(launcher, {
	honor_workarea = true,
	margins = { right = preferences.theme.default_margin * 2 + 500, top = preferences.theme.default_margin }
})

---@alias App { name: string, icon: string }

---@type App[]
local apps = {}

local function get_app_icon(app_name, icon_name, command)
	-- Find the path to the app icon:
	--
	-- First, we run `find /usr/share/icons -name <APPNAME>.png`. This will list all icons with the given app name.
	--
	-- Then, that gets piped into `sort --version-sort -r`. This sorts the results alphabetically. The `--version-sort`
	-- flag makes sure numbers are sorted correctly; So 11 comes after 2, for example. `-r` sorts in reverse order,
	-- so we get the largest numbers first. This way higher resolution icons, such as 256x256, are listed first over
	-- lower resolution ones like 16x16.
	--
	-- Finally, that gets piped into `head -n 1`, which will make it so only the first result is displayed. This is
	-- the icon path used.
	awful.spawn.easy_async_with_shell(
		('find /usr/share/icons -name %s.png | sort --version-sort -r | head -n 1'):format(icon_name),
		function(path)
			path = path:match("([^\r\n]+)[\r\n]*$")
			if path then
				table.insert(apps, { name = app_name, icon = path, command = command })
			end
		end
	)
end

-- Register applications
awful.spawn.easy_async("ls /usr/share/applications -1", function(applications)
	for app in applications:gmatch("([^\n]+)") do
		local file = assert(io.open("/usr/share/applications/" .. app, "r"))
		local info = file:read("*a")
		local icon = info:match("Icon=([^\r\n]+)")
		local name = info:match("Name=([^\r\n]+)")
		local command = info:match("Exec=([^\r\n]+)")
		file:close()
		get_app_icon(name, icon, command)
	end
end)

--- Returns the "distance" between two strings, case insensitively, according to the
--- [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance) algorithm,
--- with certain special exceptions.
---
--- The "Levenshtein distance" essentially represents how close two strings are, with a lower
--- distance meaning closer strings. The one exception in this case is that this function
--- prioritizes prefix matching, i.e., the words `fire` and `firefox` will be closer together
--- than `girefoy` and `firefox`. This is because when using this to determine launcher results,
--- we want to be able to show programs without typing in their full name. Importantly, this also
--- makes this algorithm non-symmetric. The first argument should be considered the "prefix" while
--- the second is the full word.
---
--- This is used to show program results in the launcher widget.
---
--- This algorithm is adapted and modified from `https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows`.
---
---@param first string The first string to get the distance from the other.
---@param other string The other string to get the distance from the first.
---
---@return integer distance The distance between the two strings. This will always be nonnegative, and only 0 if the two strings are
--- the same (case insensitive)
local function distance_between(first, other)
	first = first:lower()
	other = other:lower()

	if first == other then
		return 0
	end

	if other:sub(1, #first) == first then
		return 1
	end

	local dummy
	local m = #first
	local n = #other

	local v0 = {}
	local v1 = {}

	for i = 0, #other do
		v0[i] = i
	end

	for i = 0, m - 1 do
		v1[0] = i + 1
		for j = 0, n - 1 do
			local deletion_cost = v0[j + 1]
			local insertion_cost = v1[j] + 1

			local substitution_cost = v0[j] + 1
			if first:sub(i + 1, i + 1) == other:sub(j + 1, j + 1) then
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

--- Sorts the launcher's programs by the given search text, showing closest
--- matches first.
---
---@param search_text string The program being searched
---
---@return nil
function launcher:sort(search_text)
	-- Sort programs by search text
	local sorted = {}
	for _, app in ipairs(apps) do
		table.insert(sorted, app)
	end
	table.sort(sorted, function(a, b)
		local a_text = a.name
		local b_text = b.name
		local a_distance = distance_between(a_text, search_text)
		local b_distance = distance_between(b_text, search_text)
		return a_distance < b_distance
	end)
	launcher.apps = sorted
	local sorted_widgets = { layout = wibox.layout.fixed.vertical }

	-- Add program result widgets
	for _, app in ipairs(sorted) do
		-- Program icon
		local icon_widget = wibox.widget.imagebox(app.icon)
		icon_widget.forced_width = 70
		icon_widget.forced_height = 70

		-- Program name
		local name_widget = wibox.widget.textbox()
		name_widget.markup = ('<span color="%s">%s</span>'):format(preferences.theme.primary_foreground, app.name)
		name_widget.font = preferences.theme.font_size(20)

		-- Composite widget
		local app_widget = {
			layout = wibox.layout.fixed.horizontal,
			{
				widget = wibox.container.margin,
				top = 15,
				left = 15,
				right = 15,
				bottom = 15,
				icon_widget,
			},
			name_widget,
		}

		-- Add it
		table.insert(sorted_widgets, app_widget)
	end

	-- Highlight first entry
	sorted_widgets[1] = {
		sorted_widgets[1],
		widget = wibox.container.background,
		bg = "#2C2C4C",
	}

	-- Add the widgets to the launcher
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

--- Toggles the launcher widget
function launcher:toggle()
	if self.visible then
		self:hide()
	else
		self:show()
	end
end

--- Shows the launcher widget.
function launcher:show()
	self.visible = true
end

--- Hides the launcher widget.
function launcher:hide()
	self.visible = false
end

-- Return the widget
return {
	widget = launcher,
}
