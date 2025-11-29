require("lze").load({
	{
		"jupytext-nvim",
		after = function()
			require("jupytext").setup({})
		end,
	},
	{
		"jovian-nvim",
		dep_of = { "hydra.nvim" },
		ft = { "python" },
		after = function()
			require("jovian").setup({
				preview_width_percent = 30,
				repl_height_percent = 30,
				preview_image_ratio = 0.3,
			})
		end,
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
	-- 	{
	-- 		"hydra.nvim",
	-- 		after = function()
	-- 			local hydra = require("hydra")
	-- 			local jukit_cell = require("jukit.core.cells")
	-- 			local jukit_send = require("jukit.core.send")
	-- 			hydra({
	-- 				name = "JupyterNavigator",
	-- 				hint = [[
	-- _J_/_K_: move down/up  _r_: run cell _l_: send line
	--     _v_: run visual  _a_: run all]],
	-- 				config = {
	-- 					color = "pink",
	-- 					invoke_on_body = true,
	-- 					hint = {
	-- 						float_opts = {
	-- 							border = "rounded", -- you can change the border if you want
	-- 						},
	-- 					},
	-- 				},
	-- 				mode = { "n" },
	-- 				body = "<localleader>j", -- this is the key that triggers the hydra
	-- 				heads = {
	-- 					{
	-- 						"J",
	-- 						function()
	-- 							jukit_cell.jump_to_next()
	-- 						end,
	-- 					},
	-- 					{
	-- 						"K",
	-- 						function()
	-- 							jukit_cell.jump_to_previous()
	-- 						end,
	-- 					},
	-- 					{
	-- 						"r",
	-- 						function()
	-- 							jukit_send.send_cell()
	-- 						end,
	-- 					},
	-- 					{
	-- 						"l",
	-- 						function()
	-- 							jukit_send.send_line()
	-- 						end,
	-- 					},
	-- 					{
	-- 						"v",
	-- 						function()
	-- 							jukit_send.send_selection()
	-- 						end,
	-- 					},
	-- 					{
	-- 						"a",
	-- 						function()
	-- 							require("jukit.terminals.kitty").run_all_cells()
	-- 						end,
	-- 					},
	-- 					{ "<esc>", nil, { exit = true } },
	-- 					{ "q", nil, { exit = true } },
	-- 				},
	-- 			})
	-- 		end,
	-- 	},
})
