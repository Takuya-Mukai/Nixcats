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
	{
		"mini.ai",
		event = "DeferredUIEnter",
		dep_of = { "NotebookNavigator.nvim" },
	},
	{
		"iron.nvim",
		dep_of = { "NotebookNavigator.nvim" },
		after = function()
			require("iron.core").setup({
				config = {
					repl_open_cmd = require("iron.view").split.vertical.rightbelow("%30"),
				},
			})
		end,
		lazy = true,
	},
	{
		"NotebookNavigator.nvim",
		ft = { "ipynb", "py" },
		keys = {
			{
				"]h",
				function()
					require("notebook-navigator").move_cell("d")
				end,
			},
			{
				"[h",
				function()
					require("notebook-navigator").move_cell("u")
				end,
			},
			{ "<leader>jX", "<cmd>lua require('notebook-navigator').run_cell()<cr>", desc = "Run Cell" },
			{ "<leader>jx", "<cmd>lua require('notebook-navigator').run_and_move()<cr>", desc = "Run Cell and Move" },
			{ "<leader>ja", "<cmd>lua require('notebook-navigator').run_all_cells()<cr>", desc = "Run All Cells" },
			{
				"<leader>jk",
				"<cmd>lua require('notebook-navigator').insert_cell_above()<cr>",
				desc = "Insert Cell Above",
			},
			{
				"<leader>jj",
				"<cmd>lua require('notebook-navigator').insert_cell_below()<cr>",
				desc = "Insert Cell Below",
			},
			{ "<leader>jd", "<cmd>lua require('notebook-navigator').delete_cell()<cr>", desc = "Delete Cell" },
			{ "<leader>js", "<cmd>lua require('notebook-navigator').save_notebook()<cr>", desc = "Save Notebook" },
			{ "<leader>jl", "<cmd>lua require('notebook-navigator').list_cells()<cr>", desc = "List Cells" },
			{ "<leader>H" },
		},
		after = function()
			require("notebook-navigator").setup({
				activate_hydra_keys = "<leader>H",
			})
			local nn = require("notebook-navigator")
			local opts = { custom_textobjects = { h = nn.miniai_spec } }
			require("mini.ai").setup({
				opts,
			})
		end,
	},
})

