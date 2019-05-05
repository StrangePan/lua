local class = require "me.strangepan.libs.util.v1.class"
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

--[[ A queue implementation backed by a singularly linked list. Most operations have constant-time
complexity. ]]
local Queue = class.build()

function Queue:_init()
  self:clear()
end

--[[ Adds an object into the queue at the back. Object may be nil.

Complexity is O(1).
]]
function Queue:enqueue(object)

  -- Use integer indexes instead of readable names as a micro-optimization
  local node = {
    object,
    nil,
  }

  if not self._front then
    self._front = node
  end
  if self._back then
    self._back[2] = node
  end
  self._back = node
  self._size = self._size + 1
end

--[[ Removes and returns the specified number of items from the front of the queue. If no number of
items is specified, then only one item is removed and returned.

Complexity is `O(n)`, where `n` is the value of the parameter `n`.

Parameters:
- n: must either be `nil` or a number greater than or equal to 0

Returns: the `n` items that were removed from the queue, in the order they were removed. If no items
were removed, then `nil` is returned.
]]
function Queue:poll(n)
  if n then
    assert_that(n):is_a_number():is_greater_than_or_equal_to(0)
  else
    n = n or 1
  end

  local r = {}
  local i = 1
  while i <= n and self._front do
    r[i] = self._front[1]
    i = i + 1

    self._front = self._front[1]
    if self._front == nil then
      self._back = nil
    end
    self._size = self._size - 1
  end

  return unpack(r)
end

--[[ Returns the first `n` items in the queue without removing them. `n` defaults to 1. If no items
are in the queue, then nil is returned.

Complexity is `O(n)`, where `n` is the value of the parameter `n`.

Parameters:
- n: must either be `nil` or a number greater than or equal to 0

Returns: The first `n` items in the queue in the order they were originally added. If `n` is greater
than the number of items in the queue, then only returns the items in the queue.
]]
function Queue:peek(n)
  if n then
    assert_that(n):is_a_number():is_greater_than_or_equal_to(0)
  else
    n = n or 1
  end

  local r = {}
  local i = 1
  local cur = self._front
  while i <= n and cur do
    r[i] = cur[1]
    i = i + 1
    cur = cur[2]
  end

  return unpack(r)
end

--[[ Returns `true` if the queue contains at least one item.

Complexity is O(1).
]]
function Queue:is_populated()
  return self._size > 0
end

--[[ Returns the number of items in the queue.

Complexity is O(1).
]]
function Queue:size()
  return self._size
end

--[[ Removes all items from the queue. Does not return them.

Complexity is O(1).
]]
function Queue:clear()
  self._front = nil
  self._back = nil
  self._size = 0
end

--[[ Returns an iterator function for stepping through items in queue. Items are not removed from
the queue.

Returns: an iterator function that returns position in the queue, and the item at that position.
]]
function Queue:items()
  local node = self._front
  local i = 0
  return function()
    local value = node and node[1]
    node = node and node[2]
    i = node and i + 1
    return i,value
  end
end

return Queue
