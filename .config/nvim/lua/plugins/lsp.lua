return {
	-- LSP
	{
		"vi013t/forge.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			"stevearc/conform.nvim",
		},
		opts = {
			ui = {
				window_config = {
					border = "rounded"
				}
			},
		},
		init = function()
			vim.keymap.set("n", "<leader>fr", ":Forge<CR>", {})       -- Open Forge.nvim
			vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, {})  -- Show hover information
			vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, {}) -- Jump to definition
			vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, {}) -- Jump to definition
			vim.keymap.set("n", "<leader>ln", vim.diagnostic.goto_next, {}) -- Go to next LSP diagnostic
			vim.keymap.set("n", "<leader>lp", vim.diagnostic.goto_prev, {}) -- Go to previous LSP diagnostic
		end
	},

	-- Incremental LSP rename
	{
		"smjonas/inc-rename.nvim",
		dependencies = { "stevearc/dressing.nvim" },
		opts = {
			input_buffer_type = "dressing",
		},
		keys = {
			{ "<leader>lr", ":IncRename ", desc = "Incremental Rename" },
		},
	},

	-- Rust support
	{
		"rust-lang/rust.vim",
		dependencies = {
			"simrat39/rust-tools.nvim",
			"neovim/nvim-lspconfig",
		},
		ft = "rust",
	},

	-- Call Hierarchy
	{
		"marcomayer/calltree.nvim",
		opts = {
			icons = "codicons"
		},
		keys = {
			{
				"<leader>lc",
				function()
					vim.cmd("NeoTreeClose")
					vim.lsp.buf.incoming_calls()
				end
			}
		},
		init = function()
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "incomingCalls:1",
				callback = function(args)
					vim.api.nvim_buf_set_keymap(args.buf, "n", "q",
						(":CTClose<CR>:Neotree dir=%s<CR>"):format(vim.g.project_cwd), {})
				end
			})
		end
	}

}
