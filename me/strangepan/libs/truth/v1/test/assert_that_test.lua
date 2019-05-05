local luaunit = require 'luaunit'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

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

function TestClass:test_isNotNil_whenTable_didThrowError()
  assert_that({}):is_not_nil()
end

function TestClass:test_isNotNil_whenNil_didNotThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: value is nil, expected not nil",
    function()
      assert_that(nil):is_not_nil()
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

function TestClass:test_isFalse_whenTrue_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be false, but was true",
    function()
      assert_that(true):is_false()
    end)
end

function TestClass:test_isFalse_whenZero_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be false, but was 0",
    function()
      assert_that(0):is_false()
    end)
end

function TestClass:test_isFalse_whenTable_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be false, but was table.*",
    function()
      assert_that({}):is_false()
    end)
end

function TestClass:test_isFalse_whenString_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value to be false, but was hi",
    function()
      assert_that('hi'):is_false()
    end)
end

-- equals

function TestClass:test_isEqualTo_whenBothTrue_didNotThrowError()
  assert_that(true):is_equal_to(true)
end

function TestClass:test_isEqualTo_whenBothFalse_didNotThrowError()
  assert_that(false):is_equal_to(false)
end

function TestClass:test_isEqualTo_whenBothNil_didNotThrowError()
  assert_that(nil):is_equal_to(nil)
end

function TestClass:test_isEqualTo_whenBothEqualNumbers_didNotThrowError()
  assert_that(132):is_equal_to(132)
end

function TestClass:test_isEqualTo_whenBothEqualStrings_didNotThrowError()
  assert_that("hi"):is_equal_to("hi")
end

function TestClass:test_isEqualTo_whenBothSameFunction_didNotThrowError()
  local f = function() end
  assert_that(f):is_equal_to(f)
end

function TestClass:test_isEqualTo_whenBothSameTable_didNotThrowError()
  local t = {x = 132 }
  assert_that(t):is_equal_to(t)
end

-- equals errors

function TestClass:test_isEqualTo_whenUnequalBooleans_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(false):is_equal_to(true)
    end)
end

function TestClass:test_isEqualTo_whenNilAndFalse_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(nil):is_equal_to(false)
    end)
end

function TestClass:test_isEqualTo_whenUnequalNumbers_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(132):is_equal_to(10101010)
    end)
end

function TestClass:test_isEqualTo_whenUnequalStrings_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that("hi"):is_equal_to("bye")
    end)
end

function TestClass:test_isEqualTo_whenEqualFunctions_didThrowError()
  local f1 = function() end
  local f2 = function() end

  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(f1):is_equal_to(f2)
    end)
end

function TestClass:test_isEqualTo_whenEqualTables_didThrowError()
  local t1 = {x = 132}
  local t2 = {x = 132 }

  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(t1):is_equal_to(t2)
    end)
end

-- unequals

function TestClass:test_isUnequalTo_whenBothTrue_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be unequal, but were equal:.*",
    function()
      assert_that(true):is_unequal_to(true)
    end)
end

function TestClass:test_isUnequalTo_whenBothFalse_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be unequal, but were equal:.*",
    function()
      assert_that(false):is_unequal_to(false)
    end)
end

function TestClass:test_isUnequalTo_whenBothNil_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be unequal, but were equal:.*",
    function()
      assert_that(nil):is_unequal_to(nil)
    end)
end

function TestClass:test_isUnequalTo_whenBothEqualNumbers_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be unequal, but were equal:.*",
    function()
      assert_that(132):is_unequal_to(132)
    end)
end

function TestClass:test_isUnequalTo_whenBothEqualStrings_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be unequal, but were equal:.*",
    function()
      assert_that("hi"):is_unequal_to("hi")
    end)
end

function TestClass:test_isUnequalTo_whenBothSameFunction_didThrowError()
  local f = function() end
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be unequal, but were equal:.*",
    function()
      assert_that(f):is_unequal_to(f)
    end)
end

