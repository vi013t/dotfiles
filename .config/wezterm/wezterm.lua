-- Wezterm API
local wezterm = require("wezterm")

-- Main configuration
local config = {}

-- Text & Fonts
config.font = wezterm.font("Consolas")
config.font_size = 13
config.allow_square_glyphs_to_overflow_width = "Never"

-- Colors
config.colors = {
	background = "#1E1E2E",
	foreground = "white",
	cursor_bg = "dodgerblue",
	cursor_fg = "black",
	tab_bar = {
		active_tab = {
			bg_color = "#1E1E2E",
			fg_color = "#FFFFFF",
		},
		inactive_tab = {
			bg_color = "#181825",
			fg_color = "#808080",
		},
		new_tab = {
			bg_color = "transparent",
			fg_color = "#CCCCCC",
		},
		new_tab_hover = {
			fg_color = "white",
			bg_color = "transparent",
		},
	},
}

-- config.window_background_gradient = {
-- 	orientation = "Vertical",
-- 	colors = {
-- 		"#000000",
-- 		"#170F39",
-- 	},
-- }

-- Tabs
local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end
	return tab_info.active_pane.title
end

-- Tab names
wezterm.on("format-tab-title", function(tab)
	local title = tab_title(tab)
	if tab.is_active then
		return {
			{ Text = " " .. title:match(":(.+)") .. " " },
		}
	end
	return title
end)

-- Tab bar background
config.window_frame = {
	active_titlebar_bg = "#11111B",
	inactive_titlebar_bg = "#11111B",
}

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_rate = 400

-- Keys
config.keys = {
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "t", mods = "CTRL", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "C", mods = "CTRL", action = wezterm.action.CopyTo("Clipboard") },
}

return config
