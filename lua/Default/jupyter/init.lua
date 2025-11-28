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
		"hydra.nvim",
		after = function()
			local hydra = require("hydra")
			local jukit_cell = require("jukit.core.cells")
			local jukit_send = require("jukit.core.send")
			hydra({
				name = "JupyterNavigator",
				hint = [[
_J_/_K_: move down/up  _r_: run cell _l_: send line
    _v_: run visual  _a_: run all]],
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
					{
						"J",
						function()
							jukit_cell.jump_to_next()
						end,
					},
					{
						"K",
						function()
							jukit_cell.jump_to_previous()
						end,
					},
					{
						"r",
						function()
							jukit_send.send_cell()
						end,
					},
					{
						"l",
						function()
							jukit_send.send_line()
						end,
					},
					{
						"v",
						function()
							jukit_send.send_selection()
						end,
					},
					{
						"a",
						function()
							require("jukit.terminals.kitty").run_all_cells()
						end,
					},
					{ "<esc>", nil, { exit = true } },
					{ "q", nil, { exit = true } },
				},
			})
		end,
	},
})

vim.g.jukit_terminal = "kitty"
vim.g.jukit_output_new_os_window = 1
vim.g.jukit_outhist_nes_os_window = 1

local jukit_config_dir = vim.fn.expand("~/.local/share/jukit-nvim")
vim.g.jukit_config_dir = jukit_config_dir
-- g:jukit_config_dir は既にLuaのグローバル変数として設定されている前提
if vim.fn.isdirectory(vim.g.jukit_config_dir) == 0 then
	vim.fn.system({ "mkdir", "-p", vim.g.jukit_config_dir })
end
