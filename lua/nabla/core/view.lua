-- Viewport-based view ranges with coalescing for multi-window support

local env = require('nabla.lib.env')

local M = {}

---@class nabla.View
---@field buf number Buffer handle
---@field ranges number[][] List of {top, bottom} ranges
local View = {}
View.__index = View

---Create view from buffer (coalesces ranges from all windows)
---@param buf number
---@param offset number|nil Lines to buffer (default 10)
---@return nabla.View
function View.new(buf, offset)
  local self = setmetatable({}, View)
  self.buf = buf
  offset = offset or 10
  
  local ranges = {}
  for _, win in ipairs(env.buf.wins(buf)) do
    ranges[#ranges + 1] = env.range(buf, win, offset)
  end
  
  self.ranges = M.coalesce(ranges)
  return self
end

---Check if a node range overlaps with view
---@param start_row number
---@param end_row number
---@return boolean
function View:overlaps(start_row, end_row)
  for _, range in ipairs(self.ranges) do
    if start_row <= range[2] and end_row >= range[1] then
      return true
    end
  end
  return false
end

---Check if a single row is in view
---@param row number
---@return boolean
function View:contains(row)
  return self:overlaps(row, row)
end

---Get combined range (min top, max bottom)
---@return number[] {top, bottom}
function View:combined()
  if #self.ranges == 0 then
    return { 0, 0 }
  end
  local top = self.ranges[1][1]
  local bottom = self.ranges[1][2]
  for i = 2, #self.ranges do
    top = math.min(top, self.ranges[i][1])
    bottom = math.max(bottom, self.ranges[i][2])
  end
  return { top, bottom }
end

---Iterate over visible ranges
---@param callback fun(top: number, bottom: number)
function View:foreach(callback)
  for _, range in ipairs(self.ranges) do
    callback(range[1], range[2])
  end
end

---Coalesce overlapping/adjacent ranges
---@param ranges number[][]
---@return number[][]
function M.coalesce(ranges)
  if #ranges == 0 then
    return {}
  end
  
  -- Sort by start
  table.sort(ranges, function(a, b)
    return a[1] < b[1]
  end)
  
  local result = { { ranges[1][1], ranges[1][2] } }
  
  for i = 2, #ranges do
    local last = result[#result]
    local curr = ranges[i]
    
    -- Check for overlap or adjacency
    if curr[1] <= last[2] + 1 then
      -- Merge
      last[2] = math.max(last[2], curr[2])
    else
      -- New range
      result[#result + 1] = { curr[1], curr[2] }
    end
  end
  
  return result
end

M.View = View

return M
