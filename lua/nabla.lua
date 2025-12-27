-- Efficient LaTeX rendering for Neovim using virtual text
-- Architecture inspired by render-markdown.nvim:
-- - Viewport-based parsing (only parse visible content)
-- - Extmark caching with show/hide pattern
-- - Debounced updates
-- - Anti-conceal for cursor proximity

local parser = require("nabla.latex")
local ascii = require("nabla.ascii")
local ts_utils = vim.treesitter
local utils = require("nabla.utils")
local Manager = require("nabla.core.manager").Manager
local Extmark = require("nabla.core.ui").Extmark

-- Module state
local M = {}
local ns_id = vim.api.nvim_create_namespace("nabla.nvim")
local manager = nil
local saved_conceallevel = {}
local saved_concealcursor = {}

-- Configuration
local config = {
  debounce = 100,
  anti_conceal = {
    enabled = true,
    above = 0,
    below = 0,
  },
}

---Setup nabla with optional configuration
---@param opts table|nil
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
end

-- Colorize virtual text based on AST node type
local function colorize_virt(g, virt_lines, first_dx, dx, dy)
  if g.t == "num" then
    local off = dy == 0 and first_dx or dx
    for i = 1, g.w do
      if virt_lines[dy + 1] and virt_lines[dy + 1][off + i] then
        virt_lines[dy + 1][off + i][2] = "@number"
      end
    end
  end

  if g.t == "sym" then
    local off = dy == 0 and first_dx or dx
    if g.content and g.content[1] and string.match(g.content[1], "^%a") then
      for i = 1, g.w do
        if virt_lines[dy + 1] and virt_lines[dy + 1][off + i] then
          virt_lines[dy + 1][off + i][2] = "@string"
        end
      end
    elseif g.content and g.content[1] and string.match(g.content[1], "^%d") then
      for i = 1, g.w do
        if virt_lines[dy + 1] and virt_lines[dy + 1][off + i] then
          virt_lines[dy + 1][off + i][2] = "@number"
        end
      end
    else
      for y = 1, g.h do
        local off2 = (y + dy == 1) and first_dx or dx
        for i = 1, g.w do
          if virt_lines[dy + y] and virt_lines[dy + y][off2 + i] then
            virt_lines[dy + y][off2 + i][2] = "@operator"
          end
        end
      end
    end
  end

  if g.t == "op" or g.t == "par" then
    for y = 1, g.h do
      local off = (y + dy == 1) and first_dx or dx
      for i = 1, g.w do
        if virt_lines[dy + y] and virt_lines[dy + y][off + i] then
          virt_lines[dy + y][off + i][2] = "@operator"
        end
      end
    end
  end

  if g.t == "var" then
    local off = dy == 0 and first_dx or dx
    for i = 1, g.w do
      if virt_lines[dy + 1] and virt_lines[dy + 1][off + i] then
        virt_lines[dy + 1][off + i][2] = "@string"
      end
    end
  end

  for _, child in ipairs(g.children or {}) do
    colorize_virt(child[1], virt_lines, child[2] + first_dx, child[2] + dx, child[3] + dy)
  end
end

-- Parse a single formula and generate ASCII representation
local function parse_formula(text)
  local line = text:gsub("%$", "")
  line = line:gsub("\\%[", "")
  line = line:gsub("\\%]", "")
  line = line:gsub("^\\%(", "")
  line = line:gsub("\\%)$", "")
  line = vim.trim(line)

  if line == "" then
    return nil, nil
  end

  local success, exp = pcall(parser.parse_all, line)
  if not success or not exp then
    return nil, nil
  end

  local succ, g = pcall(ascii.to_ascii, { exp }, 1)
  if not succ or not g or g == "" then
    return nil, nil
  end

  local drawing = {}
  for row in vim.gsplit(tostring(g), "\n") do
    table.insert(drawing, row)
  end

  return drawing, g
end

-- Convert drawing to virtual text format with colorization
local function drawing_to_virt(drawing, g)
  local drawing_virt = {}
  for j = 1, #drawing do
    local len = vim.str_utfindex(drawing[j])
    local new_virt_line = {}
    for i = 1, len do
      local a = vim.str_byteindex(drawing[j], i - 1)
      local b = vim.str_byteindex(drawing[j], i)
      local c = drawing[j]:sub(a + 1, b)
      table.insert(new_virt_line, { c, "Normal" })
    end
    table.insert(drawing_virt, new_virt_line)
  end
  colorize_virt(g, drawing_virt, 0, 0, 0)
  return drawing_virt
