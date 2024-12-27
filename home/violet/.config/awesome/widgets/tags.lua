local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local preferences = require("preferences")

-- Tag widget
local tags_widget = wibox({
	visible = false,
	ontop = true,
	type = "popup_menu",
	screen = screen.primary,
	width = 600,
	height = 100,
	bg = "#ff000000",
})

--- Refreshes the tag widget.
local tag_widgets = { layout = wibox.layout.flex.horizontal }

for tag_number = 1, 5 do
	local individual_widget = wibox.widget.textbox()

	local color = preferences.theme.primary_foreground
	local background = preferences.theme.primary_background
	if awful.screen.focused().selected_tag and awful.screen.focused().selected_tag.index == tag_number then
		color = preferences.theme.primary_background
		background = preferences.theme.primary_foreground
	end

	individual_widget.markup = ('<span color="%s">%s</span>'):format(color, tostring(tag_number))
	individual_widget.align = "center"
	individual_widget.font = "opensans 48"
	individual_widget = {
		{
			widget = wibox.container.background,
			bg = background,
			border_color = preferences.theme.primary_foreground,
			border_width = preferences.theme.border_width,
			shape = function(cr, width, height)
				gears.shape.rounded_rect(cr, width, height, 12)
			end,
			{
				individual_widget,
				widget = wibox.container.margin,
				left = 20,
				right = 20,
			},
		},
		widget = wibox.container.margin,
		right = 10,
		left = 10,
	}

	table.insert(tag_widgets, individual_widget)
end

tags_widget:setup({
	tag_widgets,
	layout = wibox.layout.flex.horizontal,
})

function tags_widget:refresh()
	for index, widget in ipairs(tag_widgets) do
		local color = preferences.theme.primary_foreground
		local background = preferences.theme.primary_background
		if awful.screen.focused().selected_tag and awful.screen.focused().selected_tag.index == index then
			color = preferences.theme.primary_background
			background = preferences.theme.primary_foreground
		end
		widget[1].bg = background
		widget[1][1][1].markup = ('<span color="%s">%s</span>'):format(color, tostring(index))
	end

	tags_widget:setup({
		tag_widgets,
		layout = wibox.layout.flex.horizontal,
	})
end

-- Sliding animation

local top = -110
local slide_speed = 20

local function slide_in()
	awful.placement.align(tags_widget, {
		position = "top",
		honor_workarea = true,
		margins = { right = preferences.theme.default_margin, top = top }
	})
	top = top + slide_speed
	if top < 20 then
		awful.spawn.easy_async("sleep 0.001", function()
			slide_in()
		end)
	else
		top = 20
		awful.placement.align(tags_widget, {
			position = "top",
			honor_workarea = true,
			margins = { right = preferences.theme.default_margin, top = top }
		})
	end
end

local function slide_out()
	awful.placement.align(tags_widget, {
		position = "top",
		honor_workarea = true,
		margins = { right = preferences.theme.default_margin, top = top }
	})
	top = top - slide_speed
	if top > -110 then
		awful.spawn.easy_async("sleep 0.001", function()
			slide_out()
		end)
	else
		top = -110
		awful.placement.align(tags_widget, {
			position = "top",
			honor_workarea = true,
			margins = { right = preferences.theme.default_margin, top = top }
		})
		tags_widget.visible = false
	end
end

function tags_widget:toggle()
	if self.visible then
		self:hide()
	else
		self:show()
	end
end

function tags_widget:hide()
	slide_out()
end

function tags_widget:show()
	self:refresh()
	self.visible = true
	slide_in()
end

return {
	widget = tags_widget,
}
