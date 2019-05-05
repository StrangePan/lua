local assertion_subject = require 'me.strangepan.libs.truth.v1.assertion_subject'

--[[ An easy, readable way to make various types of assertions.

Example usage:
  local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

  function foo(bar)
    assert_that(bar):is_a_string()
    print(bar)
  end

You can even request that the result be returned:
  function foo(bar)
    print(assert_that(bar):is_a_string():and_return())
  end
]]

return function(subject)
  return assertion_subject(subject)
end
