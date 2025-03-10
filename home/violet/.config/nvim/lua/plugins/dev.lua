if not table.unpack then
	table.unpack = unpack
end

---@class DevPlugin : LazyPluginSpec
---@field path string
---@field fallback string
---@field name string
---@field dir nil

--- Creates a local development plugin, with a git fallback.
---
---@param spec DevPlugin The plugin spec
---
---@return LazyPluginSpec spec A new plugin spec representing the dev plugin
local function dev_plugin(spec)
	local home = os.getenv("HOME")
	---@cast home string

	local path = spec.path:gsub("^~", home)
	local fallback = spec.fallback
	local name = spec.name
	local enabled = spec.enabled or function()
		return true
	end

	spec.path = nil
	spec.fallback = nil

	return {
		vim.tbl_deep_extend("keep", {
			dir = path,
			name = name .. " (Local)",
			enabled = function()
				return vim.uv.fs_stat(path) and enabled()
			end,
		}, spec),
		vim.tbl_deep_extend("keep", {
			fallback,
			name = name .. " (Git)",
			enabled = function()
				return not vim.uv.fs_stat(path) and enabled()
			end,
			table.unpack(spec),
		}, spec),
	}
end

return vim.tbl_map(dev_plugin, {

	-- Cabin
	{
		path = "~/Documents/Coding/Developer Tools/Cabin/cabin.nvim",
		fallback = "cabin-language/cabin.nvim",
		name = "cabin.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},

	-- Tabline
	{
		path = "~/Documents/Coding/Developer Tools/Neovim Plugins/tabs.nvim/",
		fallback = "vi013t/tabs.nvim",
		name = "tabs.nvim",

		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
			offsets = {
				{
					filetype = "neo-tree",
					title = function()
						local devicons = require("nvim-web-devicons")

						-- Get project name
						local root = assert(vim.system({ "findroot" }, { text = true }):wait().stdout)
						local project_name = root:match("([^/\\%s]+)%s*$")

						-- Get most used language
						local tokei_data = vim.json.decode(vim.system({ "tokei", "--output", "json" }, { text = true }):wait().stdout)
						local max_language = nil
						local max_lines = -math.huge
						for name, language in pairs(tokei_data) do
							if name ~= "Total" and language.code > max_lines then
								max_lines = language.code
								max_language = name
							end
						end

						-- Get icon & highlight
						local icon = ""
						if max_language ~= nil then
							local tabs = require("tabs")
							local icon_name = devicons.get_icon_name_by_filetype(max_language:lower())
							local highlight_group = "DevIcon" .. icon_name:sub(1, 1):upper() .. icon_name:sub(2)
							icon = tabs.highlight(require("nvim-web-devicons").get_icon_by_filetype(max_language:lower(), {}) .. " ", highlight_group)
						end

						-- Return the icon and project name
						return icon .. project_name
					end,
				},
			},
		},

		init = function()
			vim.keymap.set("n", "<C-S-L>", require("tabs").next)
			vim.keymap.set("n", "<C-S-H>", require("tabs").previous)
			vim.keymap.set("n", "<C-S-CR>", require("tabs").open)
		end,
	},

	-- Input library
	{
		path = "/home/violet/Documents/Coding/Developer Tools/Neovim Plugins/input.nvim",
		fallback = "vi013t/input.nvim",
		name = "input.nvim",
		keys = {
			{
				"<leader>i",
				function()
					require("input.tests").test()
				end,
			},
		},
	},

	-- Search & Replace
	{
		path = "/home/violet/Documents/Coding/Developer Tools/Neovim Plugins/dragonfly.nvim",
		fallback = "vi013t/dragonfly.nvim",
		name = "dragonfly.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			on_open = function()
				if vim.fn.exists(":NeoTreeClose") == 2 then
					vim.cmd("NeoTreeClose")
				end
			end,
			on_close = function()
				if not vim.g.project_cwd then
					local directory = vim.fn.expand("%:h")
					if directory == nil or directory:match("^%s*$") then
						directory = vim.fn.getcwd()
					end
					local root = vim.system({ "findroot" }, { text = true, cwd = directory }):wait().stdout:gsub(" ", "\\ ")
					vim.g.project_cwd = root
				end
				local has_neotree = pcall(function()
					require("neo-tree")
				end)
				if has_neotree then
					vim.cmd("Neotree dir=" .. vim.g.project_cwd)
				end
			end,
		},
		keys = {
			{ "/", "<cmd>DragonflyBuffer<cr>" },
			{ "?", "<cmd>DragonflyBufferReplace<cr>" },
			{ "<C-/>", "<cmd>DragonflyProject<cr>" },
			{ "<C-?>", "<cmd>DragonflyProjectReplace<cr>" },
		},
	},

	-- LSP
	{
		path = "/home/violet/Documents/Coding/Developer Tools/Neovim Plugins/forge.nvim",
		fallback = "vi013t/forge.nvim",
		name = "forge.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			"stevearc/conform.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			ui = {
				window_config = {
					border = "rounded",
				},
			},
			autoformat = {
				ignore = { "racket", "haskell" },
			},
		},
		init = function()
			vim.keymap.set("n", "<leader>fr", ":Forge<CR>", {})
			vim.keymap.set("n", "<leader>lh", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, {})
			vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, {})
			vim.keymap.set("n", "<leader>ln", function()
				vim.diagnostic.jump({ count = 1, float = { border = "rounded" } })
			end, {})
			vim.keymap.set("n", "<leader>lp", function()
				vim.diagnostic.jump({ count = -1, float = { border = "rounded" } })
			end, {})

			vim.lsp.config.racketlsp = {
				cmd = { "racket", "-l", "racket-langserver" },
				filetypes = { "racket" },
				root_markers = {},
			}
		end,
	},
})
