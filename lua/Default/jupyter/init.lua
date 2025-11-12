require("lze").load({
	{
		"vim-jukit",
		ft = { "json" },
		after = function() end,
	},
	{
		"hydra.nvim",
		dep_of = { "vim-jukit" },
		after = function()
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
