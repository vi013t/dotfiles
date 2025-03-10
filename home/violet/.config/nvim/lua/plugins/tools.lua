return {

	-- Icon picker for writing icons such as     etc
	{
		"ziontee113/icon-picker.nvim",
		dependencies = {
			{ "nvim-telescope/telescope.nvim", lazy = true },
			"stevearc/dressing.nvim",
		},
		opts = {},
		keys = {
			{ "<leader>m", "<cmd>IconPickerNormal nerd_font_v3 alt_font symbols emoji<cr>", desc = "Insert Symbols" },
		},
	},

	-- sudo write files
	{
		"lambdalisue/suda.vim",
		keys = {
			{ "<leader>w", "<cmd>SudaWrite<cr>" },
		},
	},

	-- Color picker
	{
		"vi013t/easycolor.nvim",
		dependencies = { "stevearc/dressing.nvim" },
		opts = {},
		keys = { { "<leader>b", "<cmd>EasyColor<cr>", desc = "Easy Color" } },
	},

	-- Terminal toggler
	{
		"akinsho/toggleterm.nvim",
		opts = {},
		keys = {
			{ "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
		},
	},

	-- Markdown Preview
	{
		"toppair/peek.nvim",
		ft = { "markdown" },
		build = "deno task --quiet build:fast",
		config = function()
			require("peek").setup()
			vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
			vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
		end,
	},

	-- Open alternate files
	{
		"rgroli/other.nvim",
		opts = {
			mappings = {
				{
					pattern = "(.*)/src/(.*).c$",
					target = "%1/include/%2.h",
					transformer = "lowercase",
				},
				{
					pattern = "(.*)/include/(.*).h$",
					target = "%1/src/%2.c",
					transformer = "lowercase",
				},
			},
		},
		main = "other-nvim",
		keys = {
			{ "<leader>o", "<cmd>Other<cr>" },
		},
	},

	-- Lazy
	{
		"jackMort/ChatGPT.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		cmd = "ChatGPT",
		opts = {
			openai_params = {
				model = "gpt-4o-mini",
			},
		},
	},
}
