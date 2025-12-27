-- Extmark management with show/hide caching pattern
-- Avoids recreating extmarks on cursor movement

local M = {}

---@class nabla.Extmark
---@field id number|nil Extmark ID when visible
---@field row number 0-indexed row
---@field col number 0-indexed column
---@field opts table Extmark options
---@field conceal boolean|string Whether this mark should be hidden near cursor
local Extmark = {}
Extmark.__index = Extmark

---Create new extmark definition (not yet placed)
---@param row number
---@param col number
---@param opts table
---@param conceal boolean|string|nil
---@return nabla.Extmark
function Extmark.new(row, col, opts, conceal)
  local self = setmetatable({}, Extmark)
  self.id = nil
  self.row = row
  self.col = col
  self.opts = opts
  self.conceal = conceal ~= nil and conceal or false
  return self
end

---Show extmark (place it in buffer if not already visible)
---@param ns number Namespace
---@param buf number Buffer
function Extmark:show(ns, buf)
  if self.id then
    return -- Already visible
  end
  local ok, id = pcall(
    vim.api.nvim_buf_set_extmark,
    buf, ns,
    self.row,
    self.col,
    self.opts
  )
  if ok then
    self.id = id
  end
end

---Hide extmark (remove from buffer but keep definition)
---@param ns number Namespace
---@param buf number Buffer
function Extmark:hide(ns, buf)
  if not self.id then
    return -- Already hidden
  end
  pcall(vim.api.nvim_buf_del_extmark, buf, ns, self.id)
  self.id = nil
end

---Check if extmark overlaps with a row range
---@param range number[]|nil {start_row, end_row}
---@return boolean
function Extmark:overlaps(range)
  if not range then
    return false
  end
  return self.row >= range[1] and self.row <= range[2]
end

---Get end row of extmark
---@return number
function Extmark:end_row()
  return self.opts.end_row or self.row
end

M.Extmark = Extmark

---@class nabla.ExtmarkStore
---@field marks nabla.Extmark[]
---@field ns number Namespace
local ExtmarkStore = {}
ExtmarkStore.__index = ExtmarkStore

---Create new extmark store
---@param ns number Namespace
---@return nabla.ExtmarkStore
function ExtmarkStore.new(ns)
  local self = setmetatable({}, ExtmarkStore)
  self.marks = {}
  self.ns = ns
  return self
end

---Clear all marks from buffer and store
---@param buf number
function ExtmarkStore:clear(buf)
  vim.api.nvim_buf_clear_namespace(buf, self.ns, 0, -1)
  self.marks = {}
end

---Add mark to store
---@param mark nabla.Extmark
function ExtmarkStore:add(mark)
  self.marks[#self.marks + 1] = mark
end

---Set all marks (replaces existing)
---@param marks nabla.Extmark[]
function ExtmarkStore:set(marks)
  self.marks = marks
end

---Update visibility of all marks based on hidden range
---@param buf number
---@param hidden number[]|nil Range to hide {start_row, end_row}
function ExtmarkStore:display(buf, hidden)
  for _, mark in ipairs(self.marks) do
    local should_hide = false
    if hidden and mark:overlaps(hidden) then
      if type(mark.conceal) == 'boolean' then
        should_hide = mark.conceal
      else
        should_hide = true
      end
    end
    
    if should_hide then
      mark:hide(self.ns, buf)
    else
      mark:show(self.ns, buf)
    end
  end
end

---Get all marks in a row range
---@param start_row number
---@param end_row number
---@return nabla.Extmark[]
function ExtmarkStore:in_range(start_row, end_row)
  local result = {}
  for _, mark in ipairs(self.marks) do
    if mark.row >= start_row and mark.row <= end_row then
      result[#result + 1] = mark
    end
  end
  return result
end

M.ExtmarkStore = ExtmarkStore

return M
