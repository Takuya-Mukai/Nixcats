require("lze").load({
  {
    "copilot.lua",
    after = function()
      require("copilot").setup({ panel = { enabled = false }, suggestion = { enabled = false } })
    end,
    event = { "InsertEnter", "CmdlineEnter" },
  },
})
