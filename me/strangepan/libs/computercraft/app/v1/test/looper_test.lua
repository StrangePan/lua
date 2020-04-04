local luaunit = require 'luaunit'
local mock_os = require 'me.strangepan.libs.computercraft.mock.v1.os'
local mock_computercraft = require 'me.strangepan.libs.computercraft.mock.v1.computercraft'
local looper = require 'me.strangepan.libs.computercraft.app.v1.looper'

TestClass = {}

function TestClass:setup()
  self.system_os = os
  self.custom_os = mock_os.builder():build_upon(self.system_os):build()
  os = self.custom_os

  self.computercraft =
    mock_computercraft.builder()
        :mock_os(self.custom_os)
        :build()
        :capture()
end

function TestClass:teardown()
  self.computercraft:release()
end

function TestClass:test_initLooper_noErrors()
  local under_test = looper.builder():build()
end

function TestClass:test_loop_withoutEvents_yields()
  local under_test = looper.builder():build()
  local co = coroutine.create(function() under_test:loop() end)

  coroutine.resume(co)

  luaunit.assert_equals(coroutine.status(co), 'suspended')
end

function TestClass:test_loop_withTestEvent_invokesCallback()
  local invocations = 0
  local callback = function()
    invocations = invocations + 1
  end

  local under_test =
      looper.builder()
          :callbacks{test = callback}
          :build()
  self.custom_os.queueEvent('test')

  local co = coroutine.create(function() under_test:loop() end)

  coroutine.resume(co)

  luaunit.assert_equals(invocations, 1)
end

function TestClass:test_loop_withTestEventData_invokesCallbackWithData()
  local event_data = nil
  local callback = function(...)
    event_data = {...}
  end

  local under_test =
      looper.builder()
          :callbacks{test = callback}
          :build()
  self.custom_os.queueEvent('test', 1, 2, 3)

  local co = coroutine.create(function() under_test:loop() end)

  coroutine.resume(co)

  luaunit.assert_equals(event_data, {1, 2, 3})
end

function TestClass:test_loop_withTerminateEvent_terminates()
  local under_test = looper.builder():build()
  self.custom_os.queueEvent('terminate')

  local co = coroutine.create(function() under_test:loop() end)

  coroutine.resume(co)

  luaunit.assert_equals(coroutine.status(co), 'dead')
end

function TestClass:test_loop_withTerminateEvent_withCallback_invokesCallback()
  local invocations = 0
  local callback = function(...)
    invocations = invocations + 1
  end

  local under_test =
      looper.builder()
          :callbacks{terminate = callback}
          :build()
  self.custom_os.queueEvent('terminate')

  local co = coroutine.create(function() under_test:loop() end)

  coroutine.resume(co)

  luaunit.assert_equals(invocations, 1)
  luaunit.assert_equals(coroutine.status(co), 'dead')
end

function TestClass:test_loop_withCustomDieOn_terminates()
  local under_test =
      looper.builder()
          :die_on{'terminate', 'test'}
          :build()
  self.custom_os.queueEvent('test')

  local co = coroutine.create(function() under_test:loop() end)

  coroutine.resume(co)

  luaunit.assert_equals(coroutine.status(co), 'dead')
end

os.exit(luaunit.LuaUnit.run())
