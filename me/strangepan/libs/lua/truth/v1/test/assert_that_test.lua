local luaunit = require 'luaunit'
local assert_that = require 'me.strangepan.libs.lua.truth.v1.assert_that'

TestClass = {}
local test_string = 'this was a triumph'
local test_table = {x = 132}


-- Number assertions

function TestClass:test_isANumber_whenNumber_didNotThrowError()
  assert_that(132):is_a_number()
end

function TestClass:test_isANumber_whenNil_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: number expected, nil received",
    function()
      assert_that(nil):is_a_number()
    end)
end

function TestClass:test_isANumber_whenTable_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: number expected, table.- received",
    function()
      assert_that({}):is_a_number()
    end)
end


-- Boolean assertions

function TestClass:test_isABoolean_whenBoolean_didNotThrowError()
  assert_that(true):is_a_boolean()
end

function TestClass:test_isABoolean_whenNil_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: boolean expected, nil received",
    function()
      assert_that(nil):is_a_boolean()
    end)
end

function TestClass:test_isABoolean_whenTable_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: boolean expected, table.- received",
    function()
      assert_that({}):is_a_boolean()
    end)
end


-- String assertions

function TestClass:test_isAString_whenString_didNotThrowError()
  assert_that(test_string):is_a_string()
end

function TestClass:test_isAString_whenNil_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: string expected, nil received",
    function()
      assert_that(nil):is_a_string()
    end)
end

function TestClass:test_isAString_whenTable_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: string expected, table received",
    function()
      assert_that(test_table):is_a_string()
    end)
end


-- Table assertions

function TestClass:test_isATable_whenTable_didNotThrowError()
  assert_that(test_table):is_a_table()
end

function TestClass:test_isATable_whenNil_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: table expected, nil received",
    function()
      assert_that(nil):is_a_table()
    end)
end

function TestClass:test_isATable_whenString_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: table expected, string received",
    function()
      assert_that(test_string):is_a_table()
    end)
end


-- Function assertions

function TestClass:test_isAFunction_whenFunction_didNotThrowError()
  assert_that(function() end):is_a_function()
end

function TestClass:test_isAFunction_whenNil_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: function expected, nil received",
    function()
      assert_that(nil):is_a_function()
    end)
end

function TestClass:test_isAFunction_whenTable_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: function expected, table received",
    function()
      assert_that({}):is_a_function()
    end)
end


-- Value assertions

function TestClass:test_isNil_whenNil_didNotThrowError()
  assert_that(nil):is_nil()
end

function TestClass:test_isNil_whenTable_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: nil expected, table.- received",
    function()
      assert_that({}):is_nil()
    end)
end


-- Boolean assertions

-- is_true

function TestClass:test_isTrue_whenTrue_didNotThrowError()
  assert_that(true):is_true()
end

function TestClass:test_isTrue_whenString_didNotThrowError()
  assert_that(''):is_true()
end

function TestClass:test_isTrue_whenTable_didNotThrowError()
  assert_that({}):is_true()
end

function TestClass:test_isTrue_whenZero_didNotThrowError()
  assert_that(0):is_true()
end

function TestClass:test_isTrue_whenFalse_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be true, but was false",
    function()
      assert_that(false):is_true()
    end)
end

function TestClass:test_isTrue_whenNil_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be true, but was nil",
    function()
      assert_that(nil):is_true()
    end)
end

-- is_false

function TestClass:test_isFalse_whenFalse_didNotThrowError()
  assert_that(false):is_false()
end

function TestClass:test_isFalse_whenNil_didNotThrowError()
  assert_that(nil):is_false()
end

function TestClass:test_is_False_whenTrue_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be false, but was true",
    function()
      assert_that(true):is_false()
    end)
end

function TestClass:test_is_False_whenZero_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be false, but was 0",
    function()
      assert_that(0):is_false()
    end)
end

function TestClass:test_is_False_whenTable_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be false, but was table.*",
    function()
      assert_that({}):is_false()
    end)
end

function TestClass:test_is_False_whenString_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be false, but was hi",
    function()
      assert_that('hi'):is_false()
    end)
end


-- Test multiple chained invocations
function TestClass:test_isANumber_thrice_didNotThrowError()
  assert_that(132):is_a_number():is_a_number():is_a_number()
end

function TestClass:test_isAString_thrice_didNotThrowError()
  assert_that(test_string):is_a_string():is_a_string():is_a_string()
end

function TestClass:test_isATable_thrice_didNotThrowError()
  assert_that(test_table):is_a_table():is_a_table():is_a_table()
end

os.exit(luaunit.LuaUnit.run())