-- jupyter
require("lze").load({
	{
		"molten-nvim",
		beforeAll = function()
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = false
			vim.g.molten_virt_lines_off_by_1 = true
			-- automatically import output chunks from a jupyter notebook
			-- tries to find a kernel that matches the kernel in the jupyter notebook
			-- falls back to a kernel that matches the name of the active venv (if any)
		end,
		after = function()
			local imb = function(e) -- init molten buffer
				vim.schedule(function()
					local kernels = vim.fn.MoltenAvailableKernels()
					-- local try_kernel_name = function()
					-- 	local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
					-- 	return metadata.kernelspec.name
					-- end
					-- local ok, kernel_name = pcall(try_kernel_name)
					-- if not ok or not vim.tbl_contains(kernels, kernel_name) then
					-- 	kernel_name = nil
					-- 	local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
					-- 	if venv ~= nil then
					-- 		kernel_name = string.match(venv, "/.+/(.+)")
					-- 	end
					-- end
					local kernel_name = nil
					if kernel_name == nil then
						kernel_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):lower()
					end
					if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
						vim.cmd(("MoltenInit %s"):format(kernel_name))
					end
					vim.cmd("MoltenImportOutput")
				end)
			end

			-- automatically export output chunks to a jupyter notebook on write
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = { "*.ipynb" },
				callback = function()
					if require("molten.status").initialized() == "Molten" then
						vim.cmd("MoltenExportOutput!")
					end
				end,
			})

			-- change the configuration when editing a python file
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*.py",
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					if require("molten.status").initialized() == "Molten" then -- this is kinda a hack...
						vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
						vim.fn.MoltenUpdateOption("virt_text_output", false)
					else
						vim.g.molten_virt_lines_off_by_1 = false
						vim.g.molten_virt_text_output = false
					end
				end,
			})

			-- Undo those config changes when we go back to a markdown or quarto file
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*.qmd", "*.md", "*.ipynb" },
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					if require("molten.status").initialized() == "Molten" then
						vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
						vim.fn.MoltenUpdateOption("virt_text_output", true)
					else
						vim.g.molten_virt_lines_off_by_1 = true
						vim.g.molten_virt_text_output = true
					end
				end,
			})
			-- automatically import output chunks from a jupyter notebook
			vim.api.nvim_create_autocmd("BufAdd", {
				pattern = { "*.ipynb" },
				callback = imb,
			})

			-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*.ipynb" },
				callback = function(e)
					if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
						imb(e)
					end
				end,
			})
		end,
		ft = { "quarto", "markdown", "ipynb" },
	},
	{
		"image.nvim",
		after = function()
			require("image").setup({
				backend = "kitty",
				integrations = {},
				max_width = 100,
				max_height = 20,
				max_height_window_percentage = math.huge,
				max_width_window_percentage = math.huge,
				window_overlap_clear_enabled = true,
			})
		end,
		dep_of = { "molten-nvim" },
	},
	{
		"otter.nvim",
		dep_of = { "quarto-nvim" },
		after = function()
			require("otter").setup({})
		end,
	},
	{
		"quarto-nvim",
		lazy = false,
		dep_of = { "molten-nvim" },
		after = function()
			require("quarto").setup({
				lspFeatures = {
					enabled = true,
					-- NOTE: put whatever languages you want here:
					languages = { "r", "python", "rust" },
					chunks = "none",
					diagnostics = {
						enabled = false,
						triggers = { "BufWritePost" },
					},
					completion = {
						enabled = true,
					},
				},
				keymap = {
					-- NOTE: setup your own keymaps:
					hover = "H",
					definition = "gd",
					rename = "<leader>rn",
					references = "gr",
					format = "<leader>gf",
				},
				codeRunner = {
					enabled = true,
					default_method = "molten",
				},
			})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown" },
				callback = function()
					vim.cmd("QuartoActivate")
				end,
			})
			local runner = require("quarto.runner")
			vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
			vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
			vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
			vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
			vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
			vim.keymap.set("n", "<localleader>RA", function()
				runner.run_all(true)
			end, { desc = "run all cells of all languages", silent = true })
		end,
	},
	{
		"hydra.nvim",
		dep_of = { "quarto-nvim", "molten-nvim" },
		after = function()
			local function keys(str)
				return function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(str, true, false, true), "m", true)
				end
			end

			-- 次のコードブロックの先頭にジャンプ (j)
			function go_to_next_code_block_start()
				local start_pos = vim.api.nvim_win_get_cursor(0)
				local current_line = start_pos[1]

				-- 現在行の次から検索
				vim.api.nvim_win_set_cursor(0, { current_line + 1, 0 })

				-- ```<word> のパターン (インデント対応)
				local pattern = "^\\s*```\\S\\+"

				-- 'W' (ラップしない) フラグで順方向に検索
				local found_pos = vim.fn.searchpos(pattern, "W")

				if found_pos[1] > 0 then
					-- 見つかった行の1行下 (コードの先頭) に移動
					vim.api.nvim_win_set_cursor(0, { found_pos[1] + 1, 0 })
					vim.cmd("normal! ^") -- 行頭の空白以外にジャンプ
				else
					-- 見つからなければ元の場所に戻る
					vim.api.nvim_win_set_cursor(0, start_pos)
				end
			end

			-- 前のコードブロックの先頭にジャンプ (k)
			function go_to_prev_code_block_start()
				local start_pos = vim.api.nvim_win_get_cursor(0)
				local current_line = start_pos[1]

				-- 現在行の前から検索
				vim.api.nvim_win_set_cursor(0, { current_line - 1, 0 })

				local pattern = "^\\s*```\\S\\+"

				-- 'bW' (後方 'b' + ラップしない 'W') フラグで逆方向に検索
				local found_pos = vim.fn.searchpos(pattern, "bW")

				if found_pos[1] > 0 then
					-- 見つかった行の1行下 (コードの先頭) に移動
					vim.api.nvim_win_set_cursor(0, { found_pos[1] + 1, 0 })
					vim.cmd("normal! ^")
				else
					vim.api.nvim_win_set_cursor(0, start_pos)
				end
			end

			local hydra = require("hydra")
			hydra({
				name = "JupyterNavigator",
				hint = [[
_J_/_K_: move down/up  _r_: run cell    _l_: run line  _R_: run above
    _o_: pen output    _v_: run visual  _h_: hide output
    _d_: delete cell   _x_: open in browser   _<esc>_/_q_: exit ]],
				config = {
					color = "pink",
					invoke_on_body = true,
					hint = {
						float_opts = {
							border = "rounded", -- you can change the border if you want
						},
					},
				},
				mode = { "n" },
				body = "<localleader>M", -- this is the key that triggers the hydra
				heads = {
					{ "J", ":lua go_to_next_code_block_start()<CR>" },
					{ "K", ":lua go_to_prev_code_block_start()<CR>" },
					{ "r", ":QuartoSend<CR>" },
					{ "l", ":QuartoSendLine<CR>" },
					{ "R", ":QuartoSendAbove<CR>" },
					{ "o", ":MoltenEnterOutput<CR>" },
					{ "v", ":MoltenEvaluateOperatorCR>" },
					{ "h", ":MoltenHideOutput<CR>" },
					{ "d", ":MoltenDelete<CR>" },
					{ "x", ":MoltenOpenInBrowser<CR>" },
					{ "h", ":MoltenHideOutput<CR>" },
					{ "<esc>", nil, { exit = true } },
					{ "q", nil, { exit = true } },
				},
			})
		end,
	},
})

