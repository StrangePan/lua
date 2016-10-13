require "common/class"

Queue = buildClass()

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

function Queue:pop()
  if self.front == nil then
    return nil
  end
  local obj = self.front.value
  
  if self.back == self.front then
    self.back = nil
  end
  self.front = self.front.next
  self.size = self.size - 1
  
  return obj
end

function Queue:peek()
  if self.font == nil then
    return nil
  end
  return self.front.value
end

function Queue:empty()
  return self.size == 0
end

function Queue:peek()
  if self.front then
    return self.front.value
  end
  return nil
end

function Queue:clear()
  self.front = nil
  self.back = nil
  self.size = 0
end
