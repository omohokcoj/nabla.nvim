-- UI updater with two-phase rendering (parse + display)

local env = require('nabla.lib.env')
local Context = require('nabla.core.context').Context
local Decorator = require('nabla.lib.decorator').Decorator
local Extmark = require('nabla.lib.extmark').Extmark

local M = {}

---@class nabla.Config
---@field debounce number Debounce milliseconds
---@field anti_conceal nabla.AntiConcealConfig
local default_config = {
  debounce = 100,
  anti_conceal = {
    enabled = true,
    above = 0,
    below = 0,
  },
}

---@class nabla.AntiConcealConfig
---@field enabled boolean
---@field above number Lines above cursor to reveal
---@field below number Lines below cursor to reveal

---@class nabla.Updater
---@field buf number Buffer handle
---@field win number Window handle
---@field decorator nabla.Decorator
---@field config nabla.Config
---@field force boolean Force re-parse
---@field render_fn function Render function
local Updater = {}
Updater.__index = Updater

---Create new updater
---@param buf number
---@param ns number
---@param config nabla.Config|nil
---@param render_fn function
---@return nabla.Updater
function Updater.new(buf, ns, config, render_fn)
  local self = setmetatable({}, Updater)
  self.buf = buf
  self.win = env.win.current()
  self.decorator = Decorator.new(buf, ns)
  self.config = vim.tbl_deep_extend('force', default_config, config or {})
  self.force = false
  self.render_fn = render_fn
  return self
end

---Check if update is needed (content changed or new viewport area)
---@return boolean
function Updater:changed()
  if self.force or self.decorator:changed() then
    return true
  end
  -- Check if current visible area is within what we've already rendered
  return not self.decorator:viewport_contained(self.win)
end

---Calculate hidden range for anti-conceal
---@return number[]|nil {start_row, end_row}
function Updater:hidden()
  local config = self.config.anti_conceal
  if not config.enabled then
    return nil
  end
  
  local row = env.row.get(self.buf, self.win)
  if not row then
    return nil
  end
  
  return { row - config.above, row + config.below }
end

---Perform two-phase render
function Updater:render()
  if self:changed() then
    -- Phase 1: Parse and create extmarks
    self:parse(function(marks, range)
      self.decorator:clear()
      self.decorator:set_marks(marks)
      self.decorator:mark_processed(range)
      -- Phase 2: Display with anti-conceal
      self:display()
    end)
    self.force = false
  else
    -- Skip parse, just update visibility
    self:display()
  end
end

---Parse phase - calls render function
---@param callback fun(marks: nabla.Extmark[], range: number[])
function Updater:parse(callback)
  local ctx = Context.get(self.buf, self.win)
  local range = ctx:get_range()
  
  -- Call the actual rendering function
  local marks = self.render_fn(self.buf, range[1], range[2], ctx)
  callback(marks or {}, range)
end

---Display phase - toggle visibility based on cursor
function Updater:display()
  local hidden = self:hidden()
  self.decorator:display(hidden)
end

---Schedule update with debouncing
---@param force boolean|nil
function Updater:schedule(force)
  self.force = force or false
  self.win = env.win.current()
  
  -- Only debounce when content has changed (buffer modified or new viewport)
  -- If viewport is already rendered, no debounce needed (instant display update)
  local needs_reparse = self:changed()
  
  self.decorator:schedule(
    needs_reparse,
    self.config.debounce,
    function()
      if env.buf.valid(self.buf) then
        self:render()
      end
    end
  )
end

---Cleanup
function Updater:destroy()
  self.decorator:stop()
  self.decorator:clear()
  Context.clear(self.buf)
end

M.Updater = Updater
M.Extmark = Extmark

return M
