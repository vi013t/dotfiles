return {
	-- Reopen file to last position
	{
		"ethanholz/nvim-lastplace",
		opts = {},
	},

	{
		dir = "/home/violet/Documents/Coding/Developer Tools/Neovim Plugins/input.nvim",
		init = function()
			vim.api.nvim_create_user_command("InputTest", function() require("input.tests").test() end, {})
		end
	},
}
