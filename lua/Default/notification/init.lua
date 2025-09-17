require('lze').load {
  {
    "noice.nvim",
    after = function()
      require("noice").setup({
        lsp = {
          override = {
            ["cmp.entry.get_documentation"] = true,
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          inc_rename = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        },
      })
    end,
    event = { "UIEnter" },
    dep_of = "nvim-notify",
  },
  {
    "nvim-notify",
    after = function()
      vim.notify = require("notify")
      require("notify").setup({})
    end,
    event = { "UIEnter" },
  },
  {
    "fidget.nvim",
    after = function()
      require("fidget").setup({})
    end,
    event = { "LspAttach" },
  },
}
