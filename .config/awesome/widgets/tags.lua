local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local theme = require("misc.theme")

local tags_widget = wibox({ visible = false, ontop = true, type = "dock", screen = screen.primary })
tags_widget.width = 600
tags_widget.height = 100
tags_widget.visible = true
tags_widget.bg = "#FF000000"

awful.placement.align(tags_widget,
	{ position = "top", honor_workarea = true, margins = { top = theme.custom.default_margin } })

function tags_widget:refresh_numbers()
	local tag_widgets = { layout = wibox.layout.flex.horizontal }

	for tag_number = 1, 5 do
		local individual_widget = wibox.widget.textbox()

		local color = theme.custom.primary_foreground
		local background = theme.custom.primary_background
		if awful.screen.focused().selected_tag and awful.screen.focused().selected_tag.index == tag_number then
			color = theme.custom.primary_background
			background = theme.custom.primary_foreground
		end

		individual_widget.markup = ('<span color="%s">%s</span>'):format(color, tostring(tag_number))
		individual_widget.align = "center"
		individual_widget.font = "OpenSans 48"
		individual_widget = {
			{
				{
					individual_widget,
					widget = wibox.container.margin,
					left = 20,
					right = 20,
				},
				widget = wibox.container.background,
				bg = background,
				border_color = theme.custom.primary_foreground,
				border_width = 2,
				shape = function(cr, width, height)
					gears.shape.rounded_rect(cr, width, height, 12)
				end,
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
end

-- Sliding animation

local top = -110
local slide_speed = 20

local is_moving = false

local function slide_in()
	is_moving = true
	awful.placement.align(tags_widget,
		{ position = "top", honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
	top = top + slide_speed
	if top < 20 then
		awful.spawn.easy_async_with_shell("sleep 0.001", function()
			slide_in()
		end)
	else
		is_moving = false
		top = 20
		awful.placement.align(tags_widget,
			{ position = "top", honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
	end
end

local function slide_out()
	is_moving = true
	awful.placement.align(tags_widget,
		{ position = "top", honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
	top = top - slide_speed
	if top > -110 then
		awful.spawn.easy_async_with_shell("sleep 0.001", function()
			slide_out()
		end)
	else
		is_moving = false
		top = -110
		awful.placement.align(tags_widget,
			{ position = "top", honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
		tags_widget.visible = false
	end
end

function tags_widget:toggle()
	if not self.visible then
		self:open()
	else
		self:close()
	end
end

function tags_widget:close()
	if is_moving then return end
	slide_out()
end

function tags_widget:open()
	if is_moving then return end
	self.visible = true
	self:refresh_numbers()
	slide_in()
end

tags_widget.visible = false

return {
	widget = tags_widget,
}
