Queue = {}
Queue.__index = Queue
setmetatable(Queue, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})

function Queue:_init()
  self:clear()
end

local comp = function(a, b) return a.p < b.p end

function Queue:push(value, priority)
  self.items[self.tail] = {
    v = value,
  }
  self.tail = self.tail + 1
  self.size = self.size + 1
end

function Queue:pop()
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

function Queue:peek()
  return self.items[self.head+1]
end

function Queue:clear()
  self.items = {}
  self.head = 0 --offset of first item from 1, not index of first item
  self.tail = 1 --index following last item. should always point to nil
  self.size = 0 --number of items
end

function Queue:contents()
  local i = self.head
  return function()
    i = i + 1
    return self.items[i]
  end
end

function Queue:print()
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
