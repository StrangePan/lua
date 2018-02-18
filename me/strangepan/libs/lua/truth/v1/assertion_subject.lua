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
  self.finaled = false
end

-- INITIALIZER ASSERTIONS

function assertion_subject:is_a_string()
  return self:passes_assertion(assertions.is_a_string)
end

function assertion_subject:is_a_table()
  return self:passes_assertion(assertions.is_a_table)
end

function assertion_subject:passes_assertion(assertion)
  self:_assert_ready_for_initial_assertion()
  return self:_apply_assertion(assertion)
end

-- CHAINED ASSERTIONS

function assertion_subject:and_is_a_string()
  return self:and_passes_assertion(assertions.is_a_string)
end

function assertion_subject:and_is_a_table()
  return self:and_passes_assertion(assertions.is_a_table)
end

function assertion_subject:and_passes_assertion(assertion)
  self:_assert_ready_for_chained_assertion()
  return self:_apply_assertion(assertion)
end

-- FINALIZERS

function assertion_subject:and_return_value()
  self:_assert_ready_for_finalization()
  self.finalized = true
  return self.value
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

function assertion_subject:_assert_not_finalized()
  assert(
      not self.finalized
      'Improper use of assertions: assertions made after already finalized. A new assertion must '
          ..'be started using \'assert_that()\'')
end

function assertion_subject:_assert_ready_for_initial_assertion()
  self:_assert_not_finalized()
  assert(
      self.assertion_count < 1,
      'Improper use of assertions: use the assertion methods prefixed with \'and\' when chaining '
          ..'assertions')
end

function assertion_subject:_assertion_ready_for_chained_assertion()
  self:_assert_not_finalized()
  assert(
      self.assertion_count >= 1,
      'Improper use of assertions: do not use \'and\' prefixed assertions when starting an '
          ..'assertion chain')
end

function assertion_subject:_assert_ready_for_finalization()
  self:_assert_not_finalized()
  assert(
      self.assertion_count >= 1, 'Improper use of assertions: at least one assertion must be made')
end

return assertion_subject
