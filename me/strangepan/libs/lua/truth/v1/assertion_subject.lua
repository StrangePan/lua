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

--[[ Checks if the current test subject is of type string and returns this assertion_subject. ]]
function assertion_subject:is_a_string()
  return self:_apply_assertion(assertions.is_a_string)
end

--[[ Checks if the current test subject is of type table and returns this assertion_subject. ]]
function assertion_subject:is_a_table()
  return self:_apply_assertion(assertions.is_a_table)
end

--[[ Generic assertion method to test against the current test subject and returns this
assertion_subject. ]]
function assertion_subject:passes_assertion(assertion)
  return self:_apply_assertion(assertion)
end

-- INTERNAL METHODS

function assertion_subject:_apply_assertion(assertion)
  if not assertion:check(self.subject) then
    error('Assertion failure: '..assertion:build_failure_message(self.subject), 3)
  end
  return self
end

return assertion_subject
