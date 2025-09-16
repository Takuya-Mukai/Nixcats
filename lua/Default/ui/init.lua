local colorschemeName = nixCats('colorscheme')
if not require('nixCatsUtils').isNixCats then
  colorschemeName = "catppuccin"
end

require("catppuccin").setup({
  flavour = "mocha",
  integrations = {
    aerial = true,
    blink_cmp = {
      style = "rounded",
    },
    diffview = true,
    fidget = true,
    gitsigns = true,
    noice = true,
    notify = true,
    treesitter_context = true,
    vimwiki = true,
    lsp_trouble = true,
    which_key = true,
    nvim_surround = true,
  },
})

vim.cmd.colorscheme(colorschemeName)

require('lze').load {
  {
    "nvim-highlight-color",
    event = "DeferredUIEnter",
    after = {
      require('nvim-highlight-colors').setup({})
    },
  },
  {
    "smear-cursor.nvim",
    event = "DeferredUIEnter",
    after = {
      require('smear_cursor').setup({
        stiffness = 0.5,
        trailing_stiffness = 0.49,
        never_draw_over_target = false,
      })
    },
  },
  {
    "nvim-treesitter",
    event = "BufReadPre",
    after = {
      require('nvim-treesitter.configs').setup {
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn", -- set to `false` to disable one of the mappings
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      },

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("MyTreeSitterFold", { clear = true }),
        pattern = "*", -- すべてのファイルタイプで試す。必要に応じて絞り込む
        callback = function()
          -- Tree-sitterのパーサーがそのバッファにあればfoldexprを設定
          if vim.treesitter.language.get_parser() then
            vim.opt.foldmethod = 'expr'
            vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          end
        end
      })
    }
  },
  {
    "nvim-treesitter-context",
    event = { "CursorMoved", "CursorMovedI" },
    dep_of = "nvim-treesitter",
    after = {
      require('treesitter-context').setup {
        enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = true,       -- Enable multiwindow support.
        max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20,     -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      }
    }
  },
  {
    "nvim-treesitter-textobjects",
    event = "DeferredUIEnter",
    dep_of = "nvim-treesitter",
    after = function(_)
      require('nvim-treesitter.configs').setup {
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = { query = "@function.outer", desc = "Select outer part of a function region" },
              ["if"] = { query = "@function.inner", desc = "Select inner part of a function region" },
              ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              -- You can also use captures from other query groups like `locals.scm`
              ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V',  -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true or false
            include_surrounding_whitespace = true,
          },

          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = { query = "@function.outer", desc = "Next function start" },
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              --
              -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
              ["]o"] = { query = "@loop.*", desc = "Next loop start" },
              -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
              --
              -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
              -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
              ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]M"] = { query = "@function.outer", desc = "Next function end" },
              ["]["] = { query = "@class.outer", desc = "Next class end" },
            },
            goto_previous_start = {
              ["[m"] = { query = "@function.outer", desc = "Previous function start" },
              ["[["] = { query = "@class.outer", desc = "Previous class start" },
            },
            goto_previous_end = {
              ["[M"] = { query = "@function.outer", desc = "Previous function end" },
              ["[]"] = { query = "@class.outer", desc = "Previous class end" },
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
              ["]d"] = { query = "@conditional.outer", desc = "Next closer start or end" },
            },
            goto_previous = {
              ["[d"] = { query = "@conditional.outer", desc = "Previous closer start or end" },
            }
          },

          lsp_interop = {
            enable = true,                                                                       -- 機能を有効化
            border = 'rounded',                                                                  -- フロートウィンドウの枠線スタイル
            floating_preview_opts = {},                                                          -- `:h vim.lsp.util.open_floating_preview()` に渡すオプション
            peek_definition_code = {
              ["<leader>df"] = { query = "@function.outer", desc = "Peek function definition" }, -- 関数の定義を「チラ見」する
              ["<leader>dF"] = { "@class.outer", desc = "Peek class definition" },
            },
          },
        },
      }
    end,
  },
  {
    "nvim-treesitter-refactor",
    dep_of = "nvim-treesitter",
    keys = {
      {
        "<leader>rgd",
        function() require("nvim-treesitter-refactor.navigation").goto_definition_lsp_fallback() end,
        desc = "Go to definition with LSP fallback",
        mode = "n",
      },
      {
        "<leader>rlD",
        function() require("nvim-treesitter-refactor.navigation").list_definitions() end,
        desc = "List definitions",
        mode = "n",
      },
      {
        "<leader>rld",
        function() require("nvim-treesitter-refactor.navigation").list_definitions_toc() end,
        desc = "List definitions TOC",
        mode = "n",
      },
      {
        "<A-*>",
        function() require("nvim-treesitter-refactor.navigation").goto_next_usage() end,
        desc = "Go to next usage",
        mode = "n",
      },
      {
        "<A-#>",
        function() require("nvim-treesitter-refactor.navigation").goto_previous_usage() end,
        desc = "Go to previous usage",
        mode = "n",
      },
      {
        "<leader>rr",
        function() require("nvim-treesitter-refactor.smart_rename").smart_rename() end,
        desc = "Smart Rename",
        mode = "n",
      },
    },
    after = function(_)
      require('nvim-treesitter.configs').setup {
        refactor = {
          smart_rename = {
            enable = true,
            -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
          },
          navigation = {
            enable = true,
          },
        },
      }
    end,
  },
  {
    "rainbow-delimiters.nvim",
    dep_of = "nvim-treesitter",
    after = function(_)
      require('rainbow-delimiters').setup()
    end,
  },
  {
    "gitsigns.nvim",
    event = {
      "BufReadPre",
      "BufNewFile",
      "InsertEnter",
      "TextChanged",
      "TextChangedI",
    },
    after = function(_)
      require('gitsigns').setup {
        signs = {
          add = { text = " ┃" },
          change = { text = " ┃" },
          delete = { text = " ━" },
          topdelete = { text = " ┳" },
          changedelete = { text = " ┳" },
          untracked = { text = " ⡇" },
        },
        signs_staged = {
          add = { text = "┃ " },
          change = { text = "┃ " },
          delete = { text = "━ " },
          topdelete = { text = "┳ " },
          changedelete = { text = "┳ " },
          untracked = { text = "⡇ " },
        },
        attach_to_untracked = false,
        signcolumn = true,
        word_diff = true,
        linehl = false,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 100,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> - <summary>",

        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end, 'Next hunk')

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end, 'Previous hunk')

          -- Actions
          map('n', '<leader>hs', gitsigns.stage_hunk, 'Stage hunk')
          map('n', '<leader>hr', gitsigns.reset_hunk, 'Reset hunk')

          map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, 'Stage selected hunk')

          map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, 'Reset selected hunk')

          map('n', '<leader>hS', gitsigns.stage_buffer, 'Stage buffer')
          map('n', '<leader>hR', gitsigns.reset_buffer, 'Reset buffer')
          map('n', '<leader>hp', gitsigns.preview_hunk, 'Preview hunk')
          map('n', '<leader>hi', gitsigns.preview_hunk_inline, 'Inline preview hunk')

          map('n', '<leader>hb', function()
            gitsigns.blame_line({ full = true })
          end, 'Blame line (full)')

          map('n', '<leader>hd', gitsigns.diffthis, 'Diff this')
          map('n', '<leader>hD', function()
            gitsigns.diffthis('~')
          end, 'Diff against last commit')

          map('n', '<leader>hQ', function()
            gitsigns.setqflist('all')
          end, 'Set quickfix list (all hunks)')

          map('n', '<leader>hq', gitsigns.setqflist, 'Set quickfix list (unresolved hunks)')

          -- Toggles
          map('n', '<leader>htb', gitsigns.toggle_current_line_blame, 'Toggle line blame')
          map('n', '<leader>htw', gitsigns.toggle_word_diff, 'Toggle word diff')

          -- Text object
          map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Select hunk')
        end
      }
    end,
  },
  {
    "lualine.nvim",
    event = "DeferredUIEnter",
    dep_of = "gitsigns.nvim",
    after = function(_)
      -- local function diff_source()
      --   local gitsigns = vim.b.gitsigns_status_dict
      --   if gitsigns then
      --     return {
      --       added = gitsigns.added,
      --       modified = gitsigns.changed,
      --       removed = gitsigns.removed
      --     }
      --   end
      --   return nil
      -- end

      require("lualine").setup {
        option = {
          theme = "catppuccin",
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "filename",
            newfile_status = true,
            path = 1,
            shorting_target = 24,
            symbols = {
              modified = " ",
              readonly = " ",
              newfile  = " ",
            },
          },
          lualine_c = {
            {
              function()
                local clients = vim.lsp.get_clients()
                local seen = {}
                local names = {}

                for _, client in ipairs(clients) do
                  if client.name ~= "copilot" and client.name ~= "null-ls" and not seen[client.name] then
                    table.insert(names, client.name)
                    seen[client.name] = true
                  end
                end

                if vim.tbl_isempty(names) then
                  return "No LSP"
                end

                return " " .. table.concat(names, ", ")
              end,
              color = function()
                local clients = vim.lsp.get_clients()
                for _, client in ipairs(clients) do
                  if client.name ~= "copilot" and client.name ~= "null-ls" then
                    return { fg = "#a6e3a1" } -- LSPがあるとき：緑
                  end
                end
                return { fg = "#7f849c" } -- LSPなし（またはcopilot/null-lsだけ）：グレー
              end,
            },
            {
              'diagnostics',
              sources = { 'nvim_diagnostic', 'nvim_lsp' },
              sections = { 'error', 'warn', 'info', 'hint' },
              symbols = {
                error = ' ', -- error (U+EA87)
                warn  = ' ', -- warning (U+EA6C)
                info  = ' ', -- info (U+EA74)
                hint  = ' ', -- hint/lightbulb (U+EA61)
              }
            },
            {
              "navic"
            }
          },
          lualine_x = {
            "encoding",
          },
          lualine_y = {
            "filetype",
            "fileformat",
          },
          lualine_z = {
            "progress",
            "location",
          },
        },
        tabline = {
          lualine_a = {
            {
              "buffers",
              symbols = { modified = " ", readonly = " ", unnamed = " ", },
            },
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {
            {
              function()
                local ok, noice = pcall(require, "noice")
                return (ok and noice.api.status.command.get())
                    or ""
              end,
              cond = function()
                local ok, noice = pcall(require, "noice")
                return ok and noice.api.status.command.has()
              end,
              color = { fg = "#eba0ac" },
            },
          },
          lualine_y = {
            {
              "diff",
              symbols = {
                added    = " ",
                modified = " ",
                removed  = " ",
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed
                  }
                end
                return nil
              end,
            },
            {
              'b:gitsigns_head',
              icon = ' ',
              color = { fg = "#fab387" },
            }
          },
          lualine_z = { "tabs" },
        },
      }
    end,
  },
  {
    "neoscroll.nvim",
    event = "DeferredUIEnter",
    after = function(_)
      require('neoscroll').setup({})
    end,
  },
  {
    "nvim-web-devicons",
    after = function(_)
      require("nvim-web-devicons").setup({ variant = "dark" })
    end,
  },
  {
    "nvim-scrollview",
    event = { "BufWinEnter", "WinScrolled", "DeferredUIEnter" },
    after = function(_)
      require('scrollview').setup({})
    end,
  },
  {
    "hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    after = function(_)
      require("hlchunk").setup({
        chunk = {
          enable = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
          },
          style = "#78dce8",
        },
        indent = { enable = true},
        line_num = {
          enable = true,
          use_treesitter = false,
        },
      })
    end,
  },
}
