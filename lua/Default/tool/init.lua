require('lze').load {
  {
    "lazygit.nvim",
    dep_of = "plenary.nvim",
    after = function(_)
    end,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    "which-key.nvim",
    event = "DeferredUIEnter",
    after = function(_)
      require("which-key").setup({
        win = {
          border = "rounded",
          zindex = 1000,
        },
      })
      require("which-key").add({})
    end,
  }
}
