local preferences = require("preferences")

local theme = {}

-- Titlebar
theme.titlebar_enabled = true
theme.titlebar_bg = preferences.theme.primary_background

-- Borders
theme.border_focus = preferences.theme.primary_foreground
theme.border_normal = preferences.theme.primary_foreground
theme.border_marked = preferences.theme.primary_foreground
theme.border_width = 2

return theme
