-- Collection of type assertion methods that can be used to verify parameter types at runtime.

--[[
-- List of basic types used in assertions. Can be used to reference lua types programmatically
-- instead of litering code with strings.
--]]
Type = {
  BOOLEAN = 'boolean',
  FUNCTION = 'function',
  NIL = 'nil',
  NUMBER = 'number',
  STRING = 'string',
  TABLE = 'table',
  THREAD = 'thread',
  USERDATA = 'userdata',
}


--[[
-- Convenience function that checks if the given `value` matches the given `expectedType`. Returns
-- either `true` or `false`.
--
-- value: Required. The value to check the type of.
-- expectedType: Required. A description of the expected type. May be a string representation of a
--     Lua basic type (i.e. a value from the `Type` table) or a class reference.
-- return: `true` if the type of `value` matches `expectedType`, `false` otherwise.
 ]]
function checkType(value, expectedType)
  if type(expectedType) == 'string' then
    return type(value) == expectedType
  end

  while value ~= nil and expectedType ~= nil do
    if value == expectedType then
      return true
    else
      --Compares all parent classes
      value = getmetatable(value)
    end
  end

  --No match found
  return false
end


--[[
-- Convenience function for asserting that a value is a boolean.
--
-- value: Required. The value to check the type of.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertBoolean(value, name)
  return assertBasicType(value, Type.BOOLEAN, name)
end


--[[
-- Convenience function for asserting that a value is a function.
--
-- value: Required. The value to check the type of.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertFunction(value, name)
  return assertBasicType(value, Type.FUNCTION, name)
end


--[[
-- Convenience function for asserting that a value is nil.
--
-- value: Required. The value to check the type of.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertNil(value, name)
  return assertBasicType(value,Type.NIL, name)
end


--[[
-- Convenience function for asserting that a value is a number.
--
-- value: Required. The value to check the type of.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertNumber(value, name)
  return assertBasicType(value, Type.NUMBER, name)
end


--[[
-- Convenience function for asserting that a value is a string.
--
-- value: Required. The value to check the type of.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertString(value, name)
  return assertBasicType(value, Type.STRING, name)
end


--[[
-- Convenience function for asserting that a value is a table.
--
-- value: Required. The value to check the type of.
-- name: Optional. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertTable(value, name)
  return assertBasicType(value, Type.TABLE, name)
end


--[[
-- Convenience function for asserting that a value is a thread.
--
-- value: Required. The value to check the type of.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertThread(value, name)
  return assertBasicType(value, Type.THREAD, name)
end


--[[
-- Convenience function for asserting that a value is a userdata.
--
-- value: Required. The value to check the type of.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertUserdata(value, name)
  return assertBasicType(value, Type.USERDATA, name)
end


--[[
-- Convenience function for asserting that a value is an instance of a specific class.
--
-- value: Required. The value to check the type of.
-- class: Required table. The class or superclass that `value` is expected to be.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertClass(value, class, name)
  assertTable(value, 'value')
  assertTable(class, 'class')

  local errorMessage
  if type(name) == Type.STRING then
    errorMessage = "Unexpected type for "..name..": Object not an instance of the expected class."
  else
    errorMessage = "Unexpected type: Object not an instance of the expected class."
  end

  assert(checkType(value, class), errorMessage)
  return value
end


--[[
-- Convenience function for asserting that a value is an integer number.
--
-- value: Required. The value to check the type and value of.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertInteger(value, name)
  assertNumber(value, name)

  local errorMessage
  if type(name) == Type.STRING then
    errorMessage =
        "Unexpected number format for "..name..": Integer expected, non-integer received."
  else
    errorMessage = "Unexpected number format: Integer expected, non-integer received."
  end

  assert(math.floor(value) == value, errorMessage)
  return value
end


--[[
-- Convenience function for generic type assertions
--
-- value: Required. The value to check the type of.
-- expectedType: Required string. Name of type that `value` is expected to be. Must be a value from
--     the `Type` table.
-- name: Optional string. A name to use when referencing `value` in the error message.
-- return: The original value if the assertion is `true`. Otherwise throws an assertion error.
--]]
function assertBasicType(value, expectedType, name)
  assert(type(expectedType) == Type.STRING, 'Assertion error: expectedType must be a string.')

  local actualType = type(value)
  local errorMessage
  if type(name) == Type.STRING then
    errorMessage =
        'Unexpected type for '..name..': '..expectedType..' expected, '..actualType..' received.'
  else
    errorMessage = 'Unexpected type: '..expectedType..' expected, '..actualType..' received.'
  end

  assert(actualType == expectedType, errorMessage)
  return value
end