function TestClass:test_isUnequalTo_whenBothSameTable_didThrowError()
  local t = {x = 132}
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be unequal, but were equal:.*",
    function()
      assert_that(t):is_unequal_to(t)
    end)
end

-- equals errors

function TestClass:test_isEqualTo_whenUnequalBooleans_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(false):is_equal_to(true)
    end)
end

function TestClass:test_isEqualTo_whenNilAndFalse_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(nil):is_equal_to(false)
    end)
end

function TestClass:test_isEqualTo_whenUnequalNumbers_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(132):is_equal_to(10101010)
    end)
end

function TestClass:test_isEqualTo_whenUnequalStrings_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that("hi"):is_equal_to("bye")
    end)
end

function TestClass:test_isEqualTo_whenEqualFunctions_didThrowError()
  local f1 = function() end
  local f2 = function() end

  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(f1):is_equal_to(f2)
    end)
end

function TestClass:test_isEqualTo_whenEqualTables_didThrowError()
  local t1 = {x = 132}
  local t2 = {x = 132 }

  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: values were expected to be equal, but were unequal:.*",
    function()
      assert_that(t1):is_equal_to(t2)
    end)
end

-- copy

function TestClass:test_isCopyOf_whenSameTable_didNotThrowError()
  local t = {}
  assert_that(t):is_copy_of(t)
end

function TestClass:test_isCopyOf_whenEmptyTables_didNotThrowError()
  assert_that({}):is_copy_of({})
end

function TestClass:test_isCopyOf_whenEmptyTables_withSameMetatable_didNotThrowError()
  local mtable = {}
  local t1 = {}
  local t2 = {}
  setmetatable(t1, mtable)
  setmetatable(t2, mtable)

  assert_that(t1):is_copy_of(t2)
end

function TestClass:test_isCopyOf_whenTablesContainNumbers_didNotThrowError()
  assert_that({1, 2, 3}):is_copy_of({[1] = 1, [2] = 2, [3] = 3})
end

function TestClass:test_isCopyOf_whenTablesContainStrings_didNotThrowError()
  assert_that({"one", "two", "three"}):is_copy_of({[1] = "one", [2] = "two", [3] = "three"})
end

function TestClass:test_isCopyOf_whenTablesContainFuctions_didNotThrowError()
  local f1 = function() end
  local f2 = function() print("hi") end

  assert_that({a = f1, [132] = f2}):is_copy_of({["a"] = f1, [132] = f2})
end

function TestClass:test_isCopyOf_whenTableContainsTables_didNotThrowError()
  local t1 = {{x = 132}, ["hi"] = {"hello"} }
  local t2 = {hi = {[1] = "hello"}, [1] = {["x"] = 132}}

  assert_that(t1):is_copy_of(t2)
end

function TestClass:test_isCopyOf_whenTableContainsTablesContainsSelf_didNotThrowError()
  -- Test that recursive equality check does not fail when tables contain references to themselves
  local t1 = {x = {132}}
  t1.y = t1
  local t2 = {y = t1, x = t1.x}

  assert_that(t1):is_copy_of(t2)
end

-- copy failures

function TestClass:test_isCopyOf_whenEqualStrings_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: both received value and expected value are not tables:.*",
    function()
      assert_that("hi"):is_copy_of("hi")
    end)
end

function TestClass:test_isCopyOf_whenReceivedValueIsString_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: received value is not a table:.*",
    function()
      assert_that("hi"):is_copy_of({})
    end)
end

function TestClass:test_isCopyOf_whenEqualStrings_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: expected value is not a table:.*",
    function()
      assert_that({}):is_copy_of("hi")
    end)
end

function TestClass:test_isCopyOf_whenMetatablesUnequal_didThrowError()
  local t1 = {}
  local t2 = {}
  setmetatable(t1, {})
  setmetatable(t2, {x = 1})

  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: received value is not a copy of expected value:.*",
    function()
      assert_that(t1):is_copy_of(t2)
    end)
end

