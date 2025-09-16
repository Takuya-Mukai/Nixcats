require('lze').load {
  {
    "comment.nvim",
    keys = "g",
    after = function(_)
      require("Comment").setup()
    end,
  },
  {
    "nvim-surround",
    event = "DeferredUIEnter",
    after = function(_)
      require("nvim-surround").setup({})
    end,
    dep_of = { "nvim-treesitter-textobjects" },
  },
  {
    "nvim-autopairs",
    event = "InsertEnter",
    after = function(_)
      require("nvim-autopairs").setup({})
    end,
  },
}
