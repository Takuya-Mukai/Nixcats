require("Default.opts_and_keys")
-- NOTE: various, non-plugin config

-- NOTE: register an extra lze handler with the spec_field 'for_cat'
-- that makes enabling an lze spec for a category slightly nicer
require("lze").register_handlers(require("nixCatsUtils.lzUtils").for_cat)

-- NOTE: Register another one from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger lspconfig setup hooks only on the correct filetypes
require("lze").register_handlers(require("lzextras").lsp)
if vim.g.vscode then
	require("lze").load({
		{
			"comment.nvim",
			keys = "g",
			after = function(_)
				require("Comment").setup()
			end,
		},
		{
			"nvim-surround",
			event = "DeferredUIEnter",
			after = function(_)
				require("nvim-surround").setup({})
			end,
		},
		{
			"flash.nvim",
			event = "DeferredUIEnter",
			after = function()
				require("flash").setup({})
			end,
			keys = {
				{
					"s",
					mode = { "n", "x", "o" },
					function()
						require("flash").jump()
					end,
					desc = "Flash",
				},
				{
					"S",
					mode = { "n", "x", "o" },
					function()
						require("flash").treesitter()
					end,
					desc = "Flash Treesitter",
				},
				{
					"r",
					mode = "o",
					function()
						require("flash").remote()
					end,
					desc = "Remote Flash",
				},
				{
					"R",
					mode = { "o", "x" },
					function()
						require("flash").treesitter_search()
					end,
					desc = "Treesitter Search",
				},
				{
					"<c-s>",
					mode = { "c" },
					function()
						require("flash").toggle()
					end,
					desc = "Toggle Flash Search",
				},
			},
		},
	})
else
	require("Default.ui")
	require("Default.edit")
	require("Default.tool")
	require("Default.debug")
	require("Default.lsp")
	require("Default.code-quality")
	require("Default.lang")
	require("Default.cmp")
	require("Default.jupyter")
end
-- NOTE: we even ask nixCats if we included our debug stuff in this setup! (we didnt)
-- But we have a good base setup here as an example anyway!
-- if nixCats('debug') then
--   require('Default.debug')
-- end
-- NOTE: we included these though! Or, at least, the category is enabled.
-- these contain nvim-lint and conform setups.
-- if nixCats('lint') then
--   require('Default.lint')
-- end
-- if nixCats('format') then
--   require('Default.format')
-- end
-- NOTE: I didnt actually include any linters or formatters in this configuration,
-- but it is enough to serve as an example.
