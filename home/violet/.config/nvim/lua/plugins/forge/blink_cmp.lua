return {
	"saghen/blink.cmp",
version = "*",
event = "InsertEnter",
opts = {
	keymap = { preset = 'super-tab' },
	appearance = { nerd_font_variant = 'normal' },
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
	},
},
opts_extend = { "sources.default" }
				}