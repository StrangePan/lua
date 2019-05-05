local PlayerController = require "me.strangepan.games.mazerino.common.PlayerController"
local CommandMap = require "me.strangepan.games.mazerino.common.CommandMap"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local class = require "me.strangepan.libs.util.v1.class"
local CommandType = require "me.strangepan.games.mazerino.common.CommandType"

local LocalPlayerController = class.build(PlayerController)

function LocalPlayerController:_init(player, commandMap)
  class.superclass(LocalPlayerController)._init(self, player)
  self:setCommandMap(commandMap)
end

function LocalPlayerController:setCommandMap(commandMap)
  if commandMap then
    assert_that(commandMap):is_instance_of(CommandMap):and_return()
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

return LocalPlayerController
