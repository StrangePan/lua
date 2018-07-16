local assertion = require 'me.strangepan.libs.lua.truth.v1.assertion'

--[[ Collection of assertions used in other parts of this library and in external code.

It is preferable that external code use the `assert_that` style of assertions rather than these
simple functions, but these are still provided for convenience and efficiency.
]]

local assertions = {}

assertions.is_a_string = assertion.of_type('string')

assertions.is_a_table = assertion.of_type('table')
