return {
	-- Auto-generate licenses
	{
		"antoyo/vim-licenses",
		config = function()
			vim.g.license_copyright_holders_name = "Neph Iapalucci"
			vim.g.license_authors_name = "Neph Iapalucci"
		end,
		cmd = {
			"Affero",
			"Allpermissive",
			"Apache",
			"Boost",
			"Bsd2",
			"Bsd3",
			"Cc0",
			"Ccby",
			"Ccbysa",
			"Cecill",
			"Epl",
			"Gfdl",
			"Gpl",
			"Gplv2",
			"Isc",
			"Lgpl",
			"Mit",
			"Mitapache",
			"Mpl",
			"Uiuc",
			"Unlicense",
			"Verbatim",
			"Wtfpl",
			"Zlib",
		},
	},

	-- Icon picker for writing icons such as     etc
	{
		"ziontee113/icon-picker.nvim",
		dependencies = {
			{ "nvim-telescope/telescope.nvim", opts = {} },
			"stevearc/dressing.nvim",
		},
		opts = {},
		keys = {
			{ "<leader>m", "<cmd>IconPickerNormal nerd_font_v3 alt_font symbols emoji<cr>", desc = "Insert Symbols" },
		},
	},

	-- Todo diagnostic list
	{
		"folke/trouble.nvim",
		cmd = "TodoTrouble",
	},

	-- sudo write files
	{
		"lambdalisue/suda.vim",
		keys = {
			{ "<leader>w", "<cmd>SudaWrite<cr>" }
		}
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
		dependencies = {
			{
				"folke/edgy.nvim",
				opts = {
					wo = {
						winbar = false,
					},
					bottom = {
						"toggleterm",
						size = 15,
					},
					left = {
						"neo-tree",
						size = 35,
					},
					animate = {
						enabled = false,
					},
				},
			},
		},
		opts = {},
		keys = {
			{ "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
		},
	},
}
