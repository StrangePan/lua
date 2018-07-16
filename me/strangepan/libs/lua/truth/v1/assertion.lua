local class = require 'me.strangepan.libs.lua.v1.class'

local assertion = class.build()

function assertion:_init(check_function, failure_message_function)
  self.check = check_function
  self.build_failure_message = failure_message_function
end

function assertion.of_type(type_string)
  return assertion(
      function(_, value)
        return type(value) == type_string
      end,
      function(_, value)
        return type_string..' expected, '..type(value)..' received'
      end)
end

return assertion
