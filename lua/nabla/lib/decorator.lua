-- Decorator with debouncing and change tracking
-- Schedules updates efficiently

local env = require('nabla.lib.env')
local extmark = require('nabla.lib.extmark')

local M = {}

---@class nabla.Decorator
---@field buf number Buffer handle
---@field ns number Namespace
---@field store nabla.ExtmarkStore Extmark store
---@field tick number Last processed changedtick
---@field timer uv_timer_t Debounce timer
---@field running boolean Whether debounce is active
---@field rendered_range number[]|nil Last rendered viewport range {top, bottom}
local Decorator = {}
Decorator.__index = Decorator

---Create new decorator for buffer
---@param buf number
---@param ns number
---@return nabla.Decorator
function Decorator.new(buf, ns)
  local self = setmetatable({}, Decorator)
  self.buf = buf
  self.ns = ns
  self.store = extmark.ExtmarkStore.new(ns)
  self.tick = 0
  self.timer = vim.uv.new_timer()
  self.running = false
  self.rendered_range = nil
  return self
end

---Get current changedtick
---@return number
function Decorator:get_tick()
  return env.buf.changedtick(self.buf)
end

---Check if buffer has changed since last update
---@return boolean
function Decorator:changed()
  return self.tick ~= self:get_tick()
end

---Mark buffer as processed with rendered range
---@param range number[]|nil The viewport range that was rendered
function Decorator:mark_processed(range)
  self.tick = self:get_tick()
  self.rendered_range = range
end

---Check if current viewport is contained within rendered range
---Uses exact visible area (no offset) to check against rendered range (which has offset)
---@param win number Window handle
---@return boolean
function Decorator:viewport_contained(win)
  if not self.rendered_range then
    return false
  end
  -- Get exact visible range (offset=0) to check if it's within what we rendered
  local visible = env.range(self.buf, win, 0)
  return visible[1] >= self.rendered_range[1] and visible[2] <= self.rendered_range[2]
end

---Schedule update with debouncing
---Matches render-markdown.nvim pattern: first event fires immediately, 
---subsequent events during debounce window are ignored
---@param debounce boolean Whether to debounce (true if content changed)
---@param ms number Debounce milliseconds
---@param callback function Update callback
function Decorator:schedule(debounce, ms, callback)
  if debounce and ms > 0 then
    -- Start/restart timer - when it fires, debounce window closes
    self.timer:start(ms, 0, function()
      self.running = false
    end)
    -- Only run callback if not already running (first event wins)
    if not self.running then
      self.running = true
      vim.schedule(callback)
    end
  else
    -- No debounce - run immediately
    vim.schedule(callback)
  end
end

---Stop debounce timer
function Decorator:stop()
  if self.timer then
    self.timer:stop()
  end
end

---Clear all extmarks
function Decorator:clear()
  self.store:clear(self.buf)
end

---Set extmarks
---@param marks nabla.Extmark[]
function Decorator:set_marks(marks)
  self.store:set(marks)
end

---Add extmark
---@param mark nabla.Extmark
function Decorator:add_mark(mark)
  self.store:add(mark)
end

---Update display based on cursor position
---@param hidden number[]|nil Range to hide
function Decorator:display(hidden)
  self.store:display(self.buf, hidden)
end

M.Decorator = Decorator

return M
