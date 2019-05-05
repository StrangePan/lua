local class = require "me.strangepan.libs.util.v1.class"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

--[[ A type of set that keeps its contents sorted in a defined order. The order of the contents can
be specified using one of the following methods:

- Numbers are ordered from smallest to greatest
- Tables are sorted according to their metatable's __lt and __le functions.
- A custom comparator can be provided in the constructor that will be applied to every item

Custom comparator implementations must obey the following contract. Otherwise, behavior is
undefined:
- Accepts two parameters `a` and `b`
- Returns `true` if `a` and `b` are in the correct order, where `a` is placed before `b` in the set
- Returns `false` if `a` and `b` are in the incorrect order, where `b` comes before `a` in the set
- Returns `true` if the order of `a` and `b` does not matter (i.e. they are equal)
- Is transitive; if `a` comes before `b`, and `b` comes before `c`, `a` comes before `c`.

It's important that tables inserted into this table are not mutated in a way that would affect their
order in the table. This will cause the sorting order to break.

This set enforces exclusivity; the same item may not be included twice. This is accomplished using
standard equivalency operators.
]]
local SortedSet = class.build()

local DEFAULT_COMPARATOR = function(a, b) return a <= b end

function SortedSet:_init(comparator)
  if comparator then
    self._are_in_order = assert_that(comparator):is_a_function():and_return()
  else
    self._are_in_order = DEFAULT_COMPARATOR
  end
  self._contents = {}
  self._size = 0
end

--[[ Adds an item into the set. If the item already exists in the set, nothing happens.

Returns: `true` if an item was inserted into the set
]]
function SortedSet:add(item)

  local n = self._size

  -- return early if item is at either the front or back of the array and return early
  if n > 0 and self._contents[1] == item or self._contents[n] == item then
    return false
  end

  -- add to front of array of it makes sense and return early
  if n == 0 or self._are_in_order(item, self._contents[1]) then
    self._contents[1] = item
    self._size = n + 1
    return true
  end

  -- add to back of array if it makes sense and return early
  if self._are_in_order(self._contents[n], item) then
    self._contents[n + 1] = item
    self._size = n + 1
    return true
  end

  -- binary search to find insertion point
  local min = 2 -- inclusive
  local max = n - 1 -- inclusive
  local mid = math.floor((min + max) / 2)
  while min < max do
    local pivot = self._contents[mid]
    if item == pivot then
      return false
    end

    -- compare with pivot
    if self._are_in_order(item, pivot) then
      -- lies at or below pivot
      if self._are_in_order(self._contents[mid - 1], item) then
        -- lies at pivot
        break
      end
      -- somewhere below pivot
      max = mid - 1
    else
      -- lies somewhere above pivot
      if self._are_in_order(item, self._contents[mid + 1]) then
        -- lies just above pivot
        mid = mid + 1
        break
      end
      -- lies somewhere above pivot
      min = mid + 1
    end
  end

  -- enforce uniqueness
  if self._contents[mid] == item then
    return false
  end

  table.insert(self._contents, mid, item)
  self._size = n + 1
  return true
end

--[[ Finds the given `item` in the given `SortedSet` and returns the index or nil if not found. ]]
local function find(self, item)
  local n = self._size

  -- check ends of list and return early
  if n == 0
      or not self._are_in_order(self._contents[1], item)
      or n >= 2
      and not self._are_in_order(item, self._contents[n]) then
    return nil
  end

  -- maybe remove from front of array and return early
  if n >= 1 and self._contents[1] == item then
    return 1
  end

  -- maybe remove from end of array and return early
  if n >= 2 and self._contents[n] == item then
    return n
  end

  -- binary search to find lower bound of search space
  local min = 2 -- inclusive
  local max = n - 1 -- inclusive
  local mid = math.floor((min + max) / 2)
  while min < max do
    local pivot = self._contents[mid]

    if self._are_in_order(item, pivot) then
      -- lower bound at or below pivot
      if self._are_in_order(self._contents[mid - 1], item) then
        -- lower bound at pivot
        break
      end
      -- lower bound somewhere below pivot
      max = mid - 1
    else
      -- lower somewhere above pivot
      min = mid + 1
    end
  end

  local lower_bound = mid

  -- binary search to find upper bound
  min = 2 -- inclusive
  max = n - 1 -- inclusive
  mid = math.floor((min + max) / 2)
  while min < max do
    local pivot = self._contents[mid]

    if self._are_in_order(pivot, item) then
      -- upper bound at or above pivot
      if self._are_in_order(item, self._contents[mid + 1]) then
        -- upper bound at pivot
        break
      end
      -- upper bound somewhere above pivot
      min = mid + 1
    else
      max = mid - 1
    end
  end

  local upper_bound = mid

  for i = lower_bound,upper_bound do
    if self._contents[i] == item then
      return i
    end
  end
  return nil
end

--[[ Removes an item from the set. If the item isn't contained in the set, nothing happens.

Returns `true` if the item was removed from the set.
]]
function SortedSet:remove(item)
  local i = find(self, item)
  if i then
    table.remove(self._contents, i)
    self._size = self._size - 1
    return true
  end
  return false
end

--[[ Checks whether the set contains the given item. ]]
function SortedSet:contains(item)
  return find(self, item) ~= nil
end

--[[ Gets the number of items in the set. ]]
function SortedSet:size()
  return self._size
end

--[[ Returns an iterator function that iterates over all items in the set in order. The iterator
returns just the items in the set. ]]
function SortedSet:items()
  local i = 0
  local values = self._contents
  return function()
    i = i + 1
    return values[i]
  end
end

return SortedSet
