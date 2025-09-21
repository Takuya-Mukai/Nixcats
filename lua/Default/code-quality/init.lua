require("lze").load({
  {
    "nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    after = function(_)
      require("lint").linters_by_ft = {
        shell = { "shellcheck" },
        python = { "ruff" },
        lua = { "luacheck" },
        rust = { "clippy" },
        nix = { "statix", "deadnix" },
        markdown = { "markdownlint-cli2"},
        cpp = { "clang-tidy" },
        sql = { "sqlfluff" },
        yaml = { "yq" },
        docker = { "hadolint" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()

          -- try_lint without arguments runs the linters defined in `linters_by_ft`
          -- for the current filetype
          require("lint").try_lint()

          -- You can call `try_lint` with a linter name or a list of names to always
          -- run specific linters, independent of the `linters_by_ft` configuration
          -- require("lint").try_lint("cspell")
        end,
      })
    end,
  },
  {
    "conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<leader>lf",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    after = function(_)
      require("conform").setup({
        formatters_by_ft = {
          python = { "isort", "black" },
          markdown = { "markdownlint-cli2", },
          lua = { "stylua", },
          nix = { "nixfmt", "nixpkgs-fmt", },
          cpp = { "clang-format", },
          shell = { "shellcheck" },
          sql = { "sqlfluff" },
          typst = { "typstyle" },
          yaml = { "yq" },
          json = { "yq" },
          xml = { "yq" },
        },
        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  }
})
