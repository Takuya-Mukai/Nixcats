require("lze").load({
	{
		"jupytext-nvim",
		after = function()
			require("jupytext").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
			})
		end,
	},
	{
		"mini.ai",
		event = "DeferredUIEnter",
		dep_of = { "NotebookNavigator.nvim" },
	},
	{
		"hydra.nvim",
		dep_of = { "NotebookNavigator.nvim" },
		after = function()
			require("hydra").setup({})
		end,
		lazy = true,
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
