-- Environment utilities for nabla.nvim
-- Handles viewport detection, window/buffer queries, and visibility checks

local M = {}

---@class nabla.Env
M.buf = {}
M.win = {}
M.row = {}

---Get all windows displaying a buffer
---@param buf number
---@return number[]
function M.buf.wins(buf)
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      wins[#wins + 1] = win
    end
  end
  return wins
end

---Get buffer line count
---@param buf number
---@return number
function M.buf.line_count(buf)
  return vim.api.nvim_buf_line_count(buf)
end

---Get buffer changedtick
---@param buf number
---@return number
function M.buf.changedtick(buf)
  return vim.api.nvim_buf_get_changedtick(buf)
end

---Check if buffer is valid
---@param buf number
---@return boolean
function M.buf.valid(buf)
  return vim.api.nvim_buf_is_valid(buf)
end

---Get window view info (topline, etc)
---@param win number
---@return table
function M.win.view(win)
  return vim.api.nvim_win_call(win, function()
    return vim.fn.winsaveview()
  end)
end

---Get window height
---@param win number
---@return number
function M.win.height(win)
  return vim.api.nvim_win_get_height(win)
end

---Check if window is valid
---@param win number
---@return boolean
function M.win.valid(win)
  return vim.api.nvim_win_is_valid(win)
end

---Get current window
---@return number
function M.win.current()
  return vim.api.nvim_get_current_win()
end

---Check if a row is visible in window (not folded)
---@param win number
---@param row number 0-indexed
---@return boolean
function M.row.visible(win, row)
  return vim.api.nvim_win_call(win, function()
    return vim.fn.foldclosed(row + 1) == -1
  end)
end

---Get cursor row for buffer/window
---@param buf number
---@param win number
---@return number|nil 0-indexed row
function M.row.get(buf, win)
  if vim.api.nvim_win_get_buf(win) ~= buf then
    return nil
  end
  return vim.api.nvim_win_get_cursor(win)[1] - 1
end

---Calculate visible range for a window with offset buffer
---@param buf number
---@param win number
---@param offset number Lines to buffer above/below viewport
---@return number[] {top, bottom} 0-indexed
function M.range(buf, win, offset)
  offset = offset or 10
  local view = M.win.view(win)
  local top = math.max(view.topline - 1 - offset, 0)
  local bottom = top
  local lines = M.buf.line_count(buf)
  local size = M.win.height(win) + (2 * offset)
  
  while bottom < lines and size > 0 do
    bottom = bottom + 1
    if M.row.visible(win, bottom) then
      size = size - 1
    end
  end
  
  return { top, bottom }
end

M.mode = {}

---Get current mode
---@return string
function M.mode.get()
  return vim.api.nvim_get_mode().mode
end

---Check if current mode is in allowed list
---@param mode string
---@param allowed string|string[]
---@return boolean
function M.mode.is(mode, allowed)
  if type(allowed) == 'string' then
    return mode:sub(1, 1) == allowed:sub(1, 1)
  end
  for _, m in ipairs(allowed) do
    if mode:sub(1, 1) == m:sub(1, 1) then
      return true
    end
  end
  return false
end

return M
