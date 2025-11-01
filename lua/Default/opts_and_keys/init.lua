-- Set up global options {{{
do
	local nixvim_global_options = { clipboard = "unnamedplus", laststatus = 3 }

	for k, v in pairs(nixvim_global_options) do
		vim.opt_global[k] = v
	end
end
-- }}}

-- Set up globals {{{
do
	local nixvim_globals = {
		helplang = "ja,en",
		loaded_netrw = 1,
		loaded_netrwPlugin = 1,
		loaded_netrwSettings = 1,
		loaded_netrwFileHandlers = 1,
		maplocalleader = " ",
		scrollview_always_show = true,
		scrollview_current_only = true,
	}

	for k, v in pairs(nixvim_globals) do
		vim.g[k] = v
	end
end
-- }}}

-- Set up local options {{{
do
	local nixvim_local_options = { signcolumn = "yes:1" }

	for k, v in pairs(nixvim_local_options) do
		vim.opt_local[k] = v
	end
end
-- }}}

-- Set up options {{{
do
	local nixvim_options = {
		autoindent = true,
		conceallevel = 1,
		cursorline = false,
		expandtab = true,
		hlsearch = true,
		ignorecase = true,
		incsearch = true,
		list = true,
		listchars = "eol:¬,tab:> ,trail:·,nbsp:%",
		matchtime = 1,
		number = true,
		pumblend = 20,
		relativenumber = true,
		scrolloff = 10,
		shiftwidth = 2,
		showmatch = true,
		showmode = false,
		sidescrolloff = 12,
		smartcase = true,
		smartindent = true,
		softtabstop = 2,
		swapfile = false,
		tabstop = 2,
		termguicolors = true,
		updatetime = 300,
		whichwrap = "b,s,<,>,[,]",
		wildmenu = true,
		wildmode = "list:longest,full",
		winblend = 20,
		wrap = false,
		winborder = "rounded",
	}

	for k, v in pairs(nixvim_options) do
		vim.opt[k] = v
	end
end

-- settings about diagnostics
vim.diagnostic.config({
	virtual_text = false, -- 行末のメッセージを無効化
	signs = true, -- サインカラムにアイコンを表示
	underline = true, -- エラーがあるコードに下線を表示
	update_in_insert = false,
})

-- }}}
-- fcitx5 Japanese IME 自動切替
local fcitx5state = vim.fn.system("fcitx5-remote"):sub(1, 1)
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		fcitx5state = vim.fn.system("fcitx5-remote"):sub(1, 1)
		vim.fn.system("fcitx5-remote -c")
	end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		if fcitx5state == "2" then
			vim.fn.system("fcitx5-remote -o")
		end
	end,
})
-- 書き込み前に行末スペースを削除
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		vim.cmd([[%s/\\s\\+$//e]])
	end,
})
-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch", -- ハイライトに使うグループ
			timeout = 300, -- ミリ秒でハイライトの長さ
			on_visual = false,
		})
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "typst" },
	callback = function()
		local o = vim.opt_local
		o.wrap = true
		o.linebreak = true
		o.showbreak = "↪\\"
	end,
})
-- jk で ESC
vim.keymap.set("i", "jk", "<Esc>", { noremap = true })

-- コードセル挿入
vim.keymap.set("n", "<leader>jc", "o<CR># %%<CR>", { noremap = true, silent = true, desc = "Insert code cell (# %%)" })

-- マークダウンセル挿入
vim.keymap.set(
	"n",
	"<leader>jm",
	"o<CR># %% [markdown]<CR># ",
	{ noremap = true, silent = true, desc = "Insert markdown cell (# %% [markdown])" }
)
