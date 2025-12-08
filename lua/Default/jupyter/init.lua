require("lze").load({
	{
		"jupytext-nvim",
		after = function()
			require("jupytext").setup({})
		end,
	},
	{
		"jovian-nvim",
		ft = { "python" },
		after = function()
			require("jovian").setup({
				ui_symbols = {
					running = " ",
					done = " ",
					error = " ",
					interrupted = " ",
					stale = " ",
				},
			})
		end,
		keys = {
			{ "<leader>jt", "<cmd>JovianToggle<cr>", desc = "Open Jovian UI" },
			{ "<leader>jc", "<cmd>JovianClear<cr>", desc = "Clear REPL" },
			{ "<leader>jp", "<cmd>JovianTogglePlot<cr>", desc = "Toggle Plot" },

			{ "<leader>jr", "<cmd>JovianRun<cr>", desc = "Run Current Cell" },
			{ "<leader>jn", "<cmd>JovianRunAndNext<cr>", desc = "Run Cell and Next" },
			{ "<leader>ja", "<cmd>JovianRunAll<cr>", desc = "Run All Cells" },
			{ "<leader>jl", "<cmd>JovianRunLine<cr>", desc = "Run Current Line" },
			{ "<leader>jv", "<cmd>JovianSendSelection<cr>", desc = "Run Visual Selection" },

			{ "<leader>js", "<cmd>JovianStart<cr>", desc = "Start Kernel" },
			{ "<leader>jk", "<cmd>JovianRestart<cr>", desc = "Restart Kernel" },
			{ "<leader>ji", "<cmd>JovianInterrupt<cr>", desc = "Interrupt Execution" },
			{ "<leader>jC", "<cmd>JovianCleanCache<cr>", desc = "Clean Cache" },

			{ "<leader>jj", "<cmd>JovianNextCell<cr>", desc = "Next Cell" },
			{ "<leader>jk", "<cmd>JovianPrevCell<cr>", desc = "Previous Cell" },
			{ "<leader>jA", "<cmd>JovianNewCellAbove<cr>", desc = "New Cell Above" },
			{ "<leader>jB", "<cmd>JovianNewCellBelow<cr>", desc = "New Cell Below" },
			{ "<leader>jd", "<cmd>JovianDeleteCell<cr>", desc = "Delete Current Cell" },
			{ "<leader>jK", "<cmd>JovianMoveCellUp<cr>", desc = "Move Cell Up" },
			{ "<leader>jJ", "<cmd>JovianMoveCellDown<cr>", desc = "Move Cell Down" },
			{ "<leader>jm", "<cmd>JovianMergeBelow<cr>", desc = "Merge with Below" },
			{ "<leader>js", "<cmd>JovianSplitCell<cr>", desc = "Split Cell at Cursor" },

			{ "<leader>jV", "<cmd>JovianVars<cr>", desc = "Show Variables" },
			{ "<leader>jD", "<cmd>JovianDoc<cr>", desc = "Inspect Object Docstring" },
			{ "<leader>jP", "<cmd>JovianPeek<cr>", desc = "Peek Object Info" },
		},
	},
	{
		"image.nvim",
		dep_of = { "jovian-nvim" },
		after = function()
			require("image").setup({
				backend = "kitty",
				processor = "magick_cli",
				max_width_window_percentage = 100,
				max_height_window_percentage = 30,
				window_overlap_clear_enabled = true,
			})
		end,
	},
	{
		"hydra.nvim",
		after = function()
			local hydra = require("hydra")
			hydra({
				name = "Jupyter",
				hint = [[
  _J_/_K_: move down/up  _R_: run cell _L_: send line
_S_: run visual  _C_: new code cell _M_: new markdown cell
]],
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
					{ "J", ":JovianNextCell<CR>" },
					{ "K", ":JovianPrevCell<CR>" },
					{ "R", ":JovianRun<CR>" },
					{ "L", ":JovianRunLine<CR>" },
					{ "S", ":JovianSendSelection<CR>" },
					{ "C", ":JovianNewCellBelow<CR>" },
					{ "M", ":JovianNewMarkdownCellBelow<CR>" },
					{ "<esc>", nil, { exit = true } },
					{ "q", nil, { exit = true } },
				},
			})
		end,
	},
})
