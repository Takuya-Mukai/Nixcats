require("lze").load({
	{
		"blink-cmp-copilot",
		dep_of = { "blink.cmp" },
		lazy = true,
	},
	{
		"copilot.lua",
		dep_of = { "blink-cmp-copilot" },
		lazy = true,
		after = function()
			require("copilot").setup({ panel = { enabled = false }, suggestion = { enabled = false } })
		end,
	},
	{
		"blink-cmp-spell",
		dep_of = { "blink.cmp" },
		lazy = true,
	},
	{
		"blink-cmp-git",
		dep_of = { "blink.cmp" },
		lazy = true,
	},
	{
		"blink-ripgrep.nvim",
		dep_of = { "blink.cmp" },
		lazy = true,
	},
	{
		"blink-cmp-dictionary",
		dep_of = { "blink.cmp" },
	},
	{
		"friendly-snippets",
		dep_of = { "blink.cmp" },
		lazy = true,
	},
	{
		"luasnip",
		dep_of = { "blink.cmp" },
		-- dep_of = "friendly-snippets",
		after = function()
			require("luasnip").config.setup({
				history = true,
				updateevents = "TextChanged,TextChangedI",
			})
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
		lazy = true,
	},
	{
		"lspkind.nvim",
		dep_of = { "blink.cmp" },
	},
	{
		"blink.cmp",
		-- dep_of = {
		-- 	"blink-cmp-ripgrep",
		-- 	"blink-cmp-spell",
		-- 	"blink-cmp-git",
		-- 	"blink-cmp-copilot",
		-- 	"lspkind.nvim",
		-- 	"luasnip",
		-- 	"blink-ripgrep.nvim",
		-- },
		event = { "InsertEnter", "CmdlineEnter" },
		after = function()
			local spell_enabled_cache = {}

			vim.api.nvim_create_autocmd("OptionSet", {
				group = vim.api.nvim_create_augroup("blink_cmp_spell", {}),
				desc = "Reset the cache for enabling the spell source for blink.cmp.",
				pattern = "spelllang",
				callback = function()
					spell_enabled_cache[vim.fn.bufnr()] = nil
				end,
			})
			require("blink-cmp").setup({
				enabled = function()
					return not vim.tbl_contains({ "dap-repl" }, vim.bo.filetype)
				end,
				cmdline = {
					enabled = true,
					-- use 'inherit' to inherit mappings from top level `keymap` config
					keymap = { preset = "inherit" },
					sources = { "buffer", "cmdline" },

					-- OR explicitly configure per cmd type
					-- This ends up being equivalent to above since the sources disable themselves automatically
					-- when not available. You may override their `enabled` functions via
					-- `sources.providers.cmdline.override.enabled = function() return your_logic end`

					-- sources = function()
					--   local type = vim.fn.getcmdtype()
					--   -- Search forward and backward
					--   if type == '/' or type == '?' then return { 'buffer' } end
					--   -- Commands
					--   if type == ':' or type == '@' then return { 'cmdline', 'buffer' } end
					--   return {}
					-- end,

					completion = {
						trigger = {
							show_on_blocked_trigger_characters = {},
							show_on_x_blocked_trigger_characters = {},
						},
						list = {
							selection = {
								-- When `true`, will automatically select the first item in the completion list
								preselect = true,
								-- When `true`, inserts the completion item automatically when selecting it
								auto_insert = true,
							},
						},
						-- Whether to automatically show the window when new completion items are available
						-- Default is false for cmdline, true for cmdwin (command-line window)
						menu = {
							auto_show = true,
						},
						-- Displays a preview of the selected item on the current line
						ghost_text = { enabled = true },
					},
				},
				term = {
					enabled = true,
					keymap = { preset = "inherit" }, -- Inherits from top level `keymap` config when not set
					sources = {},
					completion = {
						trigger = {
							show_on_blocked_trigger_characters = {},
							show_on_x_blocked_trigger_characters = nil, -- Inherits from top level `completion.trigger.show_on_blocked_trigger_characters` config when not set
						},
						-- Inherits from top level config options when not set
						list = {
							selection = {
								-- When `true`, will automatically select the first item in the completion list
								preselect = nil,
								-- When `true`, inserts the completion item automatically when selecting it
								auto_insert = nil,
							},
						},
						-- Whether to automatically show the window when new completion items are available
						menu = { auto_show = nil },
						-- Displays a preview of the selected item on the current line
						ghost_text = { enabled = nil },
					},
				},
				appearance = {
					-- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
					kind_icons = {
						Class = "󱡠",
						Color = "󰏘",
						Constant = "󰏿",
						Constructor = "󰒓",
						Copilot = "",
						Enum = "󰦨",
						EnumMember = "󰦨",
						Event = "󱐋",
						Field = "󰜢",
						File = "󰈔",
						Folder = "󰉋",
						Function = "󰊕",
						Interface = "󱡠",
						Keyword = "󰻾",
						Method = "󰊕",
						Module = "󰅩",
						Operator = "󰪚",
						Property = "󰖷",
						Reference = "󰬲",
						Snippet = "󱄽",
						Struct = "󱡠",
						Text = "󰉿",
						TypeParameter = "󰬛",
						Unit = "󰪚",
						Value = "󰦨",
					},
				},

				fuzzy = {
					sorts = {
						function(a, b)
							local sort = require("blink.cmp.fuzzy.sort")
							if a.source_id == "spell" and b.source_id == "spell" then
								return sort.label(a, b)
							end
						end,
						-- This is the normal default order, which we fall back to
						"score",
						"kind",
						"label",
					},
					implementation = "prefer_rust_with_warning",
				},

				sources = {
					-- Remove 'buffer' if you don't want text completions, by default it's only enabled when LSP returns no items
					default = {
						"lsp",
						"path",
						"snippets",
						"buffer",
						"ripgrep",
						"git",
						"copilot",
						"spell",
					},
					providers = {
						ripgrep = {
							name = "Ripgrep",
							module = "blink-ripgrep",
							-- see the full configuration below for all available options
							---@module "blink-ripgrep"
							---@type blink-ripgrep.Options
							opts = {},
						},
						copilot = {
							name = "Copilot",
							module = "blink-cmp-copilot",
							score_offset = 100,
							async = true,
						},
						git = {
							name = "Git",
							module = "blink-cmp-git",
							opts = {
								-- options for the blink-cmp-git
							},
						},
						spell = {
							name = "Spell",
							module = "blink-cmp-spell",
							enabled = true,
						},
					},
				},
				snippets = { preset = "luasnip" },
				signature = { window = { border = "rounded" } },
				completion = {
					documentation = { window = { border = "rounded" } },
					menu = {
						border = "rounded",
						draw = {
							components = {
								kind_icon = {
									text = function(ctx)
										local icon = ctx.kind_icon
										if vim.tbl_contains({ "Path" }, ctx.source_name) then
											local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
											if dev_icon then
												icon = dev_icon
											end
										else
											icon = require("lspkind").symbolic(ctx.kind, {
												mode = "symbol",
											})
										end

										return icon .. ctx.icon_gap
									end,

									-- Optionally, use the highlight groups from nvim-web-devicons
									-- You can also add the same function for `kind.highlight` if you want to
									-- keep the highlight groups in sync with the icons.
									highlight = function(ctx)
										local hl = ctx.kind_hl
										if vim.tbl_contains({ "Path" }, ctx.source_name) then
											local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
											if dev_icon then
												hl = dev_hl
											end
										end
										return hl
									end,
								},
							},
						},
					},
				},
			})
		end,
	},
})
