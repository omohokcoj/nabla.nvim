-- Manager - handles buffer attachment and autocmds

local env = require('nabla.lib.env')
local Updater = require('nabla.core.ui').Updater

local M = {}

---@class nabla.Manager
---@field updaters table<number, nabla.Updater> Updaters per buffer
---@field ns number Namespace
---@field config nabla.Config
---@field render_fn function
---@field autocmd_ids table<number, number[]> Autocmd IDs per buffer
local Manager = {}
Manager.__index = Manager

-- Singleton instance
local instance = nil

---Get or create manager instance
---@param ns number Namespace
---@param config nabla.Config|nil
---@param render_fn function
---@return nabla.Manager
function Manager.get(ns, config, render_fn)
  if not instance then
    instance = setmetatable({}, Manager)
    instance.updaters = {}
    instance.ns = ns
    instance.config = config or {}
    instance.render_fn = render_fn
    instance.autocmd_ids = {}
  end
  return instance
end

---Reset manager (for testing)
function Manager.reset()
  if instance then
    for buf, _ in pairs(instance.updaters) do
      instance:detach(buf)
    end
  end
  instance = nil
end

---Attach to buffer
---@param buf number
function Manager:attach(buf)
  if self.updaters[buf] then
    return -- Already attached
  end
  
  self.updaters[buf] = Updater.new(buf, self.ns, self.config, self.render_fn)
  self:register_autocmds(buf)
end

---Detach from buffer
---@param buf number
function Manager:detach(buf)
  local updater = self.updaters[buf]
  if updater then
    updater:destroy()
    self.updaters[buf] = nil
  end
  
  -- Remove autocmds
  local ids = self.autocmd_ids[buf]
  if ids then
    for _, id in ipairs(ids) do
      pcall(vim.api.nvim_del_autocmd, id)
    end
    self.autocmd_ids[buf] = nil
  end
end

---Register autocmds for buffer
---@param buf number
function Manager:register_autocmds(buf)
  local ids = {}
  
  local function schedule(force)
    local updater = self.updaters[buf]
    if updater then
      updater:schedule(force)
    end
  end
  
  -- Buffer/window events that need re-render
  ids[#ids + 1] = vim.api.nvim_create_autocmd({'BufWinEnter'}, {
    buffer = buf,
    callback = function()
      schedule(true)
    end,
    desc = 'nabla.nvim: render on window enter',
  })
  
  -- Text changes need re-parse
  ids[#ids + 1] = vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
    buffer = buf,
    callback = function()
      schedule(true)
    end,
    desc = 'nabla.nvim: re-parse on text change',
  })
  
  -- Cursor movement just needs display update (anti-conceal)
  ids[#ids + 1] = vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
    buffer = buf,
    callback = function()
      schedule(false)
    end,
    desc = 'nabla.nvim: update display on cursor move',
  })
  
  -- Scroll events may need re-parse for new viewport
  ids[#ids + 1] = vim.api.nvim_create_autocmd({'WinScrolled'}, {
    buffer = buf,
    callback = function()
      schedule(false)
    end,
    desc = 'nabla.nvim: update on scroll',
  })
  
  -- Cleanup on buffer delete
  ids[#ids + 1] = vim.api.nvim_create_autocmd({'BufDelete', 'BufWipeout'}, {
    buffer = buf,
    callback = function()
      self:detach(buf)
    end,
    desc = 'nabla.nvim: cleanup on buffer delete',
  })
  
  self.autocmd_ids[buf] = ids
end

---Get updater for buffer
---@param buf number
---@return nabla.Updater|nil
function Manager:get_updater(buf)
  return self.updaters[buf]
end

---Check if buffer is attached
---@param buf number
---@return boolean
function Manager:is_attached(buf)
  return self.updaters[buf] ~= nil
end

---Force update for buffer
---@param buf number
function Manager:update(buf)
  local updater = self.updaters[buf]
  if updater then
    updater:schedule(true)
  end
end

M.Manager = Manager

return M
