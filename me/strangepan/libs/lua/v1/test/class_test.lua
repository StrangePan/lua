local luaunit = require 'luaunit'
local class = require 'me.strangepan.libs.lua.v1.class'

TestClass = {}

function TestClass:test_build_thenInvokeConstructor_didCallInit()
  local testClass = class.build()
  local invokeCount = 0
  testClass._init = function()
    invokeCount = invokeCount + 1
  end

  testClass()

  luaunit.assertEquals(invokeCount, 1)
end

function TestClass:test_build_thenInvokeConstructor_didPassArguments()
  local testString = "asdf"
  local testNumber = 132
  local testFunction = function() end
  local testClass = class.build()
  testClass._init = function(...)
    local args = {...}
    luaunit.assertIsTable(args[1])
    luaunit.assertNotEquals(args[1], testClass)
    luaunit.assertEquals(args[2], testString)
    luaunit.assertEquals(args[3], testNumber)
    luaunit.assertEquals(args[4], testFunction)
  end

  testClass(testString, testNumber, testFunction)
end

function TestClass:test_build_thenInvokeMemberMethod_didInvoke()
  local testClass = class.build()
  local invokeCount = 0
  testClass.myMethod = function()
    invokeCount = invokeCount + 1
  end

  testClass().myMethod()

  luaunit.assertEquals(invokeCount, 1)
end

os.exit(luaunit.LuaUnit.run())
