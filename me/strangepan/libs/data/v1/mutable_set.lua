local class = require "me.strangepan.libs.util.v1.class"

local MutableSet = class.build()

function MutableSet:_init()
  self._contents = {}
  self._size = 0
end

--[[ Adds a new item into the set. If the item already exists in the set, then no change occurs.
Returns true if an item was added to the set. ]]
function MutableSet:add(item)
  if not self._contents[item] then
    self._contents[item] = true
    self._size = self._size + 1
    return true
  end
  return false
end

--[[ Removes the given item from the set if contained in the set. Returns `true` if an item was
removed from the set. ]]
function MutableSet:remove(item)
  if self._contents[item] then
    self._contents[item] = nil
    self._size = self._size - 1
    return true
  end
  return false
end

--[[ Returns `true` iff the set contains the given item. ]]
function MutableSet:contains(item)
  return self._contents[item] == true
end

--[[ Returns the number of items in the set. ]]
function MutableSet:size()
  return self._size
end

--[[ Returns `true` iff the set contains at least one item. ]]
function MutableSet:is_populated()
  return self._size > 0
end

--[[ Removes all items from the set. ]]
function MutableSet:clear()
  self._contents = {}
  self._size = 0
end

--[[ Returns an iterator function that iterates through the contents of the set in an undefined
order. ]]
function MutableSet:items()
  local f = pairs(self._contents)
  return function()
    -- we only want the key; drop the value
    local k = f()
    return k
  end
end

return MutableSet
