require "strangepan.util.class"

Set = buildClass()

function Set:_init()
  self.contents = {}
  self.num_contents = 0
end

function Set:add(item)
  assertTable(item, "item")
  if not self.contents[item] then
    self.contents[item] = true
    self.num_contents = self.num_contents + 1
  end
end

function Set:remove(item)
  assertTable(item, "item")
  if self.contents[item] then
    self.contents[item] = nil
    self.num_contents = self.num_contents - 1
  end
end

function Set:size()
  return self.num_contents
end

function Set:isEmpty()
  return self:size() == 0
end

function Set:clear()
  self.contents = {}
  self.num_contents = 0
end

function Set:each()
  local f = pairs(self.contents)
  return function()
    local k = f()
    return k
  end
end
