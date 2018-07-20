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

local are_equal
are_equal = function(first, second, seen_tables)
  seen_tables = seen_tables or {}

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
    if not are_equal(v, second[k], seen_tables) then return false end
  end
  -- if we encounter a field in second that we didn't see in first, auto-fail
  for k,_ in pairs(second) do
    if not seen_keys[k] then return false end
  end
  -- check if metatables are equal
  return are_equal(getmetatable(first), getmetatable(second), seen_tables)
end

function assertions.equals(other)
  return assertion(
      function(_, value)
        return value == other
            or type(value) == "table"
                and type(other) == "table"
                and are_equal(value, other)
      end,
      function(_, value)
        return "values are not equal:\n"
            .."  expected: "..tostring(other).."\n"
            .."  received: "..tostring(value)
      end)
end

function assertions.is(other)
  return assertion(
      function(_, value)
        return value == other and type(value) == type(other)
      end,
      function(_, value)
        return "values are not the same:\n"
            .."  expected: "..tostring(other).."\n"
            .."  received: "..tostring(value)
      end)
end

return assertions
