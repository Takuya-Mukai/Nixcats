require("lze").load({
	{
		"aerial.nvim",
		for_cat = aerial,
		after = function(_)
			require("aerial").setup({
				-- optionally use on_attach to set keymaps when aerial has attached to a buffer
				on_attach = function(bufnr)
					-- Jump forwards/backwards with '{' and '}'
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
				end,
				backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
				layout = {
					min_width = 20,
					max_width = { 40, 0.2 },
				},
				filter_kind = false,
				autojump = true,
			})
			-- You probably also want to set a keymap to toggle aerial
			vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
		end,
		keys = { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Toggle Aerial" },
	},
	{
		"nvim-navic",
		event = "LspAttach",
		after = function()
			require("nvim-navic").setup({
				icons = {
					File = "󰈙 ",
					Module = " ",
					Namespace = "󰌗 ",
					Package = " ",
					Class = "󰌗 ",
					Method = "󰆧 ",
					Property = " ",
					Field = " ",
					Constructor = " ",
					Enum = "󰕘",
					Interface = "󰕘",
					Function = "󰊕 ",
					Variable = "󰆧 ",
					Constant = "󰏿 ",
					String = "󰀬 ",
					Number = "󰎠 ",
					Boolean = "◩ ",
					Array = "󰅪 ",
					Object = "󰅩 ",
					Key = "󰌋 ",
					Null = "󰟢 ",
					EnumMember = " ",
					Struct = "󰌗 ",
					Event = " ",
					Operator = "󰆕 ",
					TypeParameter = "󰊄 ",
				},
				lsp = {
					auto_attach = true,
					preference = nil,
				},
				highlight = true,
				separator = " > ",
				depth_limit = 0,
				depth_limit_indicator = "..",
				safe_output = true,
				lazy_update_context = false,
				click = true,
			})
		end,
	},
	{
		"nvim-lspconfig",
		event = "LspAttach",
		after = function(_)
			local LspList = {
				"pyright",
				"ruff",
				"marksman",
				"ts_ls",
				"rust_analyzer",
				"lua_ls",
				"nil_ls",
				"ltex_ls",
				"bashls",
				"clangd",
				"sqls",
				"tinymist",
				"yamlls",
			}
			vim.lsp.config("*", {})
			vim.lsp.config(
				"lua_ls",
				{ cmd = { "lua-lsp" }, settings = { Lua = { diagnostics = { globals = { "vim" } } } } }
			)
			vim.lsp.config("pyright", {
				settings = {
					python = { analysis = { diagnosticServerityOverrides = { reportUnusedExpression = "none" } } },
				},
			})
			vim.lsp.enable(LspList)
		end,
		dep_of = {
			"nvim-navic",
			"nvim-navbuddy",
			"trouble.nvim",
			"aerial.nvim",
			"quarto-nvim",
		},
	},
	{
		"trouble.nvim",
		after = function()
			require("trouble").setup({})
		end,
		keys = {
			{
				"<leader>xs",
				"<cmd>Trouble symbols toggle focus=false<CR>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<CR>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<CR>",
				desc = "Quickfix List (Trouble)",
			},
			{
				"<leader>xx",
				function()
					require("trouble").toggle({
						mode = "diagnostics",
						filter = { buf = 0 },
						sort = { { "severity", "desc" } },
						preview = { type = "split", relative = "win", position = "right", size = 0.4 },
					})
				end,
				desc = "Trouble: Current Buffer Diagnostics",
			},
			{
				"<leader>xX",
				function()
					require("trouble").toggle({
						mode = "diagnostics",
						sort = { { "severity", "desc" } },
						preview = { type = "split", relative = "win", position = "right", size = 0.4 },
					})
				end,
				desc = "Trouble: All Buffers Diagnostics",
			},
		},
	},
})

do
	local __nixvim_autogroups = { nixvim_lsp_binds = { clear = false }, nixvim_lsp_on_attach = { clear = false } }

	for group_name, options in pairs(__nixvim_autogroups) do
		vim.api.nvim_create_augroup(group_name, options)
	end
end
-- }}
-- Set up autocommands {{
do
	local __nixvim_autocommands = {
		-- {
		--     callback = function(event)
		--         do
		--             -- client and bufnr are supplied to the builtin `on_attach` callback,
		--             -- so make them available in scope for our global `onAttach` impl
		--             local client = vim.lsp.get_client_by_id(event.data.client_id)
		--             local bufnr = event.buf
		--             require("lsp-format").on_attach(client, bufnr)
		--         end
		--     end,
		--     desc = "Run LSP onAttach",
		--     event = "LspAttach",
		--     group = "nixvim_lsp_on_attach",
		-- },
		{
			callback = function(args)
				do
					local map = {
						action = vim.lsp.buf["definition"],
						key = "gd",
						lspBufAction = "definition",
						mode = "",
						options = { desc = "Go to definition" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map = {
						action = vim.lsp.buf["references"],
						key = "gD",
						lspBufAction = "references",
						mode = "",
						options = { desc = "Find references" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map = {
						action = vim.lsp.buf["type_definition"],
						key = "gt",
						lspBufAction = "type_definition",
						mode = "",
						options = { desc = "Go to type definition" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map = {
						action = vim.lsp.buf["implementation"],
						key = "gi",
						lspBufAction = "implementation",
						mode = "",
						options = { desc = "Go to implementation" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map = {
						action = vim.lsp.buf["hover"],
						key = "K",
						lspBufAction = "hover",
						mode = "",
						options = { desc = "Hover info" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map = {
						action = function()
							vim.diagnostic.jump({ count = -1, float = true })
						end,
						key = "<leader>lk",
						mode = "",
						options = { desc = "Previous diagnostic" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map = {
						action = function()
							vim.diagnostic.jump({ count = 1, float = true })
						end,
						key = "<leader>lj",
						mode = "",
						options = { desc = "Next diagnostic" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map =
						{ action = "<CMD>LspStop<CR>", key = "<leader>lx", mode = "", options = { desc = "LSP stop" } }
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map = {
						action = "<CMD>LspStart<CR>",
						key = "<leader>ls",
						mode = "",
						options = { desc = "LSP start" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end

				do
					local map = {
						action = "<CMD>LspRestart<CR>",
						key = "<leader>lr",
						mode = "",
						options = { desc = "LSP restart" },
					}
					local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
					vim.keymap.set(map.mode, map.key, map.action, options)
				end
			end,
			desc = "Load LSP keymaps",
			event = "LspAttach",
			group = "nixvim_lsp_binds",
		},
	}

	for _, autocmd in ipairs(__nixvim_autocommands) do
		vim.api.nvim_create_autocmd(autocmd.event, {
			group = autocmd.group,
			pattern = autocmd.pattern,
			buffer = autocmd.buffer,
			desc = autocmd.desc,
			callback = autocmd.callback,
			command = autocmd.command,
			once = autocmd.once,
			nested = autocmd.nested,
		})
	end
end
