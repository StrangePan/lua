local class = require "me.strangepan.libs.util.v1.class"
local CommandType = require "me.strangepan.games.mazerino.common.CommandType"
local InputMethod = require "me.strangepan.games.mazerino.common.InputMethod"
local EventCoordinator = require "me.strangepan.games.mazerino.common.EventCoordinator"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

local CommandMap = class.build()

function CommandMap:_init()
  self.mappings = {
    commands = {},
    methods = {}
  }
  
  for commandType in ipairs(CommandType) do
    self.mappings.commands[commandType] = {coordinator = EventCoordinator()}
  end
  
  for inputMethod in ipairs(InputMethod) do
    self.mappings.methods[inputMethod] = {}
  end
end

function CommandMap:registerCommandListener(command, listener, callback)
  command = assert_that(command):is_a_number():is_a_key_in(CommandType):and_return()
  if command == nil then return end
  self.mappings.commands[command].coordinator:registerListener(listener, callback)
end

function CommandMap:onKeyboardInput(key)
  return self:onInput(InputMethod.KEYBOARD, key)
end

function CommandMap:onJoystickInput(button)
  return self:onInput(InputMethod.JOYSTICK, button)
end

function CommandMap:onMouseInput(button)
  return self:onInput(InputMethod.MOUSE, button)
end

function CommandMap:onInput(method, input)
  method = assert_that(method):is_a_number():is_a_key_in(InputMethod):and_return()
  if method == nil then return end
  local command = self.mappings.methods[method][input]
  if command == nil then return end
  self.mappings.commands[command].coordinator:notifyListeners()
end

function CommandMap:getMappedInput(command)
  local mapping = self.mappings.commands[command]
  return mapping.method, mapping.input
end

function CommandMap:getMappedCommand(method, input)
  return self.mappings.methods[method][input]
end

function CommandMap:mapCommandToKeyboardKey(commandType, key)
  self:mapCommandToInput(commandType, InputMethod.KEYBOARD, key)
end

function CommandMap:mapCommandToJoystickInput(commandType, input)
  self:mapCommandToInput(commandType, InputMethod.JOYSTICK, input)
end

function CommandMap:mapCommandToMouseButton(commandType, button)
  self:mapCommandToInput(commandType, InputMethod.MOUSE, button)
end

function CommandMap:mapCommandToInput(command, method, input)
  command = assert_that(command):is_a_number():is_a_key_in(CommandType):and_return()
  method = assert_that(method):is_a_number():is_a_key_in(InputMethod):and_return()
  if command == nil or method == nil or input == nil then return end
  self:unmapCommand(command)
  self:unmapInput(method, input)
  local commandMap = self.mappings.commands[command]
  commandMap.method = method
  commandMap.input = input
  self.mappings.methods[method][input] = command
end

function CommandMap:unmapCommand(command)
  command = assert_that(command):is_a_number():is_a_key_in(CommandType):and_return()
  if command == nil then return end
  self.mappings.commands[command].method = nil
  self.mappings.commands[command].input = nil
end

function CommandMap:unmapInput(method, input)
  self.mappings.methods[method][input] = nil
end

return CommandMap
