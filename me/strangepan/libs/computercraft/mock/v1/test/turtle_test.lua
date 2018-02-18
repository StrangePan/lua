local luaunit = require 'luaunit'
local mock_turtle = require 'me.strangepan.libs.computercraft.mock.v1.turtle'
local mock_os = require 'me.strangepan.libs.computercraft.mock.v1.os'

TestClass = {}

function TestClass:setup()
  self.system_print = print
  self.messageQueue = {}
  self.custom_print = function(message)
    table.insert(self.messageQueue, message)
  end
  --noinspection GlobalCreationOutsideO
  print = self.custom_print

  self.system_os = os
  self.custom_os = mock_os.mocker():build_upon(self.system_os):build_mocks()
  --noinspection GlobalCreationOutsideO
  os = self.custom_os

  self.under_test = mock_turtle.mocker():enable_print_status(true):delay(0):build_mocks()
end

function TestClass:teardown()
  --noinspection GlobalCreationOutsideO
  os = self.system_os or os
  --noinspection GlobalCreationOutsideO
  print = self.system_print or print
end

function TestClass:test_forward_didReturnTrue()
  luaunit.assertTrue(self.under_test.forward())
end

function TestClass:test_forward_whenFacingNorth_didPrintStatus()
  self.under_test.forward()

  self:assert_enqueued_messages('forward  (0,0,-1) NORTH')
end

function TestClass:test_forward_whenFacingEast_didPrintStatus()
  self.under_test.turnRight()

  self.under_test.forward()

  self:assert_enqueued_messages('forward  (1,0,0) EAST')
end

function TestClass:test_forward_whenFacingSouth_didPrintStatus()
  self.under_test.turnRight()
  self.under_test.turnRight()

  self.under_test.forward()

  self:assert_enqueued_messages('forward  (0,0,1) SOUTH')
end

function TestClass:test_forward_whenFacingWest_didPrintStatus()
  self.under_test.turnLeft()

  self.under_test.forward()

  self:assert_enqueued_messages('forward  (-1,0,0) WEST')
end

function TestClass:test_back_didReturnTrue()
  luaunit.assertTrue(self.under_test.back())
end

function TestClass:test_back_whenFacingNorth_didPrintStatus()
  self.under_test.back()

  self:assert_enqueued_messages('back  (0,0,1) NORTH')
end

function TestClass:test_back_whenFacingEast_didPrintStatus()
  self.under_test.turnRight()

  self.under_test.back()

  self:assert_enqueued_messages('back  (-1,0,0) EAST')
end

function TestClass:test_back_whenFacingSouth_didPrintStatus()
  self.under_test.turnRight()
  self.under_test.turnRight()

  self.under_test.back()

  self:assert_enqueued_messages('back  (0,0,-1) SOUTH')
end

function TestClass:test_back_whenFacingWest_didPrintStatus()
  self.under_test.turnLeft()

  self.under_test.back()

  self:assert_enqueued_messages('back  (1,0,0) WEST')
end

function TestClass:test_up_didReturnTrue()
  luaunit.assertTrue(self.under_test.up())
end

function TestClass:test_up_whenFacingNorth_didPrintStatus()
  self.under_test.up()

  self:assert_enqueued_messages('up  (0,1,0) NORTH')
end

function TestClass:test_up_whenFacingEast_didPrintStatus()
  self.under_test.turnRight()

  self.under_test.up()

  self:assert_enqueued_messages('up  (0,1,0) EAST')
end

function TestClass:test_up_whenFacingSouth_didPrintStatus()
  self.under_test.turnRight()
  self.under_test.turnRight()

  self.under_test.up()

  self:assert_enqueued_messages('up  (0,1,0) SOUTH')
end

function TestClass:test_up_whenFacingWest_didPrintStatus()
  self.under_test.turnLeft()

  self.under_test.up()

  self:assert_enqueued_messages('up  (0,1,0) WEST')
end

function TestClass:test_down_didReturnTrue()
  luaunit.assertTrue(self.under_test.down())
end

function TestClass:test_down_whenFacingNorth_didPrintStatus()
  self.under_test.down()

  self:assert_enqueued_messages('down  (0,-1,0) NORTH')
end

function TestClass:test_down_whenFacingEast_didPrintStatus()
  self.under_test.turnRight()

  self.under_test.down()

  self:assert_enqueued_messages('down  (0,-1,0) EAST')
end

function TestClass:test_down_whenFacingSouth_didPrintStatus()
  self.under_test.turnRight()
  self.under_test.turnRight()

  self.under_test.down()

  self:assert_enqueued_messages('down  (0,-1,0) SOUTH')
end

function TestClass:test_down_whenFacingWest_didPrintStatus()
  self.under_test.turnLeft()

  self.under_test.down()

  self:assert_enqueued_messages('down  (0,-1,0) WEST')
end

function TestClass:test_turnLeft_didReturnTrue()
  luaunit.assertTrue(self.under_test.turnLeft())
end

function TestClass:test_turnLeft_whenFacingNorth_didPrintStatus()
  self.under_test.turnLeft()

  self:assert_enqueued_messages('turnLeft  (0,0,0) WEST')
end

function TestClass:test_turnLeft_whenFacingEast_didPrintStatus()
  self.under_test.turnRight()

  self.under_test.turnLeft()

  self:assert_enqueued_messages('turnLeft  (0,0,0) NORTH')