function TestClass:test_isCopyOf_whenTablesUnequal_didThrowError()
  local t1 = {x = 132, y = {}}
  local t2 = {x = 1010101, y = {}}

  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: received value is not a copy of expected value:.*",
    function()
      assert_that(t1):is_copy_of(t2)
    end)
end

function TestClass:test_isCopyOf_whenExpectedHasMoreFields_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: received value is not a copy of expected value:.*",
    function()
      assert_that({1, 2, 3}):is_copy_of({1, 2, 3, 4})
    end)
end

function TestClass:test_isCopyOf_whenExpectedHasFewerFields_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: received value is not a copy of expected value:.*",
    function()
      assert_that({1, 2, 3}):is_copy_of({1, 2})
    end)
end

-- is instance of

function TestClass:test_isInstanceOf_whenString_didThrowError()
  luaunit.assertErrorMsgMatches(
      ".-Assertion failure: received value is not an instance of expected value: "
        .."no equivalent metatables.*",
      function()
        assert_that("hi"):is_instance_of({})
      end)
end

function TestClass:test_isInstanceOf_whenMetatableMatches_didNotThrowError()
  local instance = {}
  local class = {}
  setmetatable(instance, class)

  assert_that(instance):is_instance_of(class)
end

function TestClass:test_isInstanceOf_whenMetatableOfMetatableMatches_didNotThrowError()
  local instance = {}
  local class = {}
  local superclass = {}
  setmetatable(instance, class)
  setmetatable(class, superclass)

  assert_that(instance):is_instance_of(superclass)
end

function TestClass:test_isInstanceOf_whenMetatableDoesNotMatch_didThrowError()
  local instance = {}
  local class = {}
  local otherclass = {}
  setmetatable(instance, class)

  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: received value is not an instance of expected value: "
        .."no equivalent metatables.*",
    function()
      assert_that(instance):is_instance_of(otherclass)
    end)
end

-- less than

function TestClass:test_isLessThan_whenLessThan_didNotThrowError()
  assert_that(10):is_less_than(20)
end

function TestClass:test_isLessThan_whenEqual_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: 10 is not less than 10",
    function()
      assert_that(10):is_less_than(10)
    end)
end

function TestClass:test_isLessThan_whenGreaterThan_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: 10 is not less than 5",
    function()
      assert_that(10):is_less_than(5)
    end)
end

function TestClass:test_isLessThanOrEqualTo_whenLessThan_didNotThrowError()
  assert_that(10):is_less_than_or_equal_to(20)
end

function TestClass:test_isLessThanOrEqualTo_whenEqual_didNotThrowError()
  assert_that(10):is_less_than_or_equal_to(10)
end

function TestClass:test_isLessThanOrEqualTo_whenGreaterThan_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: 10 is not less than or equal to 5",
    function()
      assert_that(10):is_less_than_or_equal_to(5)
    end)
end

function TestClass:test_isGreaterThanOrEqualTo_whenGreaterThan_didNotThrowError()
  assert_that(20):is_greater_than_or_equal_to(10)
end

function TestClass:test_isGreaterThanOrEqualTo_whenEqual_didNotThrowError()
  assert_that(5):is_greater_than_or_equal_to(5)
end

function TestClass:test_isGreaterThanOrEqualTo_whenLessThan_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: 5 is not greater than or equal to 10",
    function()
      assert_that(5):is_greater_than_or_equal_to(10)
    end)
end

function TestClass:test_isGreaterThan_whenGreaterThan_didNotThrowError()
  assert_that(20):is_greater_than(10)
end

function TestClass:test_isGreaterThan_whenEqual_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: 5 is not greater than 5",
    function()
      assert_that(5):is_greater_than(5)
    end)
end

function TestClass:test_isGreaterThan_whenLessThan_didThrowError()
  luaunit.assertErrorMsgMatches(
    ".-Assertion failure: 5 is not greater than 10",
    function()
      assert_that(5):is_greater_than(10)
    end)
end

-- and_return

function TestClass:test_andReturn_didReturn()
  local testObject = "hello"

  luaunit.assertEquals(
      testObject,
      assert_that(testObject):and_return())
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
