luaunit = require 'luaunit'
turtle = require 'me.strangepan.libs.computercraft.mock.v1.turtle'

TestClass = {}
os.sleep = function() end

function TestClass:setUp()
  turtle.verbose = true
  turtle.delay = 0
  turtle._reset()

  self.system_print = print
  self.messageQueue = {}
  --noinspection GlobalCreationOutsideO
  print = function(message)
    table.insert(self.messageQueue, message)
  end
end

function TestClass:teardown()
  --noinspection GlobalCreationOutsideO
  print = self.system_print
end

function TestClass:test_forward()
  turtle.forward()
  self:assertEnqueuedMessages('forward  (0,0,-1) NORTH')
end

function TestClass:test_forward_forward()
  turtle.forward()
  turtle.forward()
  self:assertEnqueuedMessages('forward  (0,0,-1) NORTH', 'forward  (0,0,-2) NORTH')
end

function TestClass:test_back()
  turtle.back()
  self:assertEnqueuedMessages('back  (0,0,1) NORTH')
end

function TestClass:assertEnqueuedMessages(...)
  local messages = {... }
  luaunit.assertEquals(#self.messageQueue, #messages)
  for i,message in ipairs(messages) do
    luaunit.assertEquals(self.messageQueue[i], message)
  end
end

os.exit(luaunit.LuaUnit.run())
