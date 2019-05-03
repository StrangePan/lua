local class = require "me.strangepan.libs.lua.v1.class"

local Queue = class.build()

function Queue:_init()
  self:clear()
end

function Queue:push(object)
  local new = {
    value = object,
    next = nil
  }
  if self.front == nil then
    self.front = new
  end
  if self.back ~= nil then
    self.back.next = new
  end
  self.back = new
  self.size = self.size + 1
end

--
-- Pops n items from queue, returns the n-th one. n defaults to 1. If n is
-- greater than queue size, will return `nil` regardless of number of items
-- popped.
--
function Queue:pop(n)
  n = n or 1

  local obj
  while n > 0 do
    n = n - 1
    if self.front == nil then
      return nil
    end
    obj = self.front.value

    if self.back == self.front then
      self.back = nil
    end
    self.front = self.front.next
    self.size = self.size - 1
  end

  return obj
end

--
-- Peeks the n-th item and returns it. n defaults to 1. If n is greater than
-- queue size, will return `nil` regardless of number of items peeked.
--
function Queue:peek(n)
  n = n or 1

  local node = self.front
  while n > 1 and node do
    n = n - 1
    node = node.next
  end

  return node and node.value
end

function Queue:empty()
  return self.size == 0
end

function Queue:clear()
  self.front = nil
  self.back = nil
  self.size = 0
end

--
-- Iterator function for stepping through items in queue. Pop operations should
-- not be performed when iterating through the queue.
--
function Queue:items()
  local node = self.front
  local i = 0
  return function()
    local value = node and node.value
    node = node and node.next
    i = value and i + 1
    return i,value
  end
end

return Queue
