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
				heading = {
					enabled = false,
					left_pad = 0,
					render_modes = false,
					right_pad = 4,
					sign = true,
					width = "block",
				},
			})
		end,
		ft = { "markdown", "python" },
	},
})
