local class = require 'me.strangepan.libs.lua.v1.class'
local assertions = require 'me.strangepan.libs.lua.truth.v1.assertions'

--[[ A stateful object tracking the current state of a composite assertion.

This class should not be accessed directly. Instead, it should be accessed via the assertion methods
provided by this library.
]]

local assertion_subject = class.build()

function assertion_subject:_init(subject)
  self.subject = subject
  self.assertion_count = 0
end

--[[ Checks if the current test subject is of type number and returns this assertion_subject. ]]
function assertion_subject:is_a_number()
  return self:passes_assertion(assertions.is_a_number)
end

--[[ Checks if the current test subject is of type boolean and returns this assertion_subject. ]]
function assertion_subject:is_a_boolean()
  return self:passes_assertion(assertions.is_a_boolean)
end

--[[ Checks if the current test subject is of type string and returns this assertion_subject. ]]
function assertion_subject:is_a_string()
  return self:passes_assertion(assertions.is_a_string)
end

--[[ Checks if the current test subject is of type table and returns this assertion_subject. ]]
function assertion_subject:is_a_table()
  return self:passes_assertion(assertions.is_a_table)
end

--[[ Checks if the current test subject is of type function and returns this assertion subject. ]]
function assertion_subject:is_a_function()
  return self:passes_assertion(assertions.is_a_function)
end

--[[ Generic assertion method to test against the current test subject and returns this
assertion_subject. ]]
function assertion_subject:passes_assertion(assertion)
  return self:_apply_assertion(assertion)
end

-- INTERNAL METHODS

function assertion_subject:_apply_assertion(assertion)
  assert(
      assertion:check(self.subject),
      'Assertion failure: '..assertion:build_failure_message(self.subject))
  self:_record_assertion()
  return self
end

function assertion_subject:_record_assertion()
  self.assertion_count = self.assertion_count + 1
end

return assertion_subject
