local class = require 'me.strangepan.lua.v1.class'

--[[ An easy, readable way to make various types of assertions.

Example usage:
  local assert_that = require 'me.strangepan.lua.truth.v1.assert_that'

  function foo(bar)
    assert_that(bar):is_a_string()
    print(bar)
  end

You can even request that the result be returned:
  function foo(bar)
    print(assert_that(bar):is_a_string():and_return())
  end
]]

local assert_that = class.build()

function assert_that:_init(value)
  self.value = value
end

function assert_that:is_a_string()
  assert(type(self.value) == 'string')
  return self
end

function assert_that:and_return()
  return self.value
end

return assert_that
