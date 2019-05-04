local assertion = require 'me.strangepan.libs.lua.truth.v1.assertion'

--[[ Collection of assertions used in other parts of this library and in external code.

It is preferable that external code use the `assert_that` style of assertions rather than these
simple functions, but these are still provided for convenience and efficiency.
]]

local assertions = {}

assertions.is_a_number = assertion.of_type('number')

assertions.is_a_boolean = assertion.of_type('boolean')

assertions.is_a_string = assertion.of_type('string')

assertions.is_a_table = assertion.of_type('table')

assertions.is_a_function = assertion.of_type('function')

assertions.is_nil =
    assertion(
        function(_, value)
          return value == nil
        end,
        function(_, value)
          return "nil expected, "..tostring(value).." received"
        end)

assertions.is_not_nil =
    assertion(
        function(_, value)
          return value ~= nil
        end,
        function(_, _)
          return "value is nil, expected not nil"
        end)

assertions.is_true =
    assertion(
        function(_, value)
          -- the 'not' operator converts value to boolean and inverts it. Invert again.
          return not not value
        end,
        function(_, value)
          return "expected value to be true, but was "..tostring(value)
        end)

assertions.is_false =
    assertion(
        function(_, value)
          -- The 'not' operator converts value to a boolean and inverts it
          return not value
        end,
        function(_, value)
          return "expected value to be false, but was "..tostring(value)
        end)

local function tables_are_copies(first, second)
  local seen_tables = {}
  local queue = {{first, second}}

  while queue[1] do
    first = queue[1][1]
    second = queue[1][2]
    table.remove(queue, 1)

    -- short circuit if same value or if either are not table
    if first == second then return true end
    if type(first) ~= "table" or type(second) ~= "table" then return false end

    -- check if we've made this comparison before
    if seen_tables[first] and seen_tables[first][second] then return true end
    if seen_tables[second] and seen_tables[second][first] then return true end

    -- record comparison of tables
    if seen_tables[first] then
      seen_tables[first][second] = true
    elseif seen_tables[second] then
      seen_tables[second][first] = true
    else
      seen_tables[first] = {[second] = true}
    end

    -- compare each field
    local seen_keys = {}
    for k,v in pairs(first) do
      seen_keys[k] = true
      local v2 = second[k]
      if type(v) == "table" and type(v2) == "table" then
        if (not seen_tables[v] or not seen_tables[v][v2])
            and (not seen_tables[v2] or not seen_tables[v2][v]) then
          table.insert(queue, {v, v2})
        end
      else
        if v ~= v2 then return false end
      end
    end
    -- if we encounter a field in second that we didn't see in first, auto-fail
    for k,_ in pairs(second) do
      if not seen_keys[k] then return false end
    end

    -- check if metatables are equal
    local next = {getmetatable(first), getmetatable(second)}
    if (not seen_tables[next[1]] or not seen_tables[next[1]][next[2]])
      and (not seen_tables[next[2]] or not seen_tables[next[2]][next[1]]) then
      table.insert(queue, next)
    end
  end

  return true
end

function assertions.is_copy_of(other)
  return assertion(
      function(_, value)
        return type(value) == "table"
            and type(other) == "table"
            and tables_are_copies(value, other)
      end,
      function(_, value)
        local message
        local value_is_table = type(value) == "table"
        local other_is_table = type(other) == "table"
        if not value_is_table and not other_is_table then
          message = "both received value and expected value are not tables"
        elseif not value_is_table then
          message = "received value is not a table"
        elseif not other_is_table then
          message = "expected value is not a table"
        else
          message = "received value is not a copy of expected value"
        end
        return message..":\n"
          .."  expected: "..tostring(other).."\n"
          .."  received: "..tostring(value)
      end)
end

function assertions.is_equal_to(other)
  return assertion(
      function(_, value)
        return value == other
      end,
      function(_, value)
        return "values were expected to be equal, but were unequal:\n"
            .."  expected: "..tostring(other).."\n"
            .."  received: "..tostring(value)
      end)
end

function assertions.is_unequal_to(other)
  return assertion(
      function(_, value)
        return value ~= other
      end,
      function(_, value)
        return "values were expected to be unequal, but were equal:\n"
            .."  expected: "..tostring(other).."\n"
            .."  received: "..tostring(value)
      end)
end

function assertions.is_instance_of(other)
  return assertion(
    function(_, value)
      local t = getmetatable(value)
      while t do
        if t == other then return true end
        t = getmetatable(t)
      end
      return false
    end,
    function(_, value)
      return "received value is not an instance of expected value: no equivalent metatables\n"
          .."  received: "..tostring(value)
    end)
end

function assertions.is_less_than(other)
  return assertion(
    function(_, value)
      return value < other
    end,
    function(_, value)
      return tostring(value).." is not less than "..tostring(other)
    end)
end

function assertions.is_less_than_or_equal_to(other)
  return assertion(
    function(_, value)
      return value <= other
    end,
    function(_, value)
      return tostring(value).." is not less than or equal to "..tostring(other)
    end)
end

function assertions.is_greater_than(other)
  return assertion(
    function(_, value)
      return value > other
    end,
    function(_, value)
      return tostring(value).." is not greater than "..tostring(other)
    end)
end

function assertions.is_greater_than_or_equal_to(other)
  return assertion(
    function(_, value)
      return value >= other
    end,
    function(_, value)
      return tostring(value).." is not greater than or equal to "..tostring(other)
    end)
end

function assertions.is_a_key_in_table(other)
  return assertion(
      function(_, value)
        return type(other) == "table" and other[value] ~= nil
      end,
      function (_, value)
        return tostring(value).." is not a key in table "..tostring(other)
      end)
end

function assertions.is_a_value_in_table(other)
  return assertion(
      function(_, value)
        if not type(other) ~= "table" then
          return false
        end
        for _,otherv in pairs(other) do
          if assertions.is_equal_to(otherv).check(_, value) then
            return true
          end
        end
        return false
      end,
      function (_, value)
        return tostring(value).." is not a value in table "..tostring(other)
      end)
end

function assertions.matches_a_value_in_table(other)
  return assertion(
      function(_, value)
        for _,otherv in pairs(assert_that(other):is_a_table():and_return()) do
          if assertions.is_copy_of(otherv).check(_, value) then
            return true
          end
        end
        return false
      end,
      function (_, value)
        return tostring(value).." is not a copy of a value in table "..tostring(other)
      end)
end

return assertions
