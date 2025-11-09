local M = {}

local render_markdown = require("render-markdown")

-- コメント先頭の '#' を削除して Markdown用テキストに変換
local function preprocess_comment_lines(lines)
	print("preprocess_comment_lines input:", vim.inspect(lines))
	local processed = {}
	for _, line in ipairs(lines) do
		-- 念のため文字列に変換
		local str = tostring(line)
		processed[#processed + 1] = str:gsub("^#%s?", "")
	end
	return processed
end

local function get_win_for_buf(bufnr)
	local wins = vim.api.nvim_list_wins()
	for _, win in ipairs(wins) do
		if vim.api.nvim_win_is_valid(win) then
			local config = vim.api.nvim_win_get_config(win)
			if vim.api.nvim_win_get_buf(win) == bufnr and (not config.relative or config.relative == "") then
				return win
			end
		end
	end
	return nil
end

local function get_text_start_column(winid, lnum)
	if not winid or not vim.api.nvim_win_is_valid(winid) then
		vim.notify("get_text_start_column: Invalid window ID provided.", vim.log.levels.WARN)
		return 0 -- 安全なフォールバック値
	end

	-- nvim_win_call を使い、指定したウィンドウのコンテキストで計算します
	-- これにより、現在のカーソル位置やウィンドウフォーカスを変更しません
	local start_col_1idx = vim.api.nvim_win_call(winid, function()
		-- [1] = row (0-indexed), [2] = col (0-indexed, byte index)
		local save_cursor = vim.api.nvim_win_get_cursor(0)

		-- lnum (1-indexed) を 0-indexed row に
		local target_row_0idx = lnum - 1

		-- バッファの最終行 (0-indexed)
		local buf = vim.api.nvim_win_get_buf(0) -- 0はカレントウィンドウのバッファ
		local last_line_0idx = vim.api.nvim_buf_line_count(buf) - 1

		-- 行番号が範囲外にならないよう調整
		if target_row_0idx > last_line_0idx then
			target_row_0idx = last_line_0idx
		end
		if target_row_0idx < 0 then
			target_row_0idx = 0
		end

		-- カーソルを対象行の先頭 (0列目) に一時的に移動
		-- set_cursor は {row (1-indexed), col (0-indexed)}
		vim.api.nvim_win_set_cursor(0, { target_row_0idx + 1, 0 })

		-- wincol() でスクリーン列 (1-indexed) を取得
		local col = vim.fn.wincol()

		-- カーソルを元の位置に戻す
		-- set_cursor は {row (1-indexed), col (0-indexed)}
		vim.api.nvim_win_set_cursor(0, { save_cursor[1] + 1, save_cursor[2] })

		return col
	end)

	-- wincol() は 1-indexed のスクリーン列を返します。
	-- 0-indexed のオフセット（ガター幅）を返すために -1 します。
	return start_col_1idx - 1
end

-- Markdownセルを行単位で取得
function M.find_markdown_blocks(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local blocks = {}
	local i = 1

	print("Scanning buffer", bufnr, "total lines:", #lines)

	while i <= #lines do
		local line = lines[i]
		if line:match("^# %%%% %[markdown%].*") then
			local start_row = i
			i = i + 1
			local block_lines = {}

			while i <= #lines and lines[i]:match("^#") and not lines[i]:match("^# %%%%.*") do
				table.insert(block_lines, lines[i])
				i = i + 1
			end

			table.insert(blocks, { start_row = start_row, end_row = i - 1, lines = block_lines })
			print("Found markdown block:", start_row, i - 1, vim.inspect(block_lines))
		else
			i = i + 1
		end
	end

	print("Total markdown blocks found:", #blocks)
	return blocks
end

-- Markdown overlayバッファを作成
function M.create_overlay(bufnr, blocks)
	local win = get_win_for_buf(bufnr)
	if not win then
		vim.notify("No window found for buffer " .. bufnr, vim.log.levels.WARN)
		return nil, nil
	end

	-- overlay の開始行・列
	local start_line = blocks[1].start_row -- 1-indexed
	local start_col = get_text_start_column(win, start_line)
	local col_offset = 2

	-- overlay の高さ計算
	local height = 0
	for _, block in ipairs(blocks) do
		height = height + #block.lines
		height = height + 1 -- セル間の空行
	end
	if height > 0 then
		height = height - 1
	end -- 最後の余分な空行を削除

	-- 親ウィンドウの高さを超えないように制限
	local parent_height = vim.api.nvim_win_get_height(win)
	if height > parent_height - start_line then
		height = parent_height - start_line
	end
	if height < 0 then
		height = 0
	end

	-- scratch バッファ作成
	local overlay_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(overlay_buf, "modifiable", true)
	vim.api.nvim_buf_set_option(overlay_buf, "filetype", "markdown")
	vim.api.nvim_buf_set_option(overlay_buf, "number", false)
	vim.api.nvim_buf_set_option(overlay_buf, "relativenumber", false)
	-- Markdownテキストを書き込む
	local all_text = {}
	for i, block in ipairs(blocks) do
		local processed = preprocess_comment_lines(block.lines)
		vim.list_extend(all_text, processed)
		if i < #blocks then
			table.insert(all_text, "") -- 最後のブロックの後には空行を入れない
		end
	end
	vim.api.nvim_buf_set_lines(overlay_buf, 0, -1, false, all_text)

	-- === ▼ここからが修正点▼ ===

	-- ★要望1: 書き込んだ内容から最大の「表示幅」を計算する
	local max_width = 0
	for _, line in ipairs(all_text) do
		local line_width = vim.fn.strdisplaywidth(line)
		if line_width > max_width then
			max_width = line_width
		end
	end

	-- 親ウィンドウの幅を超えないように制限する
	local parent_width = vim.api.nvim_win_get_width(win)
	local available_width = parent_width - (start_col + col_offset)

	-- ★ 利用可能な幅が0以下にならないよう保証する
	if available_width <= 0 then
		available_width = 1 -- エラー回避のため最小幅1を確保
	end
	-- テキストが空だった場合や計算結果が0以下の場合のフォールバック
	if max_width <= 0 then
		max_width = 1 -- 最小幅（例）
	end

	-- overlay ウィンドウ作成
	local overlay_win = vim.api.nvim_open_win(overlay_buf, false, {
		relative = "win",
		win = win,
		width = max_width, -- ★要望1: 最大幅に設定
		height = height,
		row = start_line - 1, -- APIは0-indexed (1-indexedの行番号から-1)
		col = start_col + col_offset,
		focusable = false,
		zindex = 50,
		border = "none", -- ★要望2: ボーダーを "none" に設定
		winhighlight = "Normal:NormalFloat",
	})

	-- === ▲ここまでが修正点▲ ===

	return overlay_buf, overlay_win
end

-- Markdownセルだけ overlay でレンダリング
function M.render_markdown_cells(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	print("Rendering markdown for buffer:", bufnr)

	local blocks = M.find_markdown_blocks(bufnr)
	print("Total markdown blocks found:", #blocks)
	for _, b in ipairs(blocks) do
		print("Found markdown block:", b.start_row, b.end_row, vim.inspect(b.lines))
	end

	if #blocks == 0 then
		return
	end
	local overlay_buf, overlay_win = M.create_overlay(bufnr, blocks)
	return overlay_buf, overlay_win
end

vim.api.nvim_create_user_command("RenderMarkdownOverlay", function()
	M.render_markdown_cells()
end, {})

return M
