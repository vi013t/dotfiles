local theme = {}

-- Values to be ignored by beautiful and used for custom widgets
theme.custom = {
	primary_background = "#0E0C12",
	primary_foreground = "#9280FF",
	secondary_foreground = "#50496B",
	default_margin = 12,
}

-- Titlebar
theme.titlebar_enabled = true
theme.titlebar_bg = theme.custom.primary_background

-- Borders
theme.border_focus = theme.custom.primary_foreground
theme.border_normal = theme.custom.primary_foreground
theme.border_marked = theme.custom.primary_foreground
theme.border_width = 2

return theme
