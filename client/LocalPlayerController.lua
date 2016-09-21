require "common/class"
require "Player"
require "CommandMap"
require "Direction"

LocalPlayerController = buildClass()

function LocalPlayerController:_init(player, commandMap)
  self:setPlayer(player)
  self:setCommandMap(commandMap)
end

function LocalPlayerController:setPlayer(player)
  if player ~= nil then
    assertType(player, "player", Player)
  end
  
  if self.player ~= nil then
    self.player = nil
  end
  
  if player ~= nil then
    self.player = player
  end
end

function LocalPlayerController:setCommandMap(commandMap)
  if commandMap ~= nil then
    assertType(commandMap, "commandMap", CommandMap)
  end
  
  if self.commandMap ~= nil then
    self.commandMap:unregisterCommandListener(CommandType.MOVE_UP, self)
    self.commandMap:unregisterCommandListener(CommandType.MOVE_RIGHT, self)
    self.commandMap:unregisterCommandListener(CommandType.MOVE_DOWN, self)
    self.commandMap:unregisterCommandListener(CommandType.MOVE_LEFT, self)
    self.commandMap = nil
  end
  
  if commandMap ~= nil then
    self.commandMap = commandMap
    self.commandMap:registerCommandListener(CommandType.MOVE_UP, self, self.moveUp)
    self.commandMap:registerCommandListener(CommandType.MOVE_RIGHT, self, self.moveRight)
    self.commandMap:registerCommandListener(CommandType.MOVE_DOWN, self, self.moveDown)
    self.commandMap:registerCommandListener(CommandType.MOVE_LEFT, self, self.moveLeft)
    self.commandMap:registerCommandListener(CommandType.EMOTE_SPIN, self, self.emoteSpin)
  end
end

function LocalPlayerController:moveUp()
  return self:move(Direction.UP)
end

function LocalPlayerController:moveRight()
  return self:move(Direction.RIGHT)
end

function LocalPlayerController:moveDown()
  return self:move(Direction.DOWN)
end

function LocalPlayerController:moveLeft()
  return self:move(Direction.LEFT)
end

function LocalPlayerController:move(direction)
  direction = Direction.fromId(direction)
  if direction == nil then return false end
  if self:isBoundToPlayer() == false then return false end
  return self.player:move(direction)
end

function LocalPlayerController:emoteSpin()
  if self:isBoundToPlayer() == false then return false end
  return self.player:spin()
end
