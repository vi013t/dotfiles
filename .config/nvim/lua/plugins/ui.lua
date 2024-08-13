return {

	-- Highlight colors in the editor such as #4a08a9, rgb(0, 255, 255), and hsl(150, 100, 50)
	{
		"brenoprata10/nvim-highlight-colors",
		opts = {},
	},

	-- Theme switcher
	{
		"zaldih/themery.nvim",
		dependencies = {
			"catppuccin/nvim",
			"one-midnight-theme/one-midnight.nvim",
			"folke/tokyonight.nvim"
		},
		config = function()
			require("themery").setup({
				themes = {
					"one-midnight",
					"catppuccin-mocha",
					"tokyonight"
				}
			})
			vim.keymap.set("n", "<leader>t", ":Themery<cr>", {})
		end
	},

	-- Highlight comments with  TODO: in them such as this, as well as FIXME and others, also creates a list of them
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
	},

	-- Better UI for find and replace
	{
		"VonHeikemen/searchbox.nvim",
		dependencies = {
			{ "MunifTanjim/nui.nvim" },
		},
		keys = {
			{ "/", "<cmd>SearchBoxIncSearch<cr>", desc = "Search" },
		},
		opts = {
			popup = {
				position = {
					row = "0%",
					col = "100%",
				},
				win_options = {
					winhighlight = "Normal:Normal,FloatBorder:Normal",
				},
			},
		},
	},

	-- Indentation lines
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			-- local highlight = { "RainbowRed" }
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function() -- HACK: set RainbowRed to the indent line color
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#1E1E2E" })
			end)
			require("ibl").setup({
				indent = {
					-- highlight = highlight,
					char = "│",
				},
			})
		end,
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
				top_down = false,    -- Send notifications to the bottom of the screen instead of the top
				background_colour = "#00000000", -- Background color
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
			{
				"3rd/image.nvim",
				opts = {
					backend = "ueberzug",
				},
			},
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
		config = function()
			require("nvim-web-devicons").setup({
				override = {
					-- Color overrides
					cs = { icon = "", color = "#8800EE", name = "Cs" },
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
		end,
		keys = {
			{
				"<leader>ef",
				function()
					-- Files that indicate the root directory
					local root_files = {
						".git",
						"Cargo.toml",
						"Makefile",
						"package.json",
						".luarc.json",
						"pyproject.toml",
						"build.zig",
						"LICENSE",
						"index.html",
						"src",
					}

					-- Check if the directory is the root directory
					local function is_root_dir(dir_name)
						for _, name in ipairs(root_files) do
							if vim.fn.filereadable(dir_name .. "/" .. name) == 1 or vim.fn.isdirectory(dir_name .. "/" .. name) == 1 then
								return true
							end
						end
						return false
					end

					-- Locate the project root directory
					local current_directory = vim.fn.expand("%:p:h")
					local root_directory = current_directory
					while not is_root_dir(root_directory) do
						root_directory = vim.fn.fnamemodify(root_directory, ":h")
						if root_directory == "/" then
							root_directory = current_directory
							break
						end
					end

					-- Open Neotree in the project root directory
					vim.cmd("Neotree dir=" .. root_directory:gsub(" ", "\\ "))
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
								if path == "/home/neph/.config/nvim/init.lua" then
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
								hint = " ",
								info = " ",
							},
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

}
