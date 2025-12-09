local function inspect_injections()
    local bufnr = vim.api.nvim_get_current_buf()
    
    -- Force full parse
    local parser = vim.treesitter.get_parser(bufnr, "python")
    parser:parse(true)
    
    print("\n=== Injected Parsers ===")
    local children = parser:children()
    local count = 0
    for lang, child_parser in pairs(children) do
        count = count + 1
        print("Found parser for language: " .. lang)
        -- Inspect ranges
        for _, tree in ipairs(child_parser:parse()) do
            local root = tree:root()
            local r, c, er, ec = root:range()
            print(string.format("  - Range: %d:%d - %d:%d", r, c, er, ec))
        end
    end
    if count == 0 then
        print("  (No injected parsers found)")
    end
end

vim.defer_fn(function()
  print("--- DEBUGGING INJECTIONS ---")
  inspect_injections()
  
  print("--- DEBUGGING HIGLIGHT GROUPS ---")
  -- Check if Function.Macro is linked
  local hl_id = vim.api.nvim_get_hl_id_by_name("Macro")
  print("HL ID for Macro: " .. hl_id)
  if hl_id == 0 then print("WARNING: Macro highlight group not defined") end
  
  vim.cmd("qa!")
end, 1000)
