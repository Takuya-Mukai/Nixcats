require("lze").load({
	{
		"neopyter",
		ft = { "python" },
		after = function()
			require("neopyter").setup({
				mode = "direct",
				remote_address = "127.0.0.1:9001",
				file_pattern = "*.ju.*",
				on_attach = function(bufnr)
					local opts = { buffer = bufnr, remap = false }
					vim.keymap.set("n", "<leader>jc", function()
						require("neopyter").run_cell()
					end, opts)
					vim.keymap.set("n", "<leader>jr", function()
						require("neopyter").run_all()
					end, opts)
					vim.keymap.set("n", "<leader>jf", function()
						require("neopyter").run_file()
					end, opts)
					vim.keymap.set("n", "<leader>jR", function()
						require("neopyter").restart_kernel()
					end, opts)
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
		dep_of = { "neopyter" },
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
				local pattern = "^\\s*# %%\\S\\+"

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

				local pattern = "^\\s*# %%\\S\\+"

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
					{ "a", ":Neopyter execute notebook:restart-run-all<CR>" },
					{ "s", ":Neopyter execute kernelmenu:restart<CR>" },
					{ "<esc>", nil, { exit = true } },
					{ "q", nil, { exit = true } },
				},
			})
		end,
	},
	{
		"websocket.nvim",
		dep_of = { "neopyter" },
	},
})
