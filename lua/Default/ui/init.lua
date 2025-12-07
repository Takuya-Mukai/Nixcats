local colorschemeName = nixCats("colorscheme")
if not require("nixCatsUtils").isNixCats then
	colorschemeName = "catppuccin"
end

require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	integrations = {
		aerial = true,
		blink_cmp = {
			style = "rounded",
		},
		diffview = true,
		fidget = true,
		gitsigns = true,
		noice = true,
		notify = true,
		treesitter_context = true,
		vimwiki = true,
		lsp_trouble = true,
		which_key = true,
		nvim_surround = true,
		navic = {
			enabled = false,
			custom_bg = "NONE",
		},
		snacks = {
			enabled = true,
			indent_scope_color = "lavender",
		},
	},
})

vim.cmd.colorscheme(colorschemeName)

require("lze").load({
	{
		"transparent.nvim",
		event = "DeferredUIEnter",
		after = function()
			require("transparent").setup({
				-- table: default groups
				groups = {
					"Normal",
					"NormalNC",
					"Comment",
					"Constant",
					"Special",
					"Identifier",
					"Statement",
					"PreProc",
					"Type",
					"Underlined",
					"Todo",
					"String",
					"Function",
					"Conditional",
					"Repeat",
					"Operator",
					"Structure",
					"LineNr",
					"NonText",
					"SignColumn",
					"CursorLine",
					"CursorLineNr",
					"StatusLine",
					"StatusLineNC",
					"EndOfBuffer",
				},
				-- table: additional groups that should be cleared
				extra_groups = {
					"NormalFloat",
				},
				-- table: groups you don't want to clear
				exclude_groups = {},
				-- function: code to be executed after highlight groups are cleared
				-- Also the user event "TransparentClear" will be triggered
				on_clear = function() end,
			})
		end,
	},
	{
		"nui.nvim",
		dep_of = {
			"noice.nvim",
			"fidget.nvim",
			"nvim-navbuddy",
		},
	},
	{
		"hlargs.nvim",
		after = function()
			require("hlargs").setup({})
		end,
	},
	{
		"noice.nvim",
		after = function()
			require("noice").setup({
				lsp = {
					override = {
						["cmp.entry.get_documentation"] = true,
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
					},
				},
				presets = {
					bottom_search = false,
					command_palette = true,
					inc_rename = true,
					long_message_to_split = true,
					lsp_doc_border = true,
				},
			})
		end,
		event = { "DeferredUIEnter" },
	},
	{
		"fidget.nvim",
		after = function()
			require("fidget").setup({})
		end,
		event = { "LspAttach" },
	},
	{
		"nvim-highlight-colors",
		event = "DeferredUIEnter",
		after = function(_)
			require("nvim-highlight-colors").setup({})
		end,
	},
	-- {
	--   "smear-cursor.nvim",
	--   event = "DeferredUIEnter",
	--   after = {
	--     require('smear_cursor').setup({
	--       stiffness = 0.5,
	--       trailing_stiffness = 0.49,
	--       never_draw_over_target = false,
	--     })
	--   },
	-- },
	{
		"nvim-treesitter-integrated",
		dep_of = {
			"nvim-treesitter-textobjects",
			"nvim-treesitter-context",
			"rainbow-delimiters.nvim",
		},
		after = function(_)
			require("nvim-treesitter").setup({
				install_dir = require("nixCats").settings.treesitterParserPath,
			})
			local function enable_treesitter_features()
				-- 1. 現在のバッファIDを取得
				local bufnr = vim.api.nvim_get_current_buf()

				-- 2. ハイライトを有効化: 廃止された highlight = { enable = true } の代替
				--     pcall(vim.treesitter.start) ではなく、バッファIDを渡してハイライトを起動
				pcall(vim.treesitter.start, bufnr)

				-- 3. 折りたたみ機能を有効化 (pcallで安全に実行)
				pcall(function()
					-- Treesitterが対応していないファイルタイプでエラーが出ないように pcall でラップ
					vim.wo[bufnr].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo[bufnr].foldmethod = "expr"
					vim.wo[bufnr].foldlevel = 99
				end)

				-- 4. インデント機能を有効化 (pcallで安全に実行)
				pcall(function()
					-- 廃止された indent = { enable = true } の代替
					vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end)
			end

			-- 5. ★ autocmd の設定（augroup を使って重複を避ける）
			local group = vim.api.nvim_create_augroup("MyTreesitterSetup", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = { "*" },
				callback = enable_treesitter_features,
			})
		end,
	},
	{
		"nvim-treesitter-context",
		event = { "CursorMoved", "CursorMovedI" },
		after = function(_)
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				multiwindow = true, -- Enable multiwindow support.
				max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = true,
				multiline_threshold = 20, -- Maximum number of lines to show for a single context
				trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- Separator between context and content. Should be a single character string, like '-'.
				-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
				separator = nil,
				zindex = 20, -- The Z-index of the context window
				on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
			})
		end,
	},
	{
		"nvim-treesitter-textobjects",
		event = "BufReadPost",
		lazy = true,
		after = function(_)
			-- configuration
			require("nvim-treesitter-textobjects").setup({
				select = {
					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,
					-- You can choose the select mode (default is charwise 'v')
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * method: eg 'v' or 'o'
					-- and should return the mode ('v', 'V', or '<c-v>') or a table
					-- mapping query_strings to modes.
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "V", -- blockwise
					},
					-- If you set this to `true` (default is `false`) then any textobject is
					-- extended to include preceding or succeeding whitespace. Succeeding
					-- whitespace has priority in order to act similarly to eg the built-in
					-- `ap`.
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * selection_mode: eg 'v'
					-- and should return true of false
					include_surrounding_whitespace = true,
				},
			})

			vim.keymap.set({ "x", "o" }, "af", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "if", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
			end)
			-- You can also use captures from other query groups like `locals.scm`
			vim.keymap.set({ "x", "o" }, "as", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
			end)
		end,
	},
	{
		"rainbow-delimiters.nvim",
		after = function(_)
			require("rainbow-delimiters.setup").setup()
		end,
		event = "BufReadPost",
	},
	{
		"gitsigns.nvim",
		dep_of = { "lualine.nvim" },
		event = {
			"BufReadPre",
			"BufNewFile",
			"InsertEnter",
			"TextChanged",
			"TextChangedI",
		},
		after = function(_)
			require("gitsigns").setup({
				signs = {
					add = { text = " ┃" },
					change = { text = " ┃" },
					delete = { text = " ━" },
					topdelete = { text = " ┳" },
					changedelete = { text = " ┳" },
					untracked = { text = " ⡇" },
				},
				signs_staged = {
					add = { text = "┃ " },
					change = { text = "┃ " },
					delete = { text = "━ " },
					topdelete = { text = "┳ " },
					changedelete = { text = "┳ " },
					untracked = { text = "⡇ " },
				},
				attach_to_untracked = false,
				signcolumn = true,
				word_diff = true,
				linehl = false,
				current_line_blame = true,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol",
					delay = 100,
					ignore_whitespace = false,
				},
				current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> - <summary>",

				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end, "Next hunk")

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end, "Previous hunk")

					-- Actions
					map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
					map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")

					map("v", "<leader>hs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, "Stage selected hunk")

					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, "Reset selected hunk")

					map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
					map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
					map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
					map("n", "<leader>hi", gitsigns.preview_hunk_inline, "Inline preview hunk")

					map("n", "<leader>hb", function()
						gitsigns.blame_line({ full = true })
					end, "Blame line (full)")

					map("n", "<leader>hd", gitsigns.diffthis, "Diff this")
					map("n", "<leader>hD", function()
						gitsigns.diffthis("~")
					end, "Diff against last commit")

					map("n", "<leader>hQ", function()
						gitsigns.setqflist("all")
					end, "Set quickfix list (all hunks)")

					map("n", "<leader>hq", gitsigns.setqflist, "Set quickfix list (unresolved hunks)")

					-- Toggles
					map("n", "<leader>htb", gitsigns.toggle_current_line_blame, "Toggle line blame")
					map("n", "<leader>htw", gitsigns.toggle_word_diff, "Toggle word diff")

					-- Text object
					map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
				end,
			})
		end,
	},
	{
		"lualine.nvim",
		event = "DeferredUIEnter",
		after = function(_)
			local function diff_source()
				local gitsigns = vim.b.gitsigns_status_dict
				if gitsigns then
					return {
						added = gitsigns.added,
						modified = gitsigns.changed,
						removed = gitsigns.removed,
					}
				end
				return nil
			end
			_G.diff_source = diff_source

			require("lualine").setup({
				option = {
					theme = "catppuccin",
					globalstatus = true,
				},
				sections = {
					lualine_a = {
						{
							"filename",
							newfile_status = true,
							path = 1,
							shorting_target = 24,
							symbols = {
								modified = " ",
								readonly = " ",
								newfile = " ",
							},
						},
					},
					lualine_b = {
						{
							function()
								local clients = vim.lsp.get_clients()
								local seen = {}
								local names = {}

								for _, client in ipairs(clients) do
									if
										client.name ~= "copilot"
										and client.name ~= "null-ls"
										and not seen[client.name]
									then
										table.insert(names, client.name)
										seen[client.name] = true
									end
								end

								if vim.tbl_isempty(names) then
									return "No LSP"
								end

								return " " .. table.concat(names, ", ")
							end,
							color = function()
								local clients = vim.lsp.get_clients()
								for _, client in ipairs(clients) do
									if client.name ~= "copilot" and client.name ~= "null-ls" then
										return { fg = "#a6e3a1" } -- LSPがあるとき：緑
									end
								end
								return { fg = "#7f849c" } -- LSPなし（またはcopilot/null-lsだけ）：グレー
							end,
						},
					},
					lualine_c = {
						{
							"diagnostics",
							sources = { "nvim_diagnostic", "nvim_lsp" },
							sections = { "error", "warn", "info", "hint" },
							symbols = {
								error = " ", -- error (U+EA87)
								warn = " ", -- warning (U+EA6C)
								info = " ", -- info (U+EA74)
								hint = " ", -- hint/lightbulb (U+EA61)
							},
						},
						{
							function()
								local ok, navic = pcall(require, "nvim-navic")
								if ok and navic.is_available() then
									return navic.get_location()
								end
								return ""
							end,
							color_correction = "dynamic",
						},
					},
					lualine_x = {
						"encoding",
					},
					lualine_y = {
						"filetype",
						"fileformat",
					},
					lualine_z = {
						"progress",
						"location",
					},
				},
				tabline = {
					lualine_a = {
						{
							"buffers",
							symbols = { modified = " ", readonly = " ", unnamed = " " },
						},
					},
					lualine_b = {},
					lualine_c = {},
					lualine_x = {
						{
							function()
								local ok, noice = pcall(require, "noice")
								return (ok and noice.api.status.command.get()) or ""
							end,
							cond = function()
								local ok, noice = pcall(require, "noice")
								return ok and noice.api.status.command.has()
							end,
							color = { fg = "#eba0ac" },
						},
					},
					lualine_y = {
						{
							"diff",
							symbols = {
								added = " ",
								modified = " ",
								removed = " ",
							},
							source = diff_source,
						},
						{
							"b:gitsigns_head",
							icon = " ",
							color = { fg = "#fab387" },
						},
					},
					lualine_z = { "tabs" },
				},
			})
		end,
	},
	{
		"nvim-web-devicons",
		after = function(_)
			require("nvim-web-devicons").setup({ variant = "dark" })
		end,
	},
	{
		"nvim-scrollview",
		event = { "BufWinEnter", "WinScrolled", "DeferredUIEnter" },
		after = function(_)
			require("scrollview").setup({})
		end,
	},
	{
		"hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		after = function(_)
			require("hlchunk").setup({
				chunk = {
					enable = true,
					chars = {
						horizontal_line = "─",
						vertical_line = "│",
						left_top = "╭",
						left_bottom = "╰",
						right_arrow = ">",
					},
					style = "#78dce8",
				},
				indent = { enable = true },
				line_num = {
					enable = true,
					use_treesitter = false,
				},
			})
		end,
	},
})
