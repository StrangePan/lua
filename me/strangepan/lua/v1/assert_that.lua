local class = require 'me.strangepan.lua.v1.class'

local assert_that = class.build()

function assert_that:_init(value)
  self.value = value
end

function assert_that:is_a_string()
  local value = self.value
  assert(type(value) == 'string')
  return value
end

return assert_that
