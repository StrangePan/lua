local Game = require "me.strangepan.games.mazerino.common.Game"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local ConnectionManager = require "me.strangepan.games.mazerino.common.networking.ConnectionManager"
local NetworkedEntityManager = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityManager"
local class = require "me.strangepan.libs.util.v1.class"
local EventType = require "me.strangepan.libs.secretary.v1.EventType"

local NetworkGame = class.build(Game)

function NetworkGame:_init(secretary, connectionManager, entityManager)
  Game._init(self, secretary)
  self.connections = assert_that(connectionManager):is_instance_of(ConnectionManager):and_return()
  self.entities = assert_that(entityManager):is_instance_of(NetworkedEntityManager):and_return()
end

function NetworkGame:start()
  Game.start(self)
  
  local secretary = self:getSecretary()
  local connections = self:getConnectionManager()
  local entities = self:getEntityManager()
  
  -- Hook up entity manager to secretary
  entities:registerWithSecretary(secretary)

  -- Hook up connection manager to secretary.
  secretary:registerEventListener(
    connections,
    connections.receiveAllMessages,
    EventType.PRE_STEP)
  secretary:registerEventListener(
    connections,
    connections.terminateAllConnections,
    EventType.SHUTDOWN)

  return self
end

function NetworkGame:stop()
  local entities = self:getEntityManager()
  local connections = self:getConnectionManager()
  
  entities:destroy()
  connections:destroy()
  
  return Game.stop(self)
end

function NetworkGame:getConnectionManager()
  return self.connections
end

function NetworkGame:getEntityManager()
  return self.entities
end

return NetworkGame
