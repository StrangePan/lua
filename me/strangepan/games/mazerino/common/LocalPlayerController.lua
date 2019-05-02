require "me.strangepan.games.mazerino.common.PlayerController"
require "me.strangepan.games.mazerino.common.CommandMap"
require "me.strangepan.games.mazerino.common.strangepan.util.type"

LocalPlayerController = buildClass(PlayerController)

function LocalPlayerController:_init(player, commandMap)
  LocalPlayerController.superclass._init(self, player)
  self:setCommandMap(commandMap)
end

function LocalPlayerController:setCommandMap(commandMap)
  if commandMap then
    assertClass(commandMap, CommandMap, "commandMap")
  end
  
  if self.commandMap then
    self.commandMap:unregisterCommandListener(CommandType.MOVE_UP, self)
    self.commandMap:unregisterCommandListener(CommandType.MOVE_RIGHT, self)
    self.commandMap:unregisterCommandListener(CommandType.MOVE_DOWN, self)
    self.commandMap:unregisterCommandListener(CommandType.MOVE_LEFT, self)
    self.commandMap = nil
  end
  
  if commandMap then
    self.commandMap = commandMap
    self.commandMap:registerCommandListener(CommandType.MOVE_UP, self, self.moveUp)
    self.commandMap:registerCommandListener(CommandType.MOVE_RIGHT, self, self.moveRight)
    self.commandMap:registerCommandListener(CommandType.MOVE_DOWN, self, self.moveDown)
    self.commandMap:registerCommandListener(CommandType.MOVE_LEFT, self, self.moveLeft)
    self.commandMap:registerCommandListener(CommandType.EMOTE_SPIN, self, self.emoteSpin)
  end
end
