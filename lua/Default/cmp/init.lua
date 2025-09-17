require("lze").load({
  {
    "blink-cmp-copilot",
    dep_of = "copilot.lua",
  },
  {
    "blink.cmp",
    dep_of = { "blink-cmp-spell", "blink-cmp-git", "blink-cmp-copilot", "lspkind.nvim", "LuaSnip", "blink-cmp-rg", },
    event = { "InsertEnter", "CmdlineEnter" },
    after = function()
      require("blink-cmp").setup({
        appearance = {
          kind_icons = {
            Class = "󱡠",
            Color = "󰏘",
            Constant = "󰏿",
            Constructor = "󰒓",
            Copilot = "",
            Enum = "󰦨",
            EnumMember = "󰦨",
            Event = "󱐋",
            Field = "󰜢",
            File = "󰈔",
            Folder = "󰉋",
            Function = "󰊕",
            Interface = "󱡠",
            Keyword = "󰻾",
            Method = "󰊕",
            Module = "󰅩",
            Operator = "󰪚",
            Property = "󰖷",
            Reference = "󰬲",
            Snippet = "󱄽",
            Struct = "󱡠",
            Text = "󰉿",
            TypeParameter = "󰬛",
            Unit = "󰪚",
            Value = "󰦨",
            Variable = "󰆦",
          },
        },
        cmdline = { completion = { menu = { auto_show = true } }, keymap = { preset = "inherit" } },
        completion = {
          documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },
          ghost_text = { enabled = true, show_with_menu = true },
          menu = { auto_show = true, border = "rounded",
            draw = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  return require('lspkind').symbolic(ctx.kind, { mode = 'symbol',})
                end,
              }
            },
          },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        signature = { window = { border = "rounded" } },
        sources = {
          default = { "lsp", "buffer", "snippets", "path", "copilot", "git" },
          per_filetype = { markdown = { "snippets", "lsp", "path" } },
          providers = {
            copilot = {
              async = true,
              module = "blink-cmp-copilot",
              name = "copilot",
              score_offset = 100,
              transform_items = function(_, items)
                local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                local kind_idx = #CompletionItemKind + 1
                CompletionItemKind[kind_idx] = "Copilot"
                for _, item in ipairs(items) do
                    item.kind = kind_idx
                end
                return items
              end,
            },
            snippets = { preset = 'luasnip' },
            spell = {
              name = 'Spell',
              module = 'blink-cmp-spell',
              opts = {
                -- EXAMPLE: Only enable source in `@spell` captures, and disable it
                -- in `@nospell` captures.
                enable_in_context = function()
                  local curpos = vim.api.nvim_win_get_cursor(0)
                  local captures = vim.treesitter.get_captures_at_pos(
                    0,
                    curpos[1] - 1,
                    curpos[2] - 1
                  )
                  local in_spell_capture = false
                  for _, cap in ipairs(captures) do
                    if cap.capture == 'spell' then
                      in_spell_capture = true
                    elseif cap.capture == 'nospell' then
                      return false
                    end
                  end
                  return in_spell_capture
                end,
              },
            },
            git = {
              enabled = function()
                return vim.tbl_contains({ 'octo', 'gitcommit', 'markdown' }, vim.bo.filetype)
              end,
              module = "blink-cmp-git",
              name = "Git",
              score_offset = 100,
            },
            ripgrep = {
              module = "blink-cmp-rg",
              name = "Ripgrep",
              -- options below are optional, these are the default values
              ---@type blink-cmp-rg.Options
              opts = {
                -- `min_keyword_length` only determines whether to show completion items in the menu,
                -- not whether to trigger a search. And we only has one chance to search.
                prefix_min_len = 3,
                get_command = function(context, prefix)
                  return {
                    "rg",
                    "--no-config",
                    "--json",
                    "--word-regexp",
                    "--ignore-case",
                    "--",
                    prefix .. "[\\w_-]+",
                    vim.fs.root(0, ".git") or vim.fn.getcwd(),
                  }
                end,
                get_prefix = function(context)
                  return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
                end,
              },
            },
          },
          fuzzy = {
            sorts = {
              function(a, b)
                local sort = require('blink.cmp.fuzzy.sort')
                if a.source_id == 'spell' and b.source_id == 'spell' then
                  return sort.label(a, b)
                end
              end,
              'score',
              'sort_text',
              'label',
            },
          },
        },
      })
    end,
  },
  {
    "copilot.lua",
    after = function()
      require("copilot").setup({ panel = { enabled = false }, suggestion = { enabled = false } })
    end,
    event = { "InsertEnter", "CmdlineEnter" },
  },
})
