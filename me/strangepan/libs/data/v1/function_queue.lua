local class = require "me.strangepan.libs.util.v1.class"
local Queue = require "me.strangepan.libs.data.v1.queue"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

--[[ Specialized queue for enqueuing function calls and executing them. ]]
local FunctionQueue = class.build()

function FunctionQueue:_init()
  self.queue = Queue()
end

--[[ Adds a new function into the queue at the back, along with a list of parameters to pass into
the function when it is eventually run.

Parameters:
- func: `function` to be run when polled
- ...: parameters to be passed into `func` when polled
]]
function FunctionQueue:enqueue(func, ...)
  assert_that(func):is_a_function():and_return()
  self.queue:push({func, {...}})
end

--[[ Removes and runs runs all functions in the queue in the order they were enqueued util the queue
is empty.

Returns `true` if at least one function was popped and run.
]]
function FunctionQueue:poll_all()
  local did_poll = false
  while self:poll() do
    did_poll = true
  end
  return did_poll
end

--[[ Pops the front function off the queue and runs it. Does nothing if the queue is empty.

Returns `true` if a function was removed from the queue and executed.
]]
function FunctionQueue:poll()
  local a = self.queue:poll()
  if a then
    a[1](unpack(a[2]))
    return true
  end
  return false
end

--[[ Returns `true` if the queue contains at least one function. ]]
function FunctionQueue:is_populated()
  return self.queue:is_populated()
end

--[[ Remove all functions from the queue without executing them. ]]
function FunctionQueue:clear()
  return self.queue:clear()
end

return FunctionQueue
