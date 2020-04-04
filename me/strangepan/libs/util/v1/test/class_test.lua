local luaunit = require 'luaunit'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'
local class = require 'me.strangepan.libs.util.v1.class'

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

function TestClass:test_buildSubclass_thenInvokeBaseMethod_didExecute()
  local baseClass = class.build()
  local invokeCount = 0
  local testClass = class.build(baseClass)

  baseClass.baseMethod = function() invokeCount = invokeCount + 1 end

  testClass():baseMethod()

  luaunit.assertEquals(invokeCount, 1)
end

function TestClass:test_buildImmutable_thenCreateInstance_isInstance()
  local testClass = class.build(nil, true)
  local testInstance = testClass()

  luaunit.assertNotEquals(testInstance, testClass)
  assert_that(testInstance):is_instance_of(testClass)
end

function TestClass:test_buildImmutable_thenMutateInstance_throwsError()
  local testClass = class.build(nil, true)
  local testInstance = testClass()

  luaunit.assertError(function() testInstance[0] = 'test' end)
end

os.exit(luaunit.LuaUnit.run())
