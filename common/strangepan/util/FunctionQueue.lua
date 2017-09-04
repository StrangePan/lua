require "strangepan.util.class"
require "strangepan.util.functions"
require "strangepan.util.Queue"

--[[
Specialized queue for enqueuing function calls and executing them.
]]
FunctionQueue = buildClass()
local class = FunctionQueue

function class:_init()
  self.queue = Queue()
end

function class:push(func, ...)
  assertType(func, 'func', 'function')
  self.queue:push({f = func, a = {...}})
end

function class:executeAll()
  while not self.queue:empty() do
    self:executeSingle()
  end
end

function class:executeSingle()
  local a = self.queue:pop()
  if a then
    a.f(unpack(a.a))
  end
end

function class:empty()
  return self.queue:empty()
end

function class:clear()
  return self.queue:clear()
end
