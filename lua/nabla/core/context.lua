-- Context for rendering - holds viewport, buffer state, and rendering context

local View = require('nabla.core.view').View
local env = require('nabla.lib.env')

local M = {}

---@class nabla.Context
---@field buf number Buffer handle
---@field win number|nil Primary window
---@field view nabla.View Viewport ranges
---@field mode string Current mode
local Context = {}
Context.__index = Context

-- Cache of contexts per buffer
local contexts = {}

---Create new context for buffer
---@param buf number
---@param win number|nil
---@return nabla.Context
function Context.new(buf, win)
  local self = setmetatable({}, Context)
  self.buf = buf
  self.win = win or env.win.current()
  self.view = View.new(buf)
  self.mode = vim.api.nvim_get_mode().mode
  return self
end

---Get or create context for buffer
---@param buf number
---@param win number|nil
---@return nabla.Context
function Context.get(buf, win)
  local key = buf
  if not contexts[key] then
    contexts[key] = Context.new(buf, win)
  else
    -- Update view and mode
    contexts[key].view = View.new(buf)
    contexts[key].mode = vim.api.nvim_get_mode().mode
    if win then
      contexts[key].win = win
    end
  end
  return contexts[key]
end

---Clear context for buffer
---@param buf number
function Context.clear(buf)
  contexts[buf] = nil
end

---Check if current view contains previous view
---@param buf number
---@param win number
---@return boolean
function Context.contains(buf, win)
  local ctx = contexts[buf]
  if not ctx then
    return false
  end
  
  local current_range = env.range(buf, win, 10)
  local cached = ctx.view:combined()
  
  return current_range[1] >= cached[1] and current_range[2] <= cached[2]
end

---Check if node is in visible range
---@param start_row number
---@param end_row number
---@return boolean
function Context:in_view(start_row, end_row)
  return self.view:overlaps(start_row, end_row)
end

---Get visible range as {top, bottom}
---@return number[]
function Context:get_range()
  return self.view:combined()
end

M.Context = Context

return M
