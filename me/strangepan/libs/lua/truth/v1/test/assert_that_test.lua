local luaunit = require 'luaunit'
local assert_that = require 'me.strangepan.libs.lua.truth.v1.assert_that'

TestClass = {}
local test_string = 'this was a triumph'
local test_table = {x = 132}

function TestClass:test_isAString_whenString_didNotThrowError()
  assert_that(test_string):is_a_string()
end

function TestClass:test_isAString_whenTable_didThrowError()
  luaunit.assertError(function()
    assert_that(test_table):is_a_string()
  end)
end

function TestClass:test_isATable_whenTable_didNotThrowError()
  assert_that(test_table):is_a_table()
end

function TestClass:test_isATable_whenString_didThrowError()
  luaunit.assertError(function()
    assert_that(test_string):is_a_table()
  end)
end

-- Test multiple chained invocations
function TestClass:test_isAString_thrice_didNotThrowError()
  assert_that(test_string):is_a_string():is_a_string():is_a_string()
end

function TestClass:test_isATable_thrice_didNotThrowError()
  assert_that(test_table):is_a_table():is_a_table():is_a_table()
end

os.exit(luaunit.LuaUnit.run())
