package.path = package.path..';common/?.lua'
luaunit = require('luaunit')
require 'strangepan.util.type'
require 'strangepan.util.class'

TestType = {}

local TEST_BOOLEAN = true
local TEST_FUNCTION = function() end
local TEST_NIL = nil
local TEST_FLOAT = 132.5
local TEST_STRING = 'this was a triumph'
local TEST_TABLE = {content = 'i\'m making a note here: huge success'}
local TEST_THREAD = coroutine.create(function ()
  print('it\'s hard to overstate my satisfaction')
end)
local TEST_CLASS = buildClass()
local TEST_INTEGER = 761

function TestType:test_checkType_BOOLEAN_whenBoolean_isTrue()
  luaunit.assertIsTrue(checkType(TEST_BOOLEAN, Type.BOOLEAN))
end

function TestType:test_checkType_BOOLEAN_whenFunction_isFalse()
  luaunit.assertIsFalse(checkType(TEST_FUNCTION, Type.BOOLEAN))
end

function TestType:test_checkType_FUNCTION_whenFunction_isTrue()
  luaunit.assertIsTrue(checkType(TEST_FUNCTION, Type.FUNCTION))
end

function TestType:test_checkType_FUNCTION_whenNil_isFalse()
  luaunit.assertIsFalse(checkType(TEST_NIL, Type.FUNCTION))
end

function TestType:test_checkType_NIL_whenNil_isTrue()
  luaunit.assertIsTrue(checkType(TEST_NIL, Type.NIL))
end

function TestType:test_checkType_NIL_whenNumber_isFalse()
  luaunit.assertIsFalse(checkType(TEST_FLOAT, Type.NIL))
end

function TestType:test_checkType_NUMBER_whenNumber_isTrue()
  luaunit.assertIsTrue(checkType(TEST_FLOAT, Type.NUMBER))
end

function TestType:test_checkType_NUMBER_whenString_isFalse()
  luaunit.assertIsFalse(checkType(TEST_STRING, Type.NUMBER))
end

function TestType:test_checkType_STRING_whenString_isTrue()
  luaunit.assertIsTrue(checkType(TEST_STRING, Type.STRING))
end

function TestType:test_checkType_STRING_whenTable_isFalse()
  luaunit.assertIsFalse(checkType(TEST_TABLE, Type.STRING))
end

function TestType:test_checkType_TABLE_whenTable_isTrue()
  luaunit.assertIsTrue(checkType(TEST_TABLE, Type.TABLE))
end

function TestType:test_checkType_TABLE_whenThread_isFalse()
  luaunit.assertIsFalse(checkType(TEST_THREAD, Type.TABLE))
end

function TestType:test_checkType_THREAD_whenThread_isTrue()
  luaunit.assertIsTrue(checkType(TEST_THREAD, Type.THREAD))
end

function TestType:test_checkType_THREAD_whenClass_isFalse()
  luaunit.assertIsFalse(checkType(TEST_CLASS, Type.THREAD))
end

function TestType:test_checkType_CLASS_whenSame_isTrue()
  luaunit.assertIsTrue(checkType(TEST_CLASS, TEST_CLASS))
end

function TestType:test_checkType_CLASS_whenInstance_isTrue()
  luaunit.assertIsTrue(checkType(TEST_CLASS(), TEST_CLASS))
end

function TestType:test_checkType_CLASS_whenBoolean_isFalse()
  luaunit.assertIsFalse(checkType(TEST_BOOLEAN, TEST_CLASS))
end


function TestType:test_assertBoolean_whenBoolean_didReturnBoolean()
  luaunit.assertEquals(assertBoolean(TEST_BOOLEAN), TEST_BOOLEAN)
end

function TestType:test_assertBoolean_whenBoolean_withName_didReturnBoolean()
  luaunit.assertEquals(assertBoolean(TEST_BOOLEAN , 'TEST_BOOLEAN'), TEST_BOOLEAN)
end

function TestType:test_assertBoolean_whenFunction_didThrowError_withDefaultMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected type: boolean expected, function received.',
      assertBoolean,
      TEST_FUNCTION)
end

function TestType:test_assertBoolean_whenFunction_withName_didThrowError_withNamedMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected type for TEST_FUNCTION: boolean expected, function received.',
      assertBoolean,
      TEST_FUNCTION,
      'TEST_FUNCTION')
end


function TestType:test_assertFunction_whenFunction_didReturnFunction()
  luaunit.assertEquals(assertFunction(TEST_FUNCTION), TEST_FUNCTION)
end

function TestType:test_assertFunction_whenFunction_withName_didReturnFunction()
  luaunit.assertEquals(assertFunction(TEST_FUNCTION , 'TEST_FUNCTION'), TEST_FUNCTION)
end

function TestType:test_assertFunction_whenNil_didThrowError_withDefaultMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected type: function expected, nil received.',
      assertFunction,
      TEST_NIL)
end

function TestType:test_assertFunction_whenNil_withName_didThrowError_withNamedMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected type for TEST_NIL: function expected, nil received.',
      assertFunction,
      TEST_NIL,
      'TEST_NIL')
end


function TestType:test_assertNil_whenNil_didReturnFunction()
  luaunit.assertEquals(assertNil(TEST_NIL), TEST_NIL)
end

function TestType:test_assertNil_whenNil_withName_didReturnFunction()
  luaunit.assertEquals(assertNil(TEST_NIL , 'TEST_NIL'), TEST_NIL)
end

function TestType:test_assertNil_whenNumber_didThrowError_withDefaultMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected type: nil expected, number received.',
      assertNil,
      TEST_FLOAT)
end

function TestType:test_assertNil_whenNumber_withName_didThrowError_withNamedMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected type for TEST_FLOAT: nil expected, number received.',
      assertNil,
      TEST_FLOAT,
      'TEST_FLOAT')
end


function TestType:test_assertInteger_whenInteger_didReturnInteger()
  luaunit.assertEquals(assertInteger(TEST_INTEGER), TEST_INTEGER)
end

function TestType:test_assertInteger_whenInteger_withName_didReturnInteger()
  luaunit.assertEquals(assertInteger(TEST_INTEGER, 'TEST_INTEGER'), TEST_INTEGER)
end

function TestType:test_assertInteger_whenFloat_didThrowError_withDefaultMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected number format: Integer expected, non-integer received.',
      assertInteger,
      TEST_FLOAT)
end

function TestType:test_assertInteger_whenFloat_withName_didThrowError_withNamedMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected number format for TEST_FLOAT: Integer expected, non-integer received.',
      assertInteger,
      TEST_FLOAT,
      'TEST_FLOAT')
end

function TestType:test_assertInteger_whenBoolean_didThrowError_withDefaultMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected type: number expected, boolean received.', assertInteger, TEST_BOOLEAN)
end

function TestType:test_assertInteger_whenBoolean_withName_didThrowError_withNamedMessage()
  luaunit.assertErrorMsgContains(
      'Unexpected type for TEST_BOOLEAN: number expected, boolean received.',
      assertInteger,
      TEST_BOOLEAN,
      'TEST_BOOLEAN')
end

os.exit(luaunit.LuaUnit.run())