end

function TestClass:test_turnLeft_whenFacingSouth_didPrintStatus()
  self.under_test.turnRight()
  self.under_test.turnRight()

  self.under_test.turnLeft()

  self:assert_enqueued_messages('turnLeft  (0,0,0) EAST')
end

function TestClass:test_turnLeft_whenFacingWest_didPrintStatus()
  self.under_test.turnLeft()

  self.under_test.turnLeft()

  self:assert_enqueued_messages('turnLeft  (0,0,0) SOUTH')
end

function TestClass:test_turnRight_didReturnTrue()
  luaunit.assertTrue(self.under_test.turnRight())
end

function TestClass:test_turnRight_whenFacingNorth_didPrintStatus()
  self.under_test.turnRight()

  self:assert_enqueued_messages('turnRight  (0,0,0) EAST')
end

function TestClass:test_turnRight_whenFacingEast_didPrintStatus()
  self.under_test.turnRight()

  self.under_test.turnRight()

  self:assert_enqueued_messages('turnRight  (0,0,0) SOUTH')
end

function TestClass:test_turnRight_whenFacingSouth_didPrintStatus()
  self.under_test.turnRight()
  self.under_test.turnRight()

  self.under_test.turnRight()

  self:assert_enqueued_messages('turnRight  (0,0,0) WEST')
end

function TestClass:test_turnRight_whenFacingWest_didPrintStatus()
  self.under_test.turnLeft()

  self.under_test.turnRight()

  self:assert_enqueued_messages('turnRight  (0,0,0) NORTH')
end

function TestClass:test_dig_didReturnTrue()
  luaunit.assertTrue(self.under_test.dig())
end

function TestClass:test_dig_didPrintStatus()
  self.under_test.dig()

  self:assert_enqueued_messages('dig  (0,0,0) NORTH')
end

function TestClass:test_digUp_didReturnTrue()
  luaunit.assertTrue(self.under_test.digUp())
end

function TestClass:test_digUp_didPrintStatus()
  self.under_test.digUp()

  self:assert_enqueued_messages('digUp  (0,0,0) NORTH')
end

function TestClass:test_digDown_didReturnTrue()
  luaunit.assertTrue(self.under_test.digDown())
end

function TestClass:test_digDown_didPrintStatus()
  self.under_test.digDown()

  self:assert_enqueued_messages('digDown  (0,0,0) NORTH')
end


-- More complicated movements

function TestClass:test_clockwiseSpin_didPrintStatus()
  self.under_test.turnRight()
  self.under_test.turnRight()
  self.under_test.turnRight()
  self.under_test.turnRight()

  self:assert_enqueued_messages(
      'turnRight  (0,0,0) EAST',
      'turnRight  (0,0,0) SOUTH',
      'turnRight  (0,0,0) WEST',
      'turnRight  (0,0,0) NORTH')
end

function TestClass:test_counterclockwiseSpin_didPrintStatus()
  self.under_test.turnLeft()
  self.under_test.turnLeft()
  self.under_test.turnLeft()
  self.under_test.turnLeft()

  self:assert_enqueued_messages(
    'turnLeft  (0,0,0) WEST',
    'turnLeft  (0,0,0) SOUTH',
    'turnLeft  (0,0,0) EAST',
    'turnLeft  (0,0,0) NORTH')
end

function TestClass:test_clockwiseLoop_didPrintStatus()
  self.under_test.turnRight()
  self.under_test.forward()
  self.under_test.turnRight()
  self.under_test.forward()
  self.under_test.turnRight()
  self.under_test.forward()
  self.under_test.turnRight()
  self.under_test.forward()

  self:assert_enqueued_messages(
      'turnRight  (0,0,0) EAST',
      'forward  (1,0,0) EAST',
      'turnRight  (1,0,0) SOUTH',
      'forward  (1,0,1) SOUTH',
      'turnRight  (1,0,1) WEST',
      'forward  (0,0,1) WEST',
      'turnRight  (0,0,1) NORTH',
      'forward  (0,0,0) NORTH')
end

function TestClass:test_counterclockwiseLoop_didPrintStatus()
  self.under_test.turnLeft()
  self.under_test.forward()
  self.under_test.turnLeft()
  self.under_test.forward()
  self.under_test.turnLeft()
  self.under_test.forward()
  self.under_test.turnLeft()
  self.under_test.forward()

  self:assert_enqueued_messages(
      'turnLeft  (0,0,0) WEST',
      'forward  (-1,0,0) WEST',
      'turnLeft  (-1,0,0) SOUTH',
      'forward  (-1,0,1) SOUTH',
      'turnLeft  (-1,0,1) EAST',
      'forward  (0,0,1) EAST',
      'turnLeft  (0,0,1) NORTH',
      'forward  (0,0,0) NORTH')
end


-- Helpers

function TestClass:assert_enqueued_messages(...)
  local expected_messages = {...}
  local length_diff = #self.messageQueue - #expected_messages
  luaunit.assertTrue(length_diff >= 0)
  for i,message in ipairs(expected_messages) do
    luaunit.assertEquals(self.messageQueue[length_diff + i], message)
  end
end

os.exit(luaunit.LuaUnit.run())
