local luaunit = require 'luaunit'
local dig = require 'me.strangepan.libs.computercraft.turtle.v1.dig'
local mock_turtle = require 'me.strangepan.libs.computercraft.mock.v1.turtle'

TestObject = {}

function TestObject:setup()
  self._system_turtle = turtle
  turtle = mock_turtle.builder():build()

  self.under_test = dig()
end

function TestObject:teardown()
  self._system_turtle = turtle
end

function TestObject:test_forward_didInvokeDig()
  local invocation_count = 0
  function turtle.dig()
    invocation_count = invocation_count + 1
  end

  self.under_test:forward()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_forward_didReturnSelf()
  luaunit.assertIs(self.under_test:forward(), self.under_test)
end

function TestObject:test_forward_whenDigReturnsTrue_didReturnTrue()
  function turtle.dig() return true end

  local _,result = self.under_test:forward()

  luaunit.assertTrue(result)
end

function TestObject:test_forward_whenDigReturnsFalse_didReturnFalse()
  function turtle.dig() return false end

  local _,result = self.under_test:forward()

  luaunit.assertFalse(result)
end

function TestObject:test_up_didInvokeDigUp()
  local invocation_count = 0
  function turtle.digUp()
    invocation_count = invocation_count + 1
  end

  self.under_test:up()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_up_didReturnSelf()
  luaunit.assertIs(self.under_test:up(), self.under_test)
end

function TestObject:test_up_whenDigUpReturnsTrue_didReturnTrue()
  function turtle.digUp() return true end

  local _,result = self.under_test:up()

  luaunit.assertTrue(result)
end

function TestObject:test_up_whenDigUpReturnsFalse_didReturnFalse()
  function turtle.digUp() return false end

  local _,result = self.under_test:up()

  luaunit.assertFalse(result)
end

function TestObject:test_down_didInvokeDigDown()
  local invocation_count = 0
  function turtle.digDown()
    invocation_count = invocation_count + 1
  end

  self.under_test:down()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_down_didReturnSelf()
  luaunit.assertIs(self.under_test:down(), self.under_test)
end

function TestObject:test_down_whenDigDownReturnsTrue_didReturnTrue()
  function turtle.digDown() return true end

  local _,result = self.under_test:down()

  luaunit.assertTrue(result)
end

function TestObject:test_down_whenDigDownReturnsFalse_didReturnFalse()
  function turtle.digDown() return false end

  local _,result = self.under_test:down()

  luaunit.assertFalse(result)
end

os.exit(luaunit.LuaUnit.run())
