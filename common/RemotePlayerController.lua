require "PlayerController"
require "strangepan.util.Queue"

RemotePlayerController = buildClass(PlayerController)
local Class = RemotePlayerController

function Class:_init(player, connection)
  self.movementDelay = 0.25
  self.movementQueue = Queue()
  self.lastMovement = nil
  self:setConnection(connection)
end

function Class:setConnection(connection)
  if connection ~= nil then
    assertType(connection, "connection", ConnectionManager)
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

function Class:setPlayerId(id)
  self.playerId = id
end

function Class:onReceivePlayerMoveMessage(message)
  if message.id == player.id then
    self.movementQueue:push(message.direction)
  end
end

function Class:onStep()
  if self:getPlayer() ~= nil and
      self.movementQueue:empty() ~= false and
      (self.lastMovement ~= nil or
      love.timer.getTime() - self.lastMovement >= self.movementDelay) then
    self:getPlayer():move(self.movementQueue:pop(), true)
    self.lastMovement = love.timer.getTime()
  end
end
