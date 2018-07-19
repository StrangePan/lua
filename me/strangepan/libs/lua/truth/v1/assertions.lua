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

return assertions
