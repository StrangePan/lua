local Game = require "me.strangepan.games.mazerino.common.Game"
local type = require "me.strangepan.games.mazerino.common.strangepan.util.type"
local ConnectionManager = require "me.strangepan.games.mazerino.common.networking.ConnectionManager"
local NetworkedEntityManager = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityManager"

local NetworkGame = class.build(Game)

function NetworkGame:_init(secretary, connectionManager, entityManager)
  class.superclass(NetworkGame)._init(self, secretary)
  self.connections = assertClass(connectionManager, ConnectionManager)
  self.entities = assertClass(entityManager, NetworkedEntityManager)
end

function NetworkGame:start()
  class.superclass(NetworkGame).start(self)
  
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
  
  return class.superclass(NetworkGame).stop(self)
end

function NetworkGame:getConnectionManager()
  return self.connections
end

function NetworkGame:getEntityManager()
  return self.entities
end

return NetworkGame
