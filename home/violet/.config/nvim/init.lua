-- =======================================================================================================================================================================================================
-- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ----------
-- =======================================================================================================================================================================================================

--[[

Violet Iapalucci's init.lua configuration for Neovim.

--]]

-- =======================================================================================================================================================================================================
-- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options -
-- =======================================================================================================================================================================================================

vim.opt.cursorline = true    -- Highlight line that cursor is on
vim.opt.number = true        -- Show line numbers
vim.opt.wrap = false         -- Disable word wrapping
vim.opt.tabstop = 4          -- Set tab size to 4
vim.opt.shiftwidth = 4       -- Use tabstop for automatic tabs
vim.opt.showcmd = false      -- Don't show keypressed
vim.opt.termguicolors = true -- Use true color in the terminal
vim.opt.scrolloff = 8        -- Set scroll offset to 8 lines
vim.opt.expandtab = false
vim.opt.hlsearch = false

vim.g.zig_fmt_autosave = false -- Disable Zig autoformatting which for some reason converts my enums into massive one-liners
vim.g.mapleader = " "          -- Set leader to space - must be done before mappings
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"

-- =======================================================================================================================================================================================================
-- Autocommands ---------- Autocommands ---------- Autocommands ---------- Autocommands ---------- Autocommands ---------- Autocommands ---------- Autocommands ---------- Autocommands ---------- Autocom
-- =======================================================================================================================================================================================================

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.cmd("set shiftwidth=4")
		vim.cmd("set tabstop=4")
		vim.cmd("set noexpandtab")
	end,
})

-- Racket silliness
vim.api.nvim_create_autocmd("FileType", {
	pattern = "racket",
	callback = function()
		vim.lsp.start({
			name = "racket-langserver",
			cmd = { "racket", "-l", "racket-langserver" },
			root_dir = vim.fn.getcwd(),
		})
	end,
})

-- Enable word wrapping for text files such as markdown or text
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
})

local filetypes = {
	["*.ll"] = "llvm",
	["*.rasi"] = "rasi",
	["*.pest"] = "pest",
	["*.lotus"] = "lotus",
	["*.lang2"] = "lang2",
	["LICENSE"] = "markdown",
	["*.h"] = "c",
	["*.bash*"] = "bash",
	["*.kl"] = "klein",
}
for pattern, filetype in pairs(filetypes) do
	vim.api.nvim_create_autocmd("BufRead", {
		pattern = pattern,
		callback = function()
			vim.bo.filetype = filetype
		end,
	})
end

-- =======================================================================================================================================================================================================
-- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins -
-- =======================================================================================================================================================================================================

-- Bootstrapping: Automatically install Lazy.nvim if it isn't already
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Start the plugin setup
require("lazy").setup(
	"plugins",

	-- Options for lazy.nvim
	{
		ui = {
			wrap = false,
			icons = {
				lazy = " ",
				loaded = "",
				start = "",
				cmd = "",
				event = "",
				not_loaded = "",
				plugin = "",
				source = "",
				config = "",
				require = "",
				ft = "",
			},
		},

		rocks = {
			hererocks = true,
		},
	}
)

-- ==================================================================================================================================================================================
-- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------
-- ==================================================================================================================================================================================

-- General
vim.keymap.set("n", "<leader>z", ":Lazy<CR>", {}) -- Open Lazy.nvim package manager

-- Copy & Pasting
vim.keymap.set("v", "<space>y", '"+y', {}) -- Copy to system clipboard
vim.keymap.set("v", "<C-c>", '"+y', {})    -- Copy to system clipboard
vim.keymap.set("n", "<space>p", '"+p', {}) -- Paste to system clipboard
vim.keymap.set("v", "<C-v>", '"+y', {})    -- Copy to system clipboard

-- Visual Movement
vim.keymap.set("n", "j", "gj", {}) -- Move down by display line
vim.keymap.set("n", "k", "gk", {}) -- Move up by display line

-- Window Movement
vim.keymap.set("n", "<C-j>", "<C-w>j", {}) -- Move to window below
vim.keymap.set("n", "<C-k>", "<C-w>k", {}) -- Move to window above
vim.keymap.set("n", "<C-h>", "<C-w>h", {}) -- Move to window left
vim.keymap.set("n", "<C-l>", "<C-w>l", {}) -- Move to window right

vim.cmd("autocmd FileType help wincmd L")
