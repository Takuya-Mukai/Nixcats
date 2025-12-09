local function inspect_captures(target_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, "python")
  parser:parse(true)
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = vim.treesitter.query.get(vim.bo.filetype, "highlights")
  if not query then
    print("NO QUERY FOUND")
    return
  end
  
  -- Print Node Type at target line
  local cursor_node = root:named_descendant_for_range(target_line, 0, target_line, 1)
  if cursor_node then
      print("Node at line " .. target_line .. ": " .. cursor_node:type())
      local parent = cursor_node:parent()
      while parent do
          print("  Parent: " .. parent:type() .. " Range: " .. table.concat({parent:range()}, ":"))
          parent = parent:parent()
      end
  end
  
  print("\n=== Captures for line " .. target_line .. " ===")
  local found_any = false
  for id, node, metadata in query:iter_captures(root, bufnr, target_line, target_line + 1) do
      local name = query.captures[id]
      local r, c, er, ec = node:range()
      local text = vim.treesitter.get_node_text(node, bufnr)
      print(string.format("[%s] @%s  (Range: %d:%d - %d:%d) Text: '%s'", 
          name, name, r, c, er, ec, text))
      found_any = true
  end
  
  if not found_any then
      print("  (No captures found on this line)")
  end
end

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
  print("--- DEBUGGING HIGHLIGHT GROUPS ---")
  local hl_id = vim.api.nvim_get_hl_id_by_name("Macro")
  print("HL ID for Macro: " .. hl_id)
  if hl_id == 0 then print("WARNING: Macro highlight group not defined") end

  -- 2. Test Magic Command
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { "!ls -la", "s = 'ls -la'" })
  local last_line = vim.api.nvim_buf_line_count(0) - 1
  print("\nChecking Magic Command Line (Line " .. last_line .. "):")
  
  -- Force updated parse
  local parser = vim.treesitter.get_parser(0, "python")
  parser:parse(true)
  
  -- Check if bash parser is available
  local has_bash = pcall(vim.treesitter.get_parser, 0, "bash")
  print("Is bash parser available? " .. tostring(has_bash))
  
  print("--- DEBUGGING INJECTIONS ---")
  inspect_injections()
  
  -- inspect_captures(last_line)
  
  vim.cmd("qa!")
end, 1000)
