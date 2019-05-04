local class = require "me.strangepan.libs.lua.v1.class"
local assert_that = require "me.strangepan.libs.lua.truth.v1.assert_that"

local PriorityQueue = class.build()

function PriorityQueue:_init()
  self.items = {}
  self.head = 0 --offset of first item from 1, not index of first item
  self.tail = 1 --index following last item. should always point to nil
  self.size = 0 --number of items
end

function PriorityQueue:push(value, priority)
  assert_that(priority):is_a_number()

  -- binary search to find insertion point
  local left = 1 + self.head
  local right = self.tail
  local mid = left
  while left <= right do
    mid = math.floor((left + right) / 2)
    if left == right
        or not self.items[mid]
        or self.items[mid].p == priority
        or self.items[mid].p > priority
            and (mid == self.head+1
            or self.items[mid-1].p < priority) then
      break
    end
    if self.items[mid].p < priority then
      left = mid + 1
    else
      right = mid - 1
    end
  end
  
  -- insert at mid, make room in rest of list. fuck the table library
  local i = self.tail
  while i > mid do
    self.items[i] = self.items[i-1]
    i = i-1
  end
  self.items[mid] = {
    v = value,
    p = priority,
  }
  self.tail = self.tail + 1
  self.size = self.size + 1
end

function PriorityQueue:pop()
  local ind = self.head + 1
  if not self.items[ind] then
    return
  end

  local item = self.items[ind].v
  self.items[ind] = nil
  self.head = self.head + 1
  self.size = self.size - 1

  if self.size == 0 then
    self.head = 0
    self.tail = 1
  end

  return item
end

function PriorityQueue:print()
  local s = '{'
  if self.size > 0 then
    s = s..self.items[self.head+1].v
    for i = (self.head+2),(self.tail - 1) do
      s = s..', '..self.items[i].v
    end
  end
  s = s..'}'
  print(s)
end

return PriorityQueue
