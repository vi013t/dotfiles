return {
	-- Reopen file to last position
	{
		"ethanholz/nvim-lastplace",
		opts = {},
	},

	-- Jump to positions with s
	{
		"smoka7/hop.nvim",
		config = function()
			require("hop").setup({})
		end,
		keys = {
			{ "s", "<cmd>HopWord<cr>" }
		}
	},
}
