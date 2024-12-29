local awful = require("awful")
local gears = require("gears")

--- A minimal animation library for AwesomeWM.
local animate = {}

---@class AnimationProperties
---@field widget any
---@field placement string
---@field from string
---@field thickness integer
---@field time number
---@field margins? {left?: integer, right?: integer, top?: integer?, bottom?: integer }
---@field on_complete? fun(): nil

--- Performs a "slide in" animation on the given wiget.
---
---@param properties AnimationProperties The animation's properties:
--- - `widget` - The widget to animate.
--- - `placement` - Where to place the widget, as a key of `awful.placement`.
--- - `from` - The side to slide in from.
--- - `thickness` - The size of the widget along the sliding axis.
--- - `time` - The amount of time, in seconds, that the animation should take.
--- - `margins` - The margins around the widget.
--- - `on_complete` - An optional callback to run when the animation finishes.
---
---@return nil
function animate.slide_in(properties)
	local current_position = -properties.thickness
	local slide_speed = 0.1 * properties.thickness / properties.time
	local extra_offset = properties.margins[properties.from] or 0

	local function slide_in()
		-- Place
		awful.placement[properties.placement](properties.widget, {
			honor_workarea = true,
			margins = gears.table.crush(gears.table.clone(properties.margins), { [properties.from] = current_position })
		})
		current_position = current_position + slide_speed

		-- Not there yet - keep sliding
		if current_position < extra_offset then
			awful.spawn.easy_async("sleep 0.001", function()
				slide_in()
			end)

			-- Done
		else
			current_position = extra_offset
			awful.placement[properties.placement](properties.widget, {
				honor_workarea = true,
				margins = gears.table.crush(gears.table.clone(properties.margins),
					{ [properties.from] = current_position })
			})
			if properties.on_complete then
				properties.on_complete()
			end
		end
	end

	properties.widget.visible = true
	slide_in()
end

--- Performs a "slide out" animation on the given wiget.
---
---@param properties AnimationProperties The animation's properties:
--- - `widget` - The widget to animate.
--- - `placement` - Where to place the widget, as a key of `awful.placement`.
--- - `from` - The side to slide in from.
--- - `thickness` - The size of the widget along the sliding axis.
--- - `time` - The amount of time, in seconds, that the animation should take.
--- - `margins` - The margins around the widget.
--- - `on_complete` - An optional callback to run when the animation finishes.
---
---@return nil
function animate.slide_out(properties)
	local current_position = 0
	local slide_speed = 0.1 * properties.thickness / properties.time

	local function slide_out()
		-- Place
		awful.placement[properties.placement](properties.widget, {
			honor_workarea = true,
			margins = gears.table.crush(gears.table.clone(properties.margins), { [properties.from] = current_position })
		})
		current_position = current_position - slide_speed

		-- Not there yet - keep sliding
		if current_position > -properties.thickness then
			awful.spawn.easy_async("sleep 0.001", function()
				slide_out()
			end)

			-- Done
		else
			properties.widget.visible = false
			if properties.on_complete then
				properties.on_complete()
			end
		end
	end

	slide_out()
end

return animate
