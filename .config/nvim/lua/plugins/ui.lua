return {

	-- Helpdoc in floating windows
	{
		"Tyler-Barham/floating-help.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
		keys = {
			{ "<leader>h", ":FloatingHelp " },
		}
	},

	-- Better help views
	{
		"OXY2DEV/helpview.nvim",
		opts = {},
		ft = "help",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		}
	},

	-- Tabline
	{
		"akinsho/bufferline.nvim",
		config = function()
			local bufferline = require("bufferline")

			-- Get the name of the project
			local directory = vim.fn.expand("%:h")
			if not directory or directory == "" then directory = vim.fn.getcwd() end
			local found_root, root = pcall(function() return vim.fn.system("splik '" .. directory .. "' --find-root") end)
			local project_name = root
			if not found_root then
				_, project_name = vim.fn.getcwd()
			end
			project_name = assert(project_name):gsub("%s+$", ""):match("[\\/]([^\\/]+)$")

			-- Get the icon from the project language
			local success, project_language = pcall(function()
				return vim.json.decode(vim.fn.system("splik '" .. directory .. "' --output json")).languages[1].name
					:lower()
			end)
			local overrides = {
				["C#"] = "cs"
			}
			local icon = nil
			local filetype = overrides[project_language] or project_language:lower()
			if success then
				icon = require("nvim-web-devicons").get_icon_by_filetype(filetype)
			end
			if icon == nil then
				icon = ""
			end

			local _, color = require("nvim-web-devicons").get_icon_color_by_filetype(filetype)

			-- Create highlight groups
			local normal_float_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("NormalFloat")), "bg#")

			vim.api.nvim_set_hl(0, "BufferlineNeotreeOffset", { fg = color, bold = true, bg = normal_float_bg })

			local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("@type")), "fg#")
			vim.api.nvim_set_hl(0, "BufferlineDragonflyOffset", { bg = normal_float_bg, fg = fg })

			-- Set up bufferline
			bufferline.setup({
				options = {
					style_preset = bufferline.style_preset.no_italic,
					offsets = {
						{
							filetype = "neo-tree",
							text = icon .. " " .. project_name,
							highlight = "BufferlineNeotreeOffset"
						},
						{
							filetype = "dragonfly",
							text = "󰠭 Dragonfly",
							highlight = "BufferlineDragonflyOffset"
						}
					}
				},
			})
		end
	},

	-- Highlight colors in the editor such as #4a08a9, rgb(0, 255, 255), and hsl(150, 100, 50)
	{
		"brenoprata10/nvim-highlight-colors",
		opts = {},
		event = "BufEnter"
	},

	-- Theme switcher
	{
		"zaldih/themery.nvim",
		config = function()
			require("themery").setup({
				themes = {
					"one-midnight",
					{
						name = "catppuccin-mocha",
						colorscheme = "catppuccin-mocha",
						after = [[
							local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("@function.macro")), "fg#")
							vim.cmd('hi CursorLineNr gui=bold')
							vim.api.nvim_set_hl(0, "@function.builtin", { fg = fg })
							vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#88FF88" })
						]]
					},
					-- "tokyonight",
					"duskfox"
				},
			})
			vim.keymap.set("n", "<leader>t", ":Themery<cr>", {})
		end
	},

	-- Colorschemes (loaded by Themery when necessary)
	{ "catppuccin/nvim",                      lazy = true },
	{ "one-midnight-theme/one-midnight.nvim", lazy = true },
	{ "folke/tokyonight.nvim",                lazy = true },
	{ "EdenEast/nightfox.nvim",               lazy = true },

	-- Highlight comments with  TODO: in them such as this, as well as FIXME and others, also creates a list of them
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
		event = "BufEnter"
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
				top_down = false, -- Send notifications to the bottom of the screen instead of the top
			})

			require("noice").setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				cmdline = {
					view = "cmdline", -- Keep Vim commands to standard bottom CMDLine instead of middle of screen
				},
				presets = {
					bottom_search = true,
					long_message_to_split = true,
					inc_rename = false,
					lsp_doc_border = true,
				},
			})

			vim.keymap.set("n", "<leader>nc", ':NoiceDismiss<cr>', {}) -- Copy to system clipboard
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
							size = { height = 15 }
						}
					},
					left = {
						{
							ft = "neo-tree",
							size = { width = 35 }
						},
						{
							title = "Call Stack",
							ft = "Calltree",
							size = { width = 35 }
						},
					},
					animate = {
						enabled = false,
					},
				},
			},
		},
		config = function()
			require("nvim-web-devicons").setup({
				override = {
					-- Color overrides
					cs = { icon = "󰌛", color = "#8800EE", name = "Cs" },
					txt = { icon = "󰬴", color = "#999999", name = "Text" },

					-- Icons for files missing them
					ll = { icon = "", color = "#999999", name = "LLVM" },
					rkt = { icon = "λ", color = "#FF6666", name = "Racket" },
					asm = { icon = "", color = "#999999", name = "Assembly" },
					unity = { icon = "󰚯", color = "#DDDDDD", name = "Unity" },
					prefab = { icon = "󰚯", color = "#DDDDDD", name = "UnityPrefab" },
					obj = { icon = "󰆧", color = "#88AAFF", name = "WavefrontObject" },
					gltf = { icon = "󰆧", color = "#88AAFF", name = "GLTF" },
					blend = { icon = "󰂫", color = "#EA7600", name = "BlenderObject" },
					o = { icon = "󰘔", color = "#888888", name = "Object" },
					pest = { icon = "󰱯", color = "#2800C6", name = "Pest" },
					toggleterm = { icon = "", color = "#888888", name = "Terminal" },
					cabin = { icon = "", color = "#775544", name = "Cabin" },

					-- Icon overrides
					tex = { icon = "𝒙", color = "#999999", name = "LaTeX" },
				},
			})

			require("neo-tree").setup({
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
						if directory == nil or directory:match("^%s*$") then directory = vim.fn.getcwd() end
						local root = vim.system({ "splik", "--find-root" }, { text = true, cwd = directory })
							:wait()
							.stdout
							:gsub(" ", "\\ ")
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
					-- "toggleterm",
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
							end
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
				highlight = { fg = "#777799", bg = bg }
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
		end
	},

	-- Image rendering
	{
		"3rd/image.nvim",
		opts = {
			backend = "ueberzug",
			processor = "magick_cli"
		},
		build = false,
		ft = "markdown",
	}
}
