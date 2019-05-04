local PlayerController = require "me.strangepan.games.mazerino.common.PlayerController"
local Queue = require "me.strangepan.games.mazerino.common.strangepan.util.Queue"
local assert_that = require "me.strangepan.libs.lua.truth.v1.assert_that"

local RemotePlayerController = class.build(PlayerController)

function RemotePlayerController:_init(player, connection)
  self.movementDelay = 0.25
  self.movementQueue = Queue()
  self.lastMovement = nil
  self:setConnection(connection)
end

function RemotePlayerController:setConnection(connection)
  if connection ~= nil then
    assert_that(connection):is_instance_of(ConnectionManager):and_return()
  end
  
  if self.connection ~= nil then
    self.connection:unregisterMessageListener(MessageType.PLAYER_MOVE, self)
    self.connection = nil
  end
  
  if connection ~= nil then
    self.connection = connection
    self.connection:registerMessageListener(MessageType.PLAYER_MOVE,
      self,
      self.onReceivePlayerMoveMessage)
  end
end

function RemotePlayerController:setPlayerId(id)
  self.playerId = id
end

function RemotePlayerController:onReceivePlayerMoveMessage(message)
  if message.id == player.id then
    self.movementQueue:push(message.direction)
  end
end

function RemotePlayerController:onStep()
  if self:getPlayer() ~= nil and
      self.movementQueue:empty() ~= false and
      (self.lastMovement ~= nil or
      love.timer.getTime() - self.lastMovement >= self.movementDelay) then
    self:getPlayer():move(self.movementQueue:pop(), true)
    self.lastMovement = love.timer.getTime()
  end
end

return RemotePlayerController
