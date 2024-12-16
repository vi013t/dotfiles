local public = {}

public.battery = {}

---@return number
function public.battery:percent()
	return assert(tonumber(io.open("/sys/class/power_supply/BAT0/capacity"):read("a")))
end

---@return boolean
function public.battery:is_charging()
	return io.open("/sys/class/power_supply/BAT0/status"):read("a"):match("%s*([^%s]+)%s*") == "Charging"
end

-- Returns an icon for the battery based on the current state.
---@return string
function public.battery:get_icon()
	local battery_icons = {
		"󱊡", -- 00% - 10%
		"󰁻", -- 10% - 20%
		"󰁼", -- 20% - 30%
		"󰁽", -- 30% - 40%
		"󰁾", -- 40% - 50%
		"󰁿", -- 50% - 60%
		"󰂀", -- 60% - 70%
		"󰂁", -- 70% - 80%
		"󰂂", -- 80% - 90%
		"󰁹", -- 90% - 100%
		"󰁹", -- 100%
	}

	local charging_icons = {
		"󰢜", -- 00% - 10%
		"󰂆", -- 10% - 20%
		"󰂇", -- 20% - 30%
		"󰂈", -- 30% - 40%
		"󰢝", -- 40% - 50%
		"󰂉", -- 50% - 60%
		"󰢞", -- 60% - 70%
		"󰂊", -- 70% - 80%
		"󰂋", -- 80% - 90%
		"󰂅", -- 90% - 100%
		"󰂅", -- 100%
	}

	local icon_set = battery_icons
	if self:is_charging() then
		icon_set = charging_icons
	end

	return icon_set[math.floor(self:percent() / 10.0) + 1]
end

public.wifi = {}

function public.wifi:name()
	return io.popen("iwgetid -r"):read("a"):gsub("\n$", "")
end

return public
