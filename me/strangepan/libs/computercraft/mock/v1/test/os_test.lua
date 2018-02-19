local luaunit = require 'luaunit'
local mock_os = require 'me.strangepan.libs.computercraft.mock.v1.os'

TestClass = {}

function TestClass:setup()
  self.base_os = {}
  self.sleep_invocation_count = 0
  self.base_os.sleep = function()
    self.sleep_invocation_count = self.sleep_invocation_count + 1
  end

  self.foo_invocation_count = 0
  self.base_os.foo = function()
    self.foo_invocation_count = self.foo_invocation_count + 1
  end

  self.under_test = mock_os.builder():build_upon(self.base_os):build()
end

function TestClass:test_sleep_didNotInvoke()
  self.under_test.sleep(0.5)

  luaunit.assertEquals(self.sleep_invocation_count, 0)
end

function TestClass:test_foo_didInvoke()
  self.under_test.foo()

  luaunit.assertEquals(self.foo_invocation_count, 1)
end

os.exit(luaunit.LuaUnit.run())
