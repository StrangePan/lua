local class = require "me.strangepan.libs.lua.v1.class"
local assert_that = require "me.strangepan.libs.lua.truth.v1.assert_that"

local SortedSet = class.build()

--[[
A type of set that only accepts integers and keeps them in sorted order.
]]
function SortedSet:_init()
  self.contents = {}
end

--[[
Inserts an integer into the set. If number already exists in set, does nothing.
Returns `true` if the number was not previously in the set and was inserted and
`false` if it was already in the set.
]]
function SortedSet:insert(number)
  assert_that(number):is_a_number():and_return()
  
  local n = #self.contents
  if n == 0 or self.contents[1] > number then
    self.contents[1] = number
    return true
  end

  if self.contents[n] < number then
    self.contents[n + 1] = number
    return true
  end
  
  if self.contents[1] == number or self.contents[n] == number then
    return false
  end
  
  -- binary search to find insertion point
  local min = 1
  local max = n - 1
  local mid = math.floor((min + max) / 2)
  while min ~= max and not (self.contents[mid] <= number and self.contents[mid + 1] >= number) do
    if self.contents[mid] > number then
      min = mid + 1
    elseif self.contents[mid + 1] < number then
      max = mid
    end
    mid = math.floor((min + max) / 2)
  end

  if self.contents[mid] < number and self.contents[mid + 1] > number then
    table.insert(self.contents, mid + 1, number)
    return true
  end
  return false
end

--[[
Removes an integer from the set. If the number doesn't already existin the set,
does nothing.

Returns `true` if the number was in the set and was removed and `false` if it was not
in the set.
]]
function SortedSet:remove(number)
  assert_that(number):is_a_number():and_return()
  
  local n = #self.contents
  if n == 0 or self.contents[1] > number or self.contents[n] < number then
    return false
  end
  
  -- binary search to find number in set
  local min = 1
  local max = n
  local mid = math.floor((min + max) / 2)
  while min < max and self.contents[mid] ~= number do
    if self.contents[mid] < number then
      min = mid + 1
    elseif self.contents[mid] > number then
      max = mid - 1
    end
    mid = math.floor((min + max) / 2)
  end
  
  if self.contents[mid] == number then
    table.remove(self.contents, mid)
    return true
  end
  return false
end

--[[
Gets the number of items in the set.
]]
function SortedSet:size()
  return #self.contents
end

--[[
Checks whether the set contains the given number.
]]
function SortedSet:contains(number)
  assert_that(number):is_a_number():and_return()
  
  local n = #self.contents
  if n == 0 then
    return false
  end
  
  -- binary search to find number in set
  local min = 1
  local max = n
  local mid = math.floor((min + max) / 2)
  while min < max and self.contents[mid] ~= number do
    if self.contents[mid] < number then
      min = mid + 1
    elseif self.contents[mid] > number then
      max = mid - 1
    end
    mid = math.floor((min + max) / 2)
  end
  
  return self.contents[mid] == number
end

--[[
Returns an iterator function for all values in the set. Traverses the set in
order.
]]
function SortedSet:values()
  local i = 0
  local values = self.contents
  return function()
    i = i + 1
    return values[i]
  end
end

return SortedSet
