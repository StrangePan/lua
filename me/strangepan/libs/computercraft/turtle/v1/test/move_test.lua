local luaunit = require 'luaunit'
local mock_turtle = require 'me.strangepan.libs.computercraft.mock.v1.turtle'
local move = require 'me.strangepan.libs.computercraft.turtle.v1.move'

TestObject = {}

function TestObject:setup()
  self._system_turtle = turtle
  turtle = mock_turtle.builder():build()

  self.under_test = move()
end

function TestObject:teardown()
  turtle = self._system_turtle
end


-- Forward

function TestObject:test_forward_didReturnSelf()
  luaunit.assertIs(self.under_test:forward(), self.under_test)
end

function TestObject:test_forward_didInvokeForward()
  local invocation_count = 0
  function turtle.forward()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:forward()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_forward_with10_didInvokeForward10Times()
  local invocation_count = 0
  function turtle.forward()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:forward(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_forward_with10_didReturn10()
  local _,result = self.under_test:forward(10)

  luaunit.assertEquals(result, 10)
end

function TestObject:test_forward_with10_whenFailsAfter5_didInvokeForward10Times()
  local invocation_count = 0
  function turtle.forward()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  self.under_test:forward(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_forward_with10_whenFailsAfter5_didReturn5()
  local invocation_count = 0
  function turtle.forward()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  local _,result = self.under_test:forward(10)

  luaunit.assertEquals(result, 5)
end


-- Backward

function TestObject:test_backward_didReturnSelf()
  luaunit.assertIs(self.under_test:backward(), self.under_test)
end

function TestObject:test_backward_didInvokeBack()
  local invocation_count = 0
  function turtle.back()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:backward()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_backward_with10_didInvokeBack10Times()
  local invocation_count = 0
  function turtle.back()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:backward(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_backward_with10_didReturn10()
  local _,result = self.under_test:backward(10)

  luaunit.assertEquals(result, 10)
end

function TestObject:test_backward_with10_whenFailsAfter5_didInvokeBack10Times()
  local invocation_count = 0
  function turtle.back()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  self.under_test:backward(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_backward_with10_whenFailsAfter5_didReturn5()
  local invocation_count = 0
  function turtle.back()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  local _,result = self.under_test:backward(10)

  luaunit.assertEquals(result, 5)
end


-- Up

function TestObject:test_up_didReturnSelf()
  luaunit.assertIs(self.under_test:up(), self.under_test)
end

function TestObject:test_up_didInvokeUp()
  local invocation_count = 0
  function turtle.up()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:up()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_up_with10_didInvokeUp10Times()
  local invocation_count = 0
  function turtle.up()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:up(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_up_with10_didReturn10()
  local _,result = self.under_test:up(10)

  luaunit.assertEquals(result, 10)
end

function TestObject:test_up_with10_whenFailsAfter5_didInvokeUp10Times()
  local invocation_count = 0
  function turtle.up()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  self.under_test:up(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_up_with10_whenFailsAfter5_didReturn5()
  local invocation_count = 0
  function turtle.up()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  local _,result = self.under_test:up(10)

  luaunit.assertEquals(result, 5)
end


-- Down

function TestObject:test_down_didReturnSelf()
  luaunit.assertIs(self.under_test:down(), self.under_test)
end

function TestObject:test_down_didInvokeDown()
  local invocation_count = 0
  function turtle.down()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:down()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_down_with10_didInvokeDown10Times()
  local invocation_count = 0
  function turtle.down()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:down(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_down_with10_didReturn10()
  local _,result = self.under_test:down(10)

  luaunit.assertEquals(result, 10)
end

function TestObject:test_down_with10_whenFailsAfter5_didInvokeDown10Times()
  local invocation_count = 0
  function turtle.down()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  self.under_test:down(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_down_with10_whenFailsAfter5_didReturn5()
  local invocation_count = 0
  function turtle.down()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  local _,result = self.under_test:down(10)

  luaunit.assertEquals(result, 5)
end


-- Left

function TestObject:test_left_didReturnSelf()
  luaunit.assertIs(self.under_test:left(), self.under_test)
end

function TestObject:test_left_didInvokeTurnLeft()
  local invocation_count = 0
  function turtle.turnLeft()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:left()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_left_with10_didInvokeTurnLeft10Times()
  local invocation_count = 0
  function turtle.turnLeft()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:left(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_left_with10_didReturn10()
  local _,result = self.under_test:left(10)

  luaunit.assertEquals(result, 10)
end

function TestObject:test_left_with10_whenFailsAfter5_didInvokeTurnLeft10Times()
  local invocation_count = 0
  function turtle.turnLeft()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  self.under_test:left(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_left_with10_whenFailsAfter5_didReturn5()
  local invocation_count = 0
  function turtle.turnLeft()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  local _,result = self.under_test:left(10)

  luaunit.assertEquals(result, 5)
end


-- Right

function TestObject:test_right_didReturnSelf()
  luaunit.assertIs(self.under_test:right(), self.under_test)
end

function TestObject:test_right_didInvokeTurnRight()
  local invocation_count = 0
  function turtle.turnRight()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:right()

  luaunit.assertEquals(invocation_count, 1)
end

function TestObject:test_right_with10_didInvokeTurnRight10Times()
  local invocation_count = 0
  function turtle.turnRight()
    invocation_count = invocation_count + 1
    return true
  end

  self.under_test:right(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_right_with10_didReturn10()
  local _,result = self.under_test:right(10)

  luaunit.assertEquals(result, 10)
end

function TestObject:test_right_with10_whenFailsAfter5_didInvokeTurnRight10Times()
  local invocation_count = 0
  function turtle.turnRight()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  self.under_test:right(10)

  luaunit.assertEquals(invocation_count, 10)
end

function TestObject:test_right_with10_whenFailsAfter5_didReturn5()
  local invocation_count = 0
  function turtle.turnRight()
    invocation_count = invocation_count + 1
    return invocation_count <= 5
  end

  local _,result = self.under_test:right(10)

  luaunit.assertEquals(result, 5)
end


os.exit(luaunit.LuaUnit.run())
