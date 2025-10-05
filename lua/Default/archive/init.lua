require("lze").load({
	-- ui
	{
		"nvim-notify",
		after = function()
			vim.notify = require("notify")
			require("notify").setup({})
		end,
		event = { "UIEnter" },
	},
	{
		"neoscroll.nvim",
		event = "DeferredUIEnter",
		after = function(_)
			require("neoscroll").setup({})
		end,
	},
	-- tools
	{
		"vim-startuptime",
	},
	{
		"diffview.nvim",
		after = function(_)
			require("diffview").setup({ use_icons = true })
		end,
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<CR>", mode = "", desc = "Open Diffview", silent = true },
		},
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
		},
	},
	{
		"toggleterm.nvim",
		keys = {
			{ "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Open Default" },
			{ "<leader>tr", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Open REPL" },
			{
				"<leader>tv",
				"<cmd>lua require('toggleterm').send_lines_to_terminal('visual_selection', false)<CR>",
				desc = "Send selected lines",
			},
		},
		cmd = { "ToggleTerm", "TermExec", "ToggleTermSendCurrentLine", "ToggleTermSendVisualSelection" },
		after = function(_)
			require("toggleterm").setup({
				direction = "float",
				float_opts = {
					border = "rounded",
					width = function()
						return math.floor(vim.o.columns * 0.9)
					end,
					height = function()
						return math.floor(vim.o.lines * 0.45)
					end,
					row = 1,
					col = function()
						return math.floor((vim.o.columns - vim.o.columns * 0.9) / 2)
					end,
					winblend = 20,
					zindex = 150,
					title_pos = "center",
				},
				hide_numbers = true,
				insert_mappings = true,
				start_in_insert = true,
				size = function(term)
					if term.direction == "horizontal" then
						return 13
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.3
					end
				end,
			})
		end,
	},
	{
		"lazygit.nvim",
		dep_of = "plenary.nvim",
		after = function(_) end,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"oil-git-status.nvim",
		after = function(_)
			require("oil-git-status").setup({})
		end,
	},
	{
		"oil.nvim",
		dep_of = "oil-git-status.nvim",
		event = { "DeferredUIEnter" },
		keys = {
			{
				"<leader>ol",
				function()
					vim.cmd("topleft vertical 30 vsplit")
					require("oil").open()
					vim.api.nvim_buf_set_name(0, "Oil Explorer")
				end,
				mode = "n",
				desc = "Open Oil",
			},
			{
				"<leader>oF",
				function()
					require("oil").open_float()
				end,
				mode = "n",
				desc = "Open Oil",
			},
			{
				"<leader>of",
				function(_)
					vim.api.nvim_create_autocmd("WinEnter", {
						callback = function()
							local bufname = vim.api.nvim_buf_get_name(0)
							if bufname:match("^oil://") then
								vim.wo.number = false
								vim.wo.relativenumber = false
							end
						end,
					})
					function OpenOilInFloat()
						-- 固定サイズ
						local fixed_width = 30
						local fixed_height = 20

						-- 画面サイズ取得
						local total_cols = vim.o.columns
						local total_lines = vim.o.lines

						-- 入り切るか判定
						local width = fixed_width
						if total_cols < fixed_width + 4 then
							width = math.floor(total_cols * 0.4) -- 相対サイズに切り替え
						end

						local height = fixed_height
						if total_lines < fixed_height + 4 then
							height = math.floor(total_lines * 0.6)
						end

						-- 右上に寄せて、少し下に余白（row: 1〜2）
						local col = total_cols - width - 2
						local row = 2

						-- scratch buffer
						local buf = vim.api.nvim_create_buf(false, true)

						-- フロート作成
						vim.api.nvim_open_win(buf, true, {
							relative = "editor",
							width = width,
							height = height,
							row = row,
							col = col,
							style = "minimal",
							border = "rounded",
						})

						-- oil 起動
						vim.cmd("Oil")

						-- q で閉じる
						vim.keymap.set("n", "q", function()
							vim.api.nvim_win_close(0, true)
						end, { buffer = true })
					end
				end,
				desc = "floating window",
			},
		},
		after = function(_)
			require("oil").setup({ win_options = { signcolumn = "yes:2", winblend = 10 } })
		end,
	},
	{
		"telescope-undo.nvim",
		lazy = true,
	},
	{
		"telescope-ui-select.nvim",
		lazy = true,
	},
	{
		"telescope-fzf-native.nvim",
		lazy = true,
	},
	{
		"telescope-frecency.nvim",
		lazy = true,
	},
	{
		"telescope.nvim",
		dep_of = {
			"telescope-undo.nvim",
			"telescope-ui-select.nvim",
			"telescope-fzf-native.nvim",
			"telescope-frecency.nvim",
		},
		after = function(_)
			require("telescope").setup({
				defaults = {
					layout_config = { prompt_position = "top" },
					layout_strategy = "vertical",
					sorting_strategy = "ascending",
				},
				extensions = {
					frecency = {
						ignore_patterns = { "*.git/*", "*/tmp/*" },
						show_scores = false,
						show_unindexed = true,
					},
					undo = {
						layout_config = { preview_height = 0.8, prompt_position = "top" },
						layout_strategy = "vertical",
						side_by_side = true,
						sorting_strategy = "ascending",
						use_delta = true,
					},
				},
			})

			local __telescopeExtensions = { "undo", "ui-select", "fzf", "frecency" }
			for i, extension in ipairs(__telescopeExtensions) do
				require("telescope").load_extension(extension)
			end
		end,
		keys = {
			{
				"<leader>lD",
				function()
					require("telescope.builtin").lsp_definitions()
				end,
				desc = "Definitions",
			},
			{
				"<leader>ls",
				function()
					require("telescope.builtin").lsp_document_symbols(require("telescope.themes").get_cursor())
				end,
				desc = "Document symbols",
			},
			{
				"<leader>lw",
				function()
					require("telescope.builtin").lsp_workspace_symbols(require("telescope.themes").get_cursor())
				end,
				desc = "Workspace symbols",
			},
			{
				"<leader>lr",
				function()
					require("telescope.builtin").lsp_references(require("telescope.themes").get_cursor())
				end,
				desc = "References",
			},
			{
				"<leader>ld",
				function()
					require("telescope.buildin").diagnostics(require("telescope.themes").get_ivy())
				end,
				desc = "Diagnostics",
			},

			{ "<leader>fn", "<CMD> Noice telescope <CR>", mode = "", desc = "Notifications", silent = true },
			{ "<leader>ff", "<CMD> Telescope find_files <CR>", mode = "", desc = "Find files", silent = true },
			{ "<leader>fg", "<CMD> Telescope live_grep <CR>", mode = "", desc = "Live grep", silent = true },
			{ "<leader>fb", "<CMD> Telescope buffers <CR>", mode = "", desc = "List buffers", silent = true },
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags(require("telescope.themes").get_ivy())
				end,
				mode = "",
				desc = "Help tags",
				silent = true,
			},
			{ "<leader>fc", "<CMD> Telescope commands <CR>", mode = "", desc = "List commands", silent = true },
			{ "<leader>fk", "<CMD> Telescope keymaps <CR>", mode = "", desc = "List keymaps", silent = true },
			{ "<leader>fi", "<CMD> Telescope builtin <CR>", mode = "", desc = "List built-in pickers", silent = true },
			{
				"<leader>fu",
				function()
					require("telescope").extensions.undo.undo()
				end,
				mode = "",
				desc = "Undo history",
				silent = true,
			},
			{ "<leader>fr", "<CMD>Telescope frecency<cr>", mode = "", desc = "Frecency", silent = true },
			{
				"<leader>fp",
				function()
					local function find_git_root()
						-- Use the current buffer's path as the starting point for the git search
						local current_file = vim.api.nvim_buf_get_name(0)
						local current_dir
						local cwd = vim.fn.getcwd()
						-- If the buffer is not associated with a file, return nil
						if current_file == "" then
							current_dir = cwd
						else
							-- Extract the directory from the current file's path
							current_dir = vim.fn.fnamemodify(current_file, ":h")
						end

						-- Find the Git root directory from the current file's path
						local git_root = vim.fn.systemlist(
							"git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel"
						)[1]
						if vim.v.shell_error ~= 0 then
							vim.notify("Not a git repository. Searching on current working directory")
							return cwd
						end
						return git_root
					end

					-- Custom live_grep function to search in git root
					local function live_grep_git_root()
						local git_root = find_git_root()
						if git_root then
							require("telescope.builtin").live_grep({
								search_dirs = { git_root },
							})
						end
					end

					live_grep_git_root()
				end,
				desc = "Live grep Git root",
			},
		},
	},
})
