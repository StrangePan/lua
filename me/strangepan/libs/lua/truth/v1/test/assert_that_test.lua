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

function TestClass:test_isAString_andreturn_whenString_didReturnValue()
  luaunit.assertEquals(assert_that(test_string):is_a_string():and_return(), test_string)
end

os.exit(luaunit.LuaUnit.run())
