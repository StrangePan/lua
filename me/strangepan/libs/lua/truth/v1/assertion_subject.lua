local class = require 'me.strangepan.libs.lua.v1.class'
local assertions = require 'me.strangepan.libs.lua.truth.v1.assertions'

--[[ A stateful object tracking the current state of a composite assertion.

This class should not be accessed directly. Instead, it should be accessed via the assertion methods
provided by this library.
]]

local assertion_subject = class.build()

function assertion_subject:_init(subject)
  self.subject = subject
end

--[[ Checks if the current test subject is of type number and returns this assertion_subject. ]]
function assertion_subject:is_a_number()
  return self:_apply_assertion(assertions.is_a_number)
end

--[[ Checks if the current test subject is of type boolean and returns this assertion_subject. ]]
function assertion_subject:is_a_boolean()
  return self:_apply_assertion(assertions.is_a_boolean)
end

--[[ Checks if the current test subject is of type string and returns this assertion_subject. ]]
function assertion_subject:is_a_string()
  return self:_apply_assertion(assertions.is_a_string)
end

--[[ Checks if the current test subject is of type table and returns this assertion_subject. ]]
function assertion_subject:is_a_table()
  return self:_apply_assertion(assertions.is_a_table)
end

--[[ Checks if the current test subject is of type function and returns this assertion subject. ]]
function assertion_subject:is_a_function()
  return self:_apply_assertion(assertions.is_a_function)
end


-- Value assertions

--[[ Checks if the current test subject is a nil reference and returns this assertion object. ]]
function assertion_subject:is_nil()
  return self:_apply_assertion(assertions.is_nil)
end

--[[ Checks if the current test subject evaluates to true and returns this assertion object.

This check leverages the truthiness of native lua types. In other words, false, and nil evaluate to
false while every other value evalutes to true, including 0. Use the `is_a_boolean()` assertion in
combination with this one to assert the boolean `true` constant.
 ]]
function assertion_subject:is_true()
  return self:_apply_assertion(assertions.is_true)
end

--[[ Checks if the current test subject evaluates to false and returns this assertion object.

This check leverages the truthiness of native lua types. In other words, false, and nil evaluate to
false while every other value evalutes to true, including 0. Use the `is_a_boolean()` assertion in
combination with this one to assert the boolean `false` constant.
 ]]
function assertion_subject:is_false()
  return self:_apply_assertion(assertions.is_false)
end

--[[ Checks if the current test subject is equivalent to the given value and returns this assertion
object.

This check uses the `==` operator to evaluate equivalency unless it's a table. Note that using this
technique, `false` and `nil` are not equal. Tables are compared using a field-by-field recursive
comparison, including metatables. To compare table identities, use the is() assertion.
]]
function assertion_subject:equals(other)
  return self:_apply_assertion(assertions.equals(other))
end

--[[ Checks if the current test subject is the same object as the given value and returns this
assertion object.

This check uses the `==` operator to evaluate equivalency. Note that strings have no concept of
"sameness", and thus their instances cannot actually be compared. Tables are compared for identity.
To compare table equivalencies recursively, use the equals() assertion.
]]
function assertion_subject:is(other)
  return self:_apply_assertion(assertions.is(other))
end

--[[ Generic assertion method to test against the current test subject and returns this
assertion_subject. ]]
function assertion_subject:passes_assertion(assertion)
  return self:_apply_assertion(assertion)
end

-- INTERNAL METHODS

function assertion_subject:_apply_assertion(assertion)
  if not assertion:check(self.subject) then
    error ('Assertion failure: '..assertion:build_failure_message(self.subject), 2)
  end
  return self
end

return assertion_subject
