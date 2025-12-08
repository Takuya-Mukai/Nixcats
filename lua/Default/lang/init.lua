require("lze").load({
	{
		"typst-preview.nvim",
		after = function()
			require("typst-preview").setup({ dependencies_bin = { tinymist = "tinymist", websocat = "websocat" } })
		end,
		ft = { "typ" },
	},
	{
		"render-markdown.nvim",
		after = function()
			require("render-markdown").setup({
				code = { right_pad = 4, width = "block" },
				completions = { blink = { enabled = true } },
				file_types = { "markdown", "vimwiki" },
				heading = {
					enabled = false,
					left_pad = 0,
					render_modes = false,
					right_pad = 4,
					sign = true,
					width = "block",
				},
				injections = {
					python = {
						enabled = true,
						query = [[
              ;
              ; === Markdownセル ===
              ;
              (comment
                (source) @injection.content
                ; Markdownセルの開始マーカー
                (#match? @injection.content "^# %% \\[markdown\\].*") 
                (#set! injection.language "markdown")
                (#set! injection.strip_prefix "# ")
                (#set! injection.combined)
              )
              (comment
                (source) @injection.content
                ; Markdownセルに属するコメント行
                ; (注: '# ' で始まり、'%' が続かない行、または '#' のみの行)
                (#match? @injection.content "^#( [^%].*|$)")
                (#set! injection.language "markdown")
                (#set! injection.strip_prefix "# ")
                (#set! injection.combined)
              )
            ]],
					},
					gitcommit = {
						enabled = true,
						query = [[
              ((message) @injection.content
                (#set! injection.combined)
                (#set! injection.include-children)
                (#set! injection.language "markdown"))
            ]],
					},
				},
			})
			local overlay = require("Default.markdown_cell_overlay")
			vim.api.nvim_create_user_command("RenderMarkdownOverlay", function()
				overlay.render_markdown_cells()
			end, {})
		end,
		ft = { "markdown", "python" },
	},
})
