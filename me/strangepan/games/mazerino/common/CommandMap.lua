require "me.strangepan.games.mazerino.common.strangepan.util.class"
require "me.strangepan.games.mazerino.common.CommandType"
require "me.strangepan.games.mazerino.common.InputMethod"
require "me.strangepan.games.mazerino.common.EventCoordinator"

CommandMap = buildClass()

function CommandMap:_init()
  self.mappings = {
    commands = {},
    methods = {}
  }
  
  for commandType in CommandType.values() do
    self.mappings.commands[commandType] = {coordinator = EventCoordinator()}
  end
  
  for inputMethod in InputMethod.values() do
    self.mappings.methods[inputMethod] = {}
  end
end

function CommandMap:registerCommandListener(command, listener, callback)
  command = CommandType.fromId(command)
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
  method = InputMethod.fromId(method)
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
  command = CommandType.fromId(command)
  method = InputMethod.fromId(method)
  if command == nil or method == nil or input == nil then return end
  self:unmapCommand(command)
  self:unmapInput(method, input)
  local commandMap = self.mappings.commands[command]
  commandMap.method = method
  commandMap.input = input
  self.mappings.methods[method][input] = command
end

function CommandMap:unmapCommand(command)
  command = CommandType.fromId(command)
  if command == nil then return end
  self.mappings.commands[command].method = nil
  self.mappings.commands[command].input = nil
end

function CommandMap:unmapInput(method, input)
  self.mappings.methods[method][input] = nil
end
