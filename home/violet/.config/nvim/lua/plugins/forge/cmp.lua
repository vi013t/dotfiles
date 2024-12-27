return {
	"hrsh7th/nvim-cmp",
	config = function()
		local has_cmp, cmp = pcall(require, "cmp")
		if has_cmp then
			local primary_sources = {}
			local secondary_sources = {}
			-- lspkind
			local has_lspkind, lspkind = pcall(require, "lspkind")
			local formatting = nil
			if has_lspkind then
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						symbol_map = {
							Class = "",
							Color = "",
							Constant = "𝛫",
							Constructor = "",
							Enum = "",
							EnumMember = "",
							Event = "",
							Field = "",
							File = "",
							Folder = "",
							Function = "λ",
							Interface = "",
							Keyword = "",
							Method = "∷",
							Module = "",
							Operator = "",
							Property = "∷",
							Reference = "&",
							Snippet = "➡️",
							Struct = "",
							Text = "",
							TypeParameter = "",
							Unit = "",
							Value = "",
							Variable = "󰫧"
						}
					}),
				}
			end
			-- LuaSnip
			local snippet = nil
			local has_luasnip, luasnip = pcall(require, "luasnip")
			if has_luasnip then
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end
				}
				table.insert(primary_sources, { name = "luasnip " })
			end
			-- CMP LSP
			local has_cmp_lsp = pcall(require, "cmp_nvim_lsp")
			if has_cmp_lsp then
				table.insert(primary_sources, { name = "nvim_lsp" })
			end
			-- CMP Buffer
			local has_cmp_buffer = pcall(require, "cmp-buffer")
			if has_cmp_buffer then
				table.insert(secondary_sources, { name = "buffer" })
			end
			-- CMP
			cmp.setup({
				snippet = snippet,
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources(primary_sources, secondary_sources),
				formatting = formatting,
			})
			-- CMDline
			local has_cmp_cmd = pcall(require, "cmp_cmdline")
			if has_cmp_cmd then
				cmp.setup.cmdline({ "/", "?" }, {
					mapping = cmp.mapping.preset.cmdline(),
					sources = secondary_sources,
				})
				cmp.setup.cmdline(":", {
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
				})
			end
		end
	end,
	event = "InsertEnter"

}
