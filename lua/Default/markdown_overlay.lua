local M = {}

-- namespace for extmarks
local ns = vim.api.nvim_create_namespace("markdown_overlay_ns")

-- debounce helper
local timer = vim.loop.new_timer()

-- Render markdown cell lines into virt_lines (簡易)
local function render_markdown_lines(lines)
	local virt_lines = {}
	for _, line in ipairs(lines) do
		local text = line:gsub("^# ?", "")
		local hl = "Normal"

		if text:match("^# ") then
			text = text:gsub("^# ", "")
			hl = "Title"
		elseif text:match("^## ") then
			text = text:gsub("^## ", "")
			hl = "Constant"
		elseif text:match("^%- ") then
			text = "• " .. text:gsub("^%- ", "")
			hl = "Identifier"
		end

		table.insert(virt_lines, { { text, hl } })
	end
	return virt_lines
end

-- Extract markdown cells from buffer
local function get_markdown_cells(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local cells = {}
	local inside_md = false
	local cell = {}

	for i, line in ipairs(lines) do
		if line:match("^# %% %[markdown%]") then
			inside_md = true
			cell = { start = i - 1, lines = {} } -- 0-indexed
		elseif inside_md and line:match("^# %%") then
			inside_md = false
			table.insert(cells, cell)
		elseif inside_md then
			table.insert(cell.lines, line)
		end
	end

	if inside_md then
		table.insert(cells, cell)
	end
	return cells
end

-- Create or update scratch buffer for markdown cell
local function attach_scratch_buf(cell)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, cell.lines)
	vim.bo[buf].filetype = "markdown"

	-- render-markdown.nvim attach
	local ok, render_markdown = pcall(require, "render-markdown")
	if ok then
		render_markdown.attach(buf)
	end

	return buf
end

-- Render overlay in Python buffer
function M.render_overlay()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	local cells = get_markdown_cells(bufnr)
	for _, cell in ipairs(cells) do
		local virt_lines = render_markdown_lines(cell.lines)
		vim.api.nvim_buf_set_extmark(bufnr, ns, cell.start, 0, {
			virt_lines = virt_lines,
			hl_mode = "combine",
		})

		-- scratch buffer attach (optional, can reuse later)
		cell.scratch_buf = attach_scratch_buf(cell)
	end
end

-- Debounced version for autocmd
function M.render_overlay_debounced(delay)
	timer:stop()
	timer:start(
		delay or 100,
		0,
		vim.schedule_wrap(function()
			M.render_overlay()
		end)
	)
end

-- Setup autocmd for live update
function M.setup_autocmd()
	vim.cmd([[
    augroup MarkdownOverlay
      autocmd!
      autocmd BufReadPost,BufWritePost,TextChanged,TextChangedI *.py lua require("markdown_overlay").render_overlay_debounced()
    augroup END
  ]])
end

return M
