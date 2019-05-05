local class = require "me.strangepan.libs.util.v1.class"
local Queue = require "me.strangepan.games.mazerino.common.strangepan.util.Queue"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

--[[
Specialized queue for enqueuing function calls and executing them.
]]
local FunctionQueue = class.build()

function FunctionQueue:_init()
  self.queue = Queue()
end

function FunctionQueue:push(func, ...)
  assert_that(func):is_a_function():and_return()
  self.queue:push({f = func, a = {...}})
end

function FunctionQueue:executeAll()
  while not self.queue:empty() do
    self:executeSingle()
  end
end

function FunctionQueue:executeSingle()
  local a = self.queue:pop()
  if a then
    a.f(unpack(a.a))
  end
end

function FunctionQueue:empty()
  return self.queue:empty()
end

function FunctionQueue:clear()
  return self.queue:clear()
end

return FunctionQueue
