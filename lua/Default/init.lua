require('Default.opts_and_keys')
-- NOTE: various, non-plugin config

-- NOTE: register an extra lze handler with the spec_field 'for_cat'
-- that makes enabling an lze spec for a category slightly nicer
require("lze").register_handlers(require('nixCatsUtils.lzUtils').for_cat)

-- NOTE: Register another one from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger lspconfig setup hooks only on the correct filetypes
require('lze').register_handlers(require('lzextras').lsp)

require("Default.ui")
require("Default.edit")
require("Default.tool")
require("Default.debug")
require("Default.lsp")
require("Default.code-quality")
require("Default.lang")
require("Default.cmp")

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
