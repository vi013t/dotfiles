return {

	-- {
	-- 	"nvchad/ui",
	-- 	dependencies = {
	-- 		"nvchad/base46",
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-tree/nvim-web-devicons",
	-- 		"nvchad/volt", -- optional, needed for theme switcher
	-- 	},
	-- 	config = function()
	-- 		require("nvchad")
	--
	-- 		dofile(vim.g.base46_cache .. "defaults")
	-- 		dofile(vim.g.base46_cache .. "statusline")
	-- 	end,
	-- 	build = function()
	-- 		require("base46").load_all_highlights()
	-- 	end,
	-- },

	-- or just use Telescope themes

	-- Icons & overrides
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			override = {
				rkt = {
					icon = "λ",
					color = "#E30000",
					name = "Racket",
				},
				clangd = {
					icon = "",
					color = "#888899",
					name = "ClangD",
				},
				kl = {
					icon = "󰡔",
					color = "#00FFBB",
					name = "Klein",
				},
			},
		},
	},

	-- Better help views
	{
		"OXY2DEV/helpview.nvim",
		opts = {},
		ft = "help",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},

	-- Highlight colors in the editor such as #4a08a9, rgb(0, 255, 255), and hsl(150, 100, 50)
	{
		"brenoprata10/nvim-highlight-colors",
		opts = {},
		event = "BufEnter",
	},

	-- Theme switcher
	{
		"zaldih/themery.nvim",
		config = function()
			require("themery").setup({
				themes = {
					{
						name = "Catppuccin Mocha",
						colorscheme = "catppuccin-mocha",
						after = [[
							vim.api.nvim_set_hl(0, "@function.builtin", { link = "Operator" })
							vim.cmd("hi DiagnosticUnderlineError gui=undercurl term=undercurl cterm=undercurl")
							vim.cmd("hi DiagnosticUnderlineWarn gui=undercurl term=undercurl cterm=undercurl")
							vim.cmd("hi DiagnosticUnderlineHint gui=undercurl term=undercurl cterm=undercurl")
							vim.cmd("hi DiagnosticUnderlineInfo gui=undercurl term=undercurl cterm=undercurl")
						]],
					},
					{
						name = "Tokyo Night",
						colorscheme = "tokyonight",
					},
					{
						name = "Dusk Fox",
						colorscheme = "duskfox",
					},
					{
						name = "Morta",
						colorscheme = "morta",
					},
				},
			})
			vim.keymap.set("n", "<leader>t", ":Themery<cr>", {})
		end,
	},

	-- Colorschemes (loaded by Themery when necessary)
	{ "catppuccin/nvim",           lazy = true },
	{ "folke/tokyonight.nvim",     lazy = true },
	{ "EdenEast/nightfox.nvim",    lazy = true },
	{ "philosofonusus/morta.nvim", lazy = true },

	-- Highlight comments with  TODO: in them such as this, as well as FIXME and others, also creates a list of them
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
		event = "BufEnter",
	},

	-- Indentation lines
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
				},
			})
		end,
		event = "BufEnter",
	},

	-- Command line improvements and message tooltips
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			---@diagnostic disable-next-line
			require("notify").setup({
				top_down = false,
			})

			require("noice").setup({
				presets = {
					bottom_search = true,
					command_palette = true,
					long_message_to_split = true,
					lsp_doc_border = true,
				},
			})

			vim.keymap.set("n", "<leader>nc", ":NoiceDismiss<cr>", {}) -- Copy to system clipboard
		end,
	},

	-- Better UIs for menus and pickers
	{
		"stevearc/dressing.nvim",
		keys = {
			{ "<leader>ly", vim.lsp.buf.code_action, desc = "Accept Code Action" },
		},
	},

	-- file tree explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim",
			{
				"folke/edgy.nvim",
				opts = {
					wo = {
						winbar = false,
					},
					bottom = {
						{
							ft = "toggleterm",
							size = { height = 15 },
						},
					},
					left = {
						{
							ft = "neo-tree",
							size = { width = 35 },
						},
						{
							title = "Call Stack",
							ft = "Calltree",
							size = { width = 35 },
						},
					},
					animate = {
						enabled = false,
					},
				},
			},
		},
		config = function()
			require("neo-tree").setup({
				hide_root_node = true,
				close_if_last_window = true,
				enable_diagnostics = true,
				filesystem = {
					filtered_items = {
						visible = true,
						hide_gitignored = false,
						hide_dotfiles = false,
						never_show_by_pattern = {
							"*.meta",
						},
					},
					follow_current_file = {
						enabled = true,
					},
					use_libuv_file_watcher = true,
				},
				window = {
					position = "left",
					width = 30,
				},
				default_component_configs = {
					modified = {
						symbol = "󰧟 ",
					},
					git_status = {
						symbols = {
							added = "+",
							modified = "",
							untracked = "+",
							deleted = "󰩹",
							renamed = "󰗧",
							staged = "",
							unstaged = "",
							conflict = "",
							ignored = "󰈉",
						},
					},
				},
			})

			vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#88FF88" })
			vim.keymap.set("n", "<leader>eu", ":wincmd p<CR>", {})
		end,
		keys = {
			{
				"<leader>ef",
				function()
					if vim.fn.exists(":DragonflyProject") == 2 then
						require("dragonfly.project_ui").close()
					end
					if not vim.g.project_cwd then
						local directory = vim.fn.expand("%:h")
						if directory == nil or directory:match("^%s*$") then
							directory = vim.fn.getcwd()
						end
						local root = vim.system({ "findroot" }, { text = true, cwd = directory }):wait().stdout:gsub(" ",
							"\\ ")
						vim.g.project_cwd = root
					end
					vim.cmd("Neotree dir=" .. vim.g.project_cwd)
				end,
				desc = "Neotree",
			},
		},
	},

	-- Pretty bottom status bar
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				extensions = {
					"neo-tree",
					"lazy",
					"mason",
					"trouble",
					"man",
				},
				sections = {
					-- Set mode name to Camelcase
					lualine_a = {
						{
							"mode",
							fmt = function(str)
								local mode = str:sub(1, 1) .. str:sub(2, str:len()):lower()
								local mode_overrides = {
									Normal = "Navigate",
									Visual = "Select",
									["V-line"] = "Select Line",
								}
								return mode_overrides[mode] or mode
							end,
						},
					},

					-- Set the "B" section to be the file type
					lualine_b = {
						{
							"filetype",
							fmt = function(type)
								local formatted = type:sub(1, 1):upper() .. type:sub(2, type:len())
								local special_formats = {
									Cs = "C#",
									Cpp = "C++",
									Javscript = "JavaScript",
									Typescript = "TypeScript",
									Llvm = "LLVM",
									Json = "JSON",
									Jsonc = "JSON + Comments",
									Css = "CSS",
									Html = "HTML",
									Toml = "TOML",
									Typescriptreact = "TypeScript + Syntax Extension",
									Javascriptreact = "JavaScript + Syntax Extension",
									Gitignore = "Git Ignore",
									Scss = "Sass",
									Toggleterm = "Terminal",
								}

								return special_formats[formatted] or formatted
							end,
						},
					},

					-- Set the "C" section to be the Git branch name for rehabilitatoin
					lualine_c = {
						"branch",
					},

					-- Set the "Y" section to be the file name
					lualine_y = {
						{
							"filename",
							fmt = function()
								local path = vim.fn.expand("%:p")
								local cwd = vim.fn.getcwd()
								if path:sub(1, cwd:len()):gsub("\\", "/") == cwd:gsub("\\", "/") then
									path = path:sub(cwd:len() + 2, path:len())
								end
								if path == "/home/violet/.config/nvim/init.lua" then
									path = " Neovim Config"
								end

								if path:sub(1, #"term:") == "term:" then
									path = " Terminal"
								end
								return path
							end,
						},
					},

					-- Set "X" section to diagnostics
					lualine_x = {
						{
							"diagnostics",
							symbols = {
								warn = " ",
								error = " ",
								hint = "󰌵 ",
								info = " ",
							},
							fmt = function(diagnostics)
								if diagnostics:match("^%s*$") then
									local lsps = ""
									for _, lsp in ipairs(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })) do
										lsps = lsps .. " " .. lsp.name .. " "
									end
									return lsps
								end

								return diagnostics
							end,
						},
					},

					-- Set the "Z" section to be the line count
					lualine_z = {
						{
							"location",
							fmt = function()
								---@type number | string
								local lines = vim.fn.line("$")
								if lines > 1000 then
									lines = "‼ " .. lines
								end
								return lines .. " Lines"
							end,
						},
					},
				},
			})
		end,
	},

	-- Visual Whitespace
	{
		"mcauley-penney/visual-whitespace.nvim",
		event = "ModeChanged *:[vV\x16]",
		config = function()
			local bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Visual")), "bg#")
			require("visual-whitespace").setup({
				highlight = { fg = "#777799", bg = bg },
			})
		end,
	},

	-- Dashboard
	{
		"goolord/alpha-nvim",
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")
			dashboard.section.header.opts.hl = "@comment"
			dashboard.section.buttons.val = {}
			dashboard.section.header.val = {
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
				"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
				"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
				"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
				"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
				"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"                                                     ",
				"            ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆                   ",
				"             ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦                ",
				"                   ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄              ",
				"                    ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄             ",
				"                   ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀            ",
				"            ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄           ",
				"           ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄            ",
				"          ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄           ",
				"          ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄          ",
				"               ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆              ",
				"                ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃              ",
				"                                                     ",
			}
			alpha.setup(dashboard.opts)
		end,
	},

	-- Image rendering
	{
		"3rd/image.nvim",
		opts = {
			backend = "ueberzug",
			processor = "magick_cli",
		},
		build = false,
		cond = function()
			return vim.fn.has("win32") == 0
		end,
		ft = "markdown",
	},
}