end

-- Main render function called by the updater
-- Returns extmark definitions for viewport
local function render_formulas(buf, top, bottom, ctx)
  local marks = {}
  local formula_nodes = utils.get_mathzones_in_range(buf, top, bottom)

  -- Track visual offset per row caused by concealed formulas
  -- Key: row number, Value: cumulative offset (positive = chars saved)
  local row_offsets = {}
  
  -- Collect all virtual lines per row (to combine multiple formulas on same row)
  -- Key: row number, Value: { above = {lines...}, below = {lines...} }
  local row_virt_lines = {}

  for _, node in ipairs(formula_nodes) do
    local srow, scol, erow, ecol = ts_utils.get_node_range(node)

    -- Skip if outside viewport
    if srow > bottom or erow < top then
      goto continue
    end

    local succ, texts = pcall(vim.api.nvim_buf_get_text, buf, srow, scol, erow, ecol, {})
    if not succ then
      goto continue
    end

    local text = table.concat(texts, " ")
    local drawing, g = parse_formula(text)
    if not drawing or not g then
      goto continue
    end

    local drawing_virt = drawing_to_virt(drawing, g)
    
    -- Use grid width for the rendered formula width
    local inline_width = g.w

    -- Original source width
    local source_width = ecol - scol
    
    -- Calculate visual column accounting for previous formulas on this row
    local prev_offset = row_offsets[srow] or 0
    local visual_col = scol - prev_offset
    
    -- Update offset for next formula on this row
    -- Offset increases by (source_width - rendered_width)
    row_offsets[srow] = prev_offset + (source_width - inline_width)

    -- Find the longest line for conceal placement
    local concealline = srow
    local longest = -1
    for r = 1, erow - srow + 1 do
      local p1, p2
      if srow == erow then
        p1, p2 = scol, ecol
      elseif r == 1 then
        p1 = scol
        p2 = #(vim.api.nvim_buf_get_lines(buf, srow, srow + 1, true)[1] or "")
      elseif r == #drawing_virt then
        p1, p2 = 0, ecol
      else
        p1 = 0
        p2 = #(vim.api.nvim_buf_get_lines(buf, srow + (r - 1), srow + r, true)[1] or "")
      end
      if p2 - p1 > longest then
        concealline = srow + (r - 1)
        longest = p2 - p1
      end
    end

    -- Initialize row_virt_lines for this concealline if needed
    if not row_virt_lines[concealline] then
      row_virt_lines[concealline] = { above = {}, below = {} }
    end

    -- Collect virtual lines above and below
    for r, virt_line in ipairs(drawing_virt) do
      -- relrow: negative = above inline, 0 = inline, positive = below inline
      local relrow = r - g.my - 1

      local p1, p2
      if srow == erow then
        p1, p2 = scol, ecol
      elseif r == 1 then
        p1 = scol
        p2 = #(vim.api.nvim_buf_get_lines(buf, srow, srow + 1, true)[1] or "")
      elseif r == #drawing_virt then
        p1, p2 = 0, ecol
      else
        p1 = 0
        p2 = #(vim.api.nvim_buf_get_lines(buf, srow + (r - 1), srow + r, true)[1] or "")
      end

      if relrow == 0 then
        -- Inline replacement
        local chunks = {}
        local margin_left = 0
        local margin_right = p2 - #virt_line - p1

        for _ = 1, margin_left do
          table.insert(chunks, { " ", "NonText" })
        end
        vim.list_extend(chunks, virt_line)
        for _ = 1, math.max(0, margin_right) do
          table.insert(chunks, { "", "NonText" })
        end

        -- Create conceal extmarks for each character
        for j, chunk in ipairs(chunks) do
          local c, hl_group = unpack(chunk)
          if p1 + j <= p2 then
            local mark = Extmark.new(concealline, p1 + j - 1, {
              end_row = concealline,
              end_col = p1 + j,
              conceal = c,
              hl_group = hl_group,
              strict = false,
            }, true) -- conceal = true for anti-conceal
            marks[#marks + 1] = mark
          elseif c ~= "" then
            -- Overflow - add as inline virtual text
            local overflow = {}
            for k = j, #chunks do
              if chunks[k][1] ~= "" then
                table.insert(overflow, chunks[k])
              end
            end
            if #overflow > 0 then
              local mark = Extmark.new(concealline, p2, {
                virt_text = overflow,
                virt_text_pos = "inline",
              }, true)
              marks[#marks + 1] = mark
            end
            break
          end
        end
      elseif relrow < 0 then
        -- Virtual line above - add padding for alignment
        local padded_line = {}
        for _ = 1, visual_col do
          table.insert(padded_line, { " ", "Normal" })
        end
        vim.list_extend(padded_line, virt_line)
        
        -- Merge into existing line at this position or add new
        local above_idx = -relrow  -- Convert to positive index (1 = closest to anchor)
        local existing = row_virt_lines[concealline].above[above_idx]
        if existing then
          -- Extend the existing line with padding and new content
          local pad_needed = visual_col - #existing
          for _ = 1, pad_needed do
            table.insert(existing, { " ", "Normal" })
          end
          vim.list_extend(existing, virt_line)
        else
          row_virt_lines[concealline].above[above_idx] = padded_line
        end
      else
        -- Virtual line below - add padding for alignment
        local padded_line = {}
        for _ = 1, visual_col do
          table.insert(padded_line, { " ", "Normal" })
        end
        vim.list_extend(padded_line, virt_line)
        
        -- Merge into existing line at this position or add new
        local existing = row_virt_lines[concealline].below[relrow]
        if existing then
          local pad_needed = visual_col - #existing
          for _ = 1, pad_needed do
            table.insert(existing, { " ", "Normal" })
          end
          vim.list_extend(existing, virt_line)
        else
          row_virt_lines[concealline].below[relrow] = padded_line
        end
      end
    end

    -- Conceal other lines of multi-line formulas
    for r = 1, erow - srow + 1 do
      local row = srow + (r - 1)
      if row ~= concealline then
        local p1, p2
        if srow == erow then
          p1, p2 = scol, ecol
        elseif r == 1 then
          p1 = scol
          p2 = #(vim.api.nvim_buf_get_lines(buf, srow, srow + 1, true)[1] or "")
        elseif r == #drawing_virt then
          p1, p2 = 0, ecol
        else
          p1 = 0
          p2 = #(vim.api.nvim_buf_get_lines(buf, row, row + 1, true)[1] or "")
        end

        for j = 1, p2 - p1 do
          local mark = Extmark.new(row, p1 + j - 1, {
            end_row = row,
            end_col = p1 + j,
            conceal = " ",
            strict = false,
          }, true)
          marks[#marks + 1] = mark
        end
      end
    end

    ::continue::
  end

  -- Create virtual line extmarks from collected row_virt_lines
  for row, vlines in pairs(row_virt_lines) do
    -- Process above lines (need to reverse: index 1 is closest to anchor, but we want furthest first)
    if next(vlines.above) then
      local above_list = {}
      -- Find max index
      local max_idx = 0
      for idx, _ in pairs(vlines.above) do
        if idx > max_idx then max_idx = idx end
      end
      -- Build list from furthest to closest
      for i = max_idx, 1, -1 do
        if vlines.above[i] then
          table.insert(above_list, vlines.above[i])
        end
      end
      if #above_list > 0 then
        local mark = Extmark.new(row, 0, {
          virt_lines = above_list,
          virt_lines_above = true,
        }, false)
        marks[#marks + 1] = mark
      end
    end
    
    -- Process below lines
    if next(vlines.below) then
      local below_list = {}
      -- Find max index
      local max_idx = 0
      for idx, _ in pairs(vlines.below) do
        if idx > max_idx then max_idx = idx end
      end
      -- Build list in order
      for i = 1, max_idx do
        if vlines.below[i] then
          table.insert(below_list, vlines.below[i])
        end
      end
      if #below_list > 0 then
        local mark = Extmark.new(row, 0, {
          virt_lines = below_list,
          virt_lines_above = false,
        }, false)
        marks[#marks + 1] = mark
      end
    end
  end

  return marks
end

-- Enable virtual text rendering for current buffer
function M.enable_virt(opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  -- Initialize manager
  if not manager then
    manager = Manager.get(ns_id, config, render_formulas)
  end

  -- Attach to buffer
  manager:attach(buf)

  -- Save and set conceal settings
  saved_conceallevel[win] = vim.wo[win].conceallevel
  saved_concealcursor[win] = vim.wo[win].concealcursor
  vim.wo[win].conceallevel = 2
  vim.wo[win].concealcursor = ""

  -- Trigger initial render
  manager:update(buf)
end

-- Disable virtual text rendering for current buffer
function M.disable_virt()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  if manager then
    manager:detach(buf)
  end

  -- Restore conceal settings
  if saved_conceallevel[win] then
    vim.wo[win].conceallevel = saved_conceallevel[win]
  end
  if saved_concealcursor[win] then
    vim.wo[win].concealcursor = saved_concealcursor[win]
  end
end

-- Toggle virtual text rendering
function M.toggle_virt(opts)
  local buf = vim.api.nvim_get_current_buf()
  if manager and manager:is_attached(buf) then
    M.disable_virt()
  else
    M.enable_virt(opts)
  end
end

-- Check if virtual text is enabled
function M.is_virt_enabled(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  return manager and manager:is_attached(buf)
end

-- Legacy colorize function for popup (kept for compatibility)
local function colorize(g, first_dx, dx, dy, ns_id_local, drawing, px, py, buf)
  if g.t == "num" then
    local off = dy == 0 and first_dx or dx
    local sx = vim.str_byteindex(drawing[dy + 1], off)
    local se = vim.str_byteindex(drawing[dy + 1], off + g.w)
    local of = dy == 0 and px or 0
    vim.api.nvim_buf_add_highlight(buf, ns_id_local, "@number", py + dy, of + sx, of + se)
  end

  if g.t == "sym" then
    local off = dy == 0 and first_dx or dx
    local sx = vim.str_byteindex(drawing[dy + 1], off)
    local se = vim.str_byteindex(drawing[dy + 1], off + g.w)

    if g.content and g.content[1] and string.match(g.content[1], "^%a") then
      local of = dy == 0 and px or 0
      vim.api.nvim_buf_add_highlight(buf, ns_id_local, "@string", dy + py, of + sx, of + se)
    elseif g.content and g.content[1] and string.match(g.content[1], "^%d") then
      local of = dy == 0 and px or 0
      vim.api.nvim_buf_add_highlight(buf, ns_id_local, "@number", dy + py, of + sx, of + se)
    else
      for y = 1, g.h do
        local off2 = (y + dy == 1) and first_dx or dx
        local sx2 = vim.str_byteindex(drawing[dy + y], off2)
        local se2 = vim.str_byteindex(drawing[dy + y], off2 + g.w)
        local of = (y + dy == 1) and px or 0
        vim.api.nvim_buf_add_highlight(buf, ns_id_local, "@operator", dy + py + y - 1, of + sx2, of + se2)
      end
    end
  end

  if g.t == "op" or g.t == "par" then
    for y = 1, g.h do
      local off = (y + dy == 1) and first_dx or dx
      local sx = vim.str_byteindex(drawing[dy + y], off)
      local se = vim.str_byteindex(drawing[dy + y], off + g.w)
      local of = (dy + y == 1) and px or 0
      vim.api.nvim_buf_add_highlight(buf, ns_id_local, "@operator", dy + py + y - 1, of + sx, of + se)
    end
  end

  if g.t == "var" then
    local off = dy == 0 and first_dx or dx
    local sx = vim.str_byteindex(drawing[dy + 1], off)
    local se = vim.str_byteindex(drawing[dy + 1], off + g.w)
    local of = dy == 0 and px or 0
    vim.api.nvim_buf_add_highlight(buf, ns_id_local, "@string", dy + py, of + sx, of + se)
  end

  for _, child in ipairs(g.children or {}) do
    colorize(child[1], child[2] + first_dx, child[2] + dx, child[3] + dy, ns_id_local, drawing, px, py, buf)
  end
end

-- Generate ASCII drawing from LaTeX lines
local function gen_drawing(lines)
  local text = table.concat(lines, " ")
  local drawing, _ = parse_formula(text)
  return drawing or 0
end

-- Show popup preview for formula at cursor
local function popup(overrides)
  if not utils.in_mathzone() then
    return
  end

  local math_node = utils.in_mathzone()
  local srow, scol, erow, ecol = ts_utils.get_node_range(math_node)

  local lines = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})
  local text = table.concat(lines, " ")
  local drawing, g = parse_formula(text)

  if not drawing or not g then
    return
  end

  local floating_default_options = {
    wrap = false,
    focusable = false,
    border = 'single',
    stylize_markdown = false
  }

  local bufnr_float = vim.lsp.util.open_floating_preview(
    drawing,
    'markdown',
    vim.tbl_deep_extend('force', floating_default_options, overrides or {})
  )

  local popup_ns = vim.api.nvim_create_namespace("")
  colorize(g, 0, 0, 0, popup_ns, drawing, 0, 0, bufnr_float)
end

-- Export module
M.gen_drawing = gen_drawing
M.popup = popup

return M

