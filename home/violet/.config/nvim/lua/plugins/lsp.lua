return {

	-- TreeSitter
	{
		"nvim-treesitter/nvim-treesitter",
		init = function()
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			---@diagnostic disable-next-line: inject-field
			parser_config.klein = {
				install_info = {
					url = "~/Documents/Coding/Developer Tools/Klein/tree-sitter-klein",
					files = { "src/parser.c" },
				},
			}
			vim.treesitter.language.register('klein', 'klein')
		end,
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
	},

}