-- Provide a command to create a blank new Python notebook
-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
-- if you use another language than Python, you should change it in the template.
local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

local function new_notebook(filename)
	local path = filename .. ".ipynb"
	local file = io.open(path, "w")
	if file then
		file:write(default_notebook)
		file:close()
		vim.cmd("edit " .. path)
	else
		print("Error: Could not open new notebook file for writing.")
	end
end

vim.api.nvim_create_user_command("NewNotebook", function(opts)
	new_notebook(opts.args)
end, {
	nargs = 1,
	complete = "file",
})
vim.keymap.set("n", "<localleader>me", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
vim.keymap.set(
	"n",
	"<localleader>mo",
	":noautocmd MoltenEnterOutput<CR>",
	{ desc = "open output window", silent = true }
)
vim.keymap.set("n", "<localleader>mc", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
vim.keymap.set(
	"v",
	"<localleader>mv",
	":<C-u>MoltenEvaluateVisual<CR>gv",
	{ desc = "execute visual selection", silent = true }
)
vim.keymap.set("n", "<localleader>mh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })

-- if you work with html outputs:
vim.keymap.set("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })
require("lze").load({
	{
		"neopyter-nvim",
		ft = { "python" },
		after = function()
			require("neopyter").setup({
				mode = "direct",
				remote_address = "127.0.0.1:9001",
				file_pattern = "*.ju.*",
				on_attach = function(buf)
					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = buf })
					end
					-- same, recommend the former
					map("n", "<C-Enter>", "<cmd>Neopyter execute notebook:run-cell<cr>", "run selected")
					-- map("n", "<C-Enter>", "<cmd>Neopyter run current<cr>", "run selected")

					-- same, recommend the former
					map("n", "<leader>jX", "<cmd>Neopyter execute notebook:run-all-above<cr>", "run all above cell")
					-- map("n", "<space>X", "<cmd>Neopyter run allAbove<cr>", "run all above cell")

					-- same, recommend the former, but the latter is silent
					map("n", "<leader>js", "<cmd>Neopyter execute kernelmenu:restart<cr>", "restart kernel")
					-- map("n", "<space>nt", "<cmd>Neopyter kernel restart<cr>", "restart kernel")

					map(
						"n",
						"<S-Enter>",
						"<cmd>Neopyter execute notebook:run-cell-and-select-next<cr>",
						"run selected and select next"
					)
					map(
						"n",
						"<M-Enter>",
						"<cmd>Neopyter execute notebook:run-cell-and-insert-below<cr>",
						"run selected and insert below"
					)

					map(
						"n",
						"<leader>jr",
						"<cmd>Neopyter execute notebook:restart-run-all<cr>",
						"restart kernel and run all"
					)
				end,
			})
		end,
	},
	{
		"jupytext-nvim",
		after = function()
			require("jupytext").setup({})
		end,
	},
	{
		"hydra.nvim",
		dep_of = { "neopyter-nvim" },
		after = function()
			local function keys(str)
				return function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(str, true, false, true), "m", true)
				end
			end

			-- 次のコードブロックの先頭にジャンプ (j)
			function go_to_next_code_block_start()
				local start_pos = vim.api.nvim_win_get_cursor(0)
				local current_line = start_pos[1]

				-- 現在行の次から検索
				vim.api.nvim_win_set_cursor(0, { current_line + 1, 0 })

				-- ```<word> のパターン (インデント対応)
				local pattern = "^\\s*# %%\\S*"

				-- 'W' (ラップしない) フラグで順方向に検索
				local found_pos = vim.fn.searchpos(pattern, "W")

				if found_pos[1] > 0 then
					-- 見つかった行の1行下 (コードの先頭) に移動
					vim.api.nvim_win_set_cursor(0, { found_pos[1] + 1, 0 })
					vim.cmd("normal! ^") -- 行頭の空白以外にジャンプ
				else
					-- 見つからなければ元の場所に戻る
					vim.api.nvim_win_set_cursor(0, start_pos)
				end
			end

			-- 前のコードブロックの先頭にジャンプ (k)
			function go_to_prev_code_block_start()
				local start_pos = vim.api.nvim_win_get_cursor(0)
				local current_line = start_pos[1]

				-- 現在行の前から検索
				vim.api.nvim_win_set_cursor(0, { current_line - 1, 0 })

				local pattern = "^\\s*# %%\\S*"

				-- 'bW' (後方 'b' + ラップしない 'W') フラグで逆方向に検索
				local found_pos = vim.fn.searchpos(pattern, "bW")

				if found_pos[1] > 0 then
					-- 見つかった行の1行下 (コードの先頭) に移動
					vim.api.nvim_win_set_cursor(0, { found_pos[1] + 1, 0 })
					vim.cmd("normal! ^")
				else
					vim.api.nvim_win_set_cursor(0, start_pos)
				end
			end

			local hydra = require("hydra")
			hydra({
				name = "JupyterNavigator",
				hint = [[
_J_/_K_: move down/up  _r_: run cell     _R_: run above
_v_: run visual  _b_: run & insert below _w_: restart & run all
                  _s_: restart kernel]],
				config = {
					color = "pink",
					invoke_on_body = true,
					hint = {
						float_opts = {
							border = "rounded", -- you can change the border if you want
						},
					},
				},
				mode = { "n" },
				body = "<localleader>j", -- this is the key that triggers the hydra
				heads = {
					{ "J", ":lua go_to_next_code_block_start()<CR>" },
					{ "K", ":lua go_to_prev_code_block_start()<CR>" },
					{ "r", ":Neopyter execute notebook:run-cell<CR>" },
					{ "R", ":Neopyter execute notebook:run-all-above<CR>" },
					{ "v", ":Neopyter execute notebook:run-cell-and-select-next<CR>" },
					{ "b", ":Neopyter execute notebook:run-cell-and-insert-below<CR>" },
					{ "w", ":Neopyter execute notebook:restart-run-all<CR>" },
					{ "s", ":Neopyter execute kernelmenu:restart<CR>" },
					{ "<esc>", nil, { exit = true } },
					{ "q", nil, { exit = true } },
				},
			})
		end,
	},
	{
		"websocket-nvim",
		dep_of = { "neopyter-nvim" },
	},
})
