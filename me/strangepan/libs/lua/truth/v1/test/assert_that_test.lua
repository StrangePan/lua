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
  luaunit.assertError(function()
    assert_that(nil):is_a_number()
  end)
end

function TestClass:test_isANumber_whenTable_didThrowError()
  luaunit.assertError(function()
    assert_that({}):is_a_number()
  end)
end

-- Boolean assertions
function TestClass:test_isABoolean_whenBoolean_didNotThrowError()
  assert_that(true):is_a_boolean()
end

function TestClass:test_isABoolean_whenNil_didThrowError()
  luaunit.assertError(function()
    assert_that(nil):is_a_boolean()
  end)
end

function TestClass:test_isABoolean_whenTable_didThrowError()
  luaunit.assertError(function()
    assert_that({}):is_a_boolean()
  end)
end

-- String assertions
function TestClass:test_isAString_whenString_didNotThrowError()
  assert_that(test_string):is_a_string()
end

function TestClass:test_isAString_whenNil_didThrowError()
  luaunit.assertError(function()
    assert_that(nil):is_a_string()
  end)
end

function TestClass:test_isAString_whenTable_didThrowError()
  luaunit.assertError(function()
    assert_that(test_table):is_a_string()
  end)
end

-- Table assertions
function TestClass:test_isATable_whenTable_didNotThrowError()
  assert_that(test_table):is_a_table()
end

function TestClass:test_isATable_whenNil_didThrowError()
  luaunit.assertError(function()
    assert_that(nil):is_a_table()
  end)
end

function TestClass:test_isATable_whenString_didThrowError()
  luaunit.assertError(function()
    assert_that(test_string):is_a_table()
  end)
end

-- Table assertions

function TestClass:test_isAFunction_whenFunction_didNotThrowError()
  assert_that(function() end):is_a_function()
end

function TestClass:test_isAFunction_whenNil_didThrowError()
  luaunit.assertError(function()
    assert_that(nil):is_a_functino()
  end)
end

function TestClass:test_isAFunction_whenTable_didThrowError()
  luaunit.assertError(function()
    assert_that({}):is_a_function()
  end)
end

-- Value assertions

function TestClass:test_isNil_whenNil_didNotThrowError()
  assert_that(nil):is_nil()
end

function TestClass:test_isNil_whenTable_didThrowError()
  luaunit.assertError(function()
    assert_that({}):is_nil()
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
