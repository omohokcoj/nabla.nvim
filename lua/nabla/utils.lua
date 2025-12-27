-- Efficient utilities for nabla.nvim
-- Optimized for viewport-based rendering

local utils = {}

local has_treesitter, ts = pcall(require, "vim.treesitter")
local _, query = pcall(require, "vim.treesitter.query")

local MATH_ENVIRONMENTS = {
  displaymath = true,
  eqnarray = true,
  equation = true,
  math = true,
  array = true,
}

local MATH_NODES = {
  displayed_equation = true,
  inline_formula = true,
}

-- Check if cursor is in a math zone
utils.in_mathzone = function()
  local function get_node_at_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_range = { cursor[1] - 1, cursor[2] }
    local buf = vim.api.nvim_get_current_buf()
    local ft = vim.bo[buf].filetype
    local lang = ft ~= "markdown" and "latex" or "markdown"
    local ok, parser = pcall(ts.get_parser, buf, lang)
    if not ok or not parser then
      return nil
    end
    local root_tree = parser:parse()[1]
    local root = root_tree and root_tree:root()

    if not root then
      return nil
    end

    return root:named_descendant_for_range(
      cursor_range[1],
      cursor_range[2],
      cursor_range[1],
      cursor_range[2]
    )
  end

  if has_treesitter then
    local buf = vim.api.nvim_get_current_buf()
    local node = get_node_at_cursor()
    while node do
      if node:type() == "text" and node:parent() and node:parent():type() == "math_environment" then
        return node
      end
      if MATH_NODES[node:type()] then
        return node
      end
      if node:type() == "environment" then
        local begin_node = node:child(0)
        local names = begin_node and begin_node:field("name")

        if names and names[1] then
          local name_text = query.get_node_text(names[1], buf):gsub("[%s*]", "")
          if MATH_ENVIRONMENTS[name_text] then
            return node
          end
        end
      end
      node = node:parent()
    end
    return false
  end
end

-- Get mathzones in a specific row range (viewport-based)
-- This is the key optimization: only parse visible content
utils.get_mathzones_in_range = function(buf, top, bottom)
  buf = buf or vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local lang = ft ~= "markdown" and "latex" or "markdown"

  local ok, parser = pcall(ts.get_parser, buf, lang)
  if not ok or not parser then
    return {}
  end

  -- Parse only the visible range for efficiency
  local root_tree = parser:parse({ top, bottom })[1]
  local root = root_tree and root_tree:root()

  if not root then
    return {}
  end

  local out = {}

  if ft == "markdown" then
    -- For markdown, find latex blocks in markdown_inline or latex injections
    local seen = {}
    parser:for_each_tree(function(tree, ltree)
      local tree_lang = ltree:lang()
      local tree_root = tree:root()
      
      if tree_lang == "latex" then
        -- Injected latex tree
        local sr, sc, er, ec = ts.get_node_range(tree_root)
        if sr <= bottom and er >= top then
          local key = string.format("%d,%d,%d,%d", sr, sc, er, ec)
          if not seen[key] then
            seen[key] = true
            table.insert(out, tree_root)
          end
        end
      elseif tree_lang == "markdown_inline" then
        -- Find latex_block nodes in markdown_inline
        utils._find_latex_blocks(tree_root, out, seen, top, bottom)
      end
    end)
  else
    -- For latex files, traverse the tree
    utils._collect_mathzones(root, out, buf, top, bottom)
  end

  return out
end

-- Find latex_block nodes in markdown_inline tree
utils._find_latex_blocks = function(node, out, seen, top, bottom)
  local node_type = node:type()
  local sr, sc, er, ec = ts.get_node_range(node)
  
  -- Skip nodes entirely outside viewport
  if sr > bottom then
    return
  end
  
  if er >= top then
    if node_type == "latex_block" then
      local key = string.format("%d,%d,%d,%d", sr, sc, er, ec)
      if not seen[key] then
        seen[key] = true
        table.insert(out, node)
      end
    end
    
    -- Recurse into children
    for child in node:iter_children() do
      utils._find_latex_blocks(child, out, seen, top, bottom)
    end
  end
end

-- Internal helper to collect mathzones recursively
utils._collect_mathzones = function(parent, out, buf, top, bottom)
  for node in parent:iter_children() do
    local sr, _, er, _ = ts.get_node_range(node)

    -- Skip nodes entirely outside viewport
    if sr > bottom then
      break
    end

    if er >= top then
      if node:type() == "text" and node:parent() and node:parent():type() == "math_environment" then
        table.insert(out, node)
      elseif MATH_NODES[node:type()] then
        table.insert(out, node)
      elseif node:type() == "environment" then
        local begin_node = node:child(0)
        local names = begin_node and begin_node:field("name")

        if names and names[1] then
          local name_text = query.get_node_text(names[1], buf):gsub("[%s*]", "")
          if MATH_ENVIRONMENTS[name_text] then
            table.insert(out, node)
          end
        end
      end
      -- Recurse into children
      utils._collect_mathzones(node, out, buf, top, bottom)
    end
  end
end

-- Legacy function for backwards compatibility
utils.get_all_mathzones = function(opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()
  local top = vim.fn.line('w0') - 1
  local bottom = vim.fn.line('w$')

  return utils.get_mathzones_in_range(buf, top, bottom)
end

-- Legacy function for backwards compatibility
utils.get_mathzones_in_node = function(parent, out)
  local buf = vim.api.nvim_get_current_buf()
  utils._collect_mathzones(parent, out, buf, 0, math.huge)
end

return utils

