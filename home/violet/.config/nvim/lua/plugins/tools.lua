return {

	-- Icon picker for writing icons such as     etc
	{
		"ziontee113/icon-picker.nvim",
		dependencies = {
			{ "nvim-telescope/telescope.nvim", lazy = true, },
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
		opts = {},
		keys = {
			{ "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
		},
	},

	-- Search & Replace
	{
		dir = "/home/violet/Documents/Coding/Developer Tools/Neovim Plugins/dragonfly.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			on_open = function()
				if vim.fn.exists(":NeoTreeClose") == 2 then vim.cmd("NeoTreeClose") end
			end,
			on_close = function()
				if not vim.g.project_cwd then
					local directory = vim.fn.expand("%:h")
					if directory == nil or directory:match("^%s*$") then directory = vim.fn.getcwd() end
					local root = vim.system({ "splik", "--find-root" }, { text = true, cwd = directory })
						:wait()
						.stdout
						:gsub(" ", "\\ ")
					vim.g.project_cwd = root
				end
				local has_neotree = pcall(function() require("neo-tree") end)
				if has_neotree then vim.cmd("Neotree dir=" .. vim.g.project_cwd) end
			end,
		},
		keys = {
			{ "/",     "<cmd>DragonflyBuffer<cr>" },
			{ "?",     "<cmd>DragonflyBufferReplace<cr>" },
			{ "<C-/>", "<cmd>DragonflyProject<cr>" },
			{ "<C-?>", "<cmd>DragonflyProjectReplace<cr>" },
		}
	},
}
