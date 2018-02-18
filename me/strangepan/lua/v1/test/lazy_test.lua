local luaunit = require 'luaunit'
local lazy = require 'me.strangepan.lua.v1.lazy'

TestClass = {}
local test_requirement = 'my.custom.requirement'
local test_result = {x = 132}
local test_requirement_invalid = {test_requirement}

function TestClass:setUp()
  self.invocation_count = 0
  lazy.require_function = function(requirement)
    self.invocation_count = self.invocation_count + 1
    self.last_requirement = requirement
    return test_result
  end
end

function TestClass:test_init_withString_didNotRequire()
  lazy(test_requirement)

  luaunit.assertEquals(self.invocation_count, 0)
end

function TestClass:test_init_withTable_didThrowError()
  luaunit.assertError(lazy, test_requirement_invalid)
end

function TestClass:test_get_didInvokeRequire()
  local under_test = lazy(test_requirement)

  under_test:get()

  luaunit.assertEquals(self.invocation_count, 1)
  luaunit.assertEquals(self.last_requirement, test_requirement)
end

function TestClass:test_getTwice_didInvokeRequireTwice()
  local under_test = lazy(test_requirement)

  under_test:get()
  under_test:get()

  luaunit.assertEquals(self.invocation_count, 2)
  luaunit.assertEquals(self.last_requirement, test_requirement)
end

function TestClass:test_get_didReturnResult()
  local under_test = lazy(test_requirement)

  luaunit.assertEquals(under_test:get(), test_result)
end

function TestClass:test_invoke_didInvokeRequire()
  local under_test = lazy(test_requirement)

  under_test()

  luaunit.assertEquals(self.invocation_count, 1)
  luaunit.assertEquals(self.last_requirement, test_requirement)
end

function TestClass:test_invokeTwice_didInvokeRequireTwice()
  local under_test = lazy(test_requirement)

  under_test()
  under_test()

  luaunit.assertEquals(self.invocation_count, 2)
  luaunit.assertEquals(self.last_requirement, test_requirement)
end

function TestClass:test_invoke_didReturnResult()
  local under_test = lazy(test_requirement)

  luaunit.assertEquals(under_test(), test_result)
end

os.exit(luaunit.LuaUnit.run())
