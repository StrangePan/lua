require "Game"
require "Secretary"
require "ConnectionManager"
require "NetworkedEntityManager"

NetworkGame = buildClass(Game)
local Class = NetworkGame

function Class:_init(secretary, connectionManager, entityManager)
  Class.superclass._init(self, secretary)
  self.connections = assertType(connectionManager, ConnectionManager)
  self.entities = assertType(entityManager, NetworkedEntityManager)
end

function Class:start()
  Class.superclass.start(self)
  
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

function Class:stop()
  local entities = self:getEntityManager()
  local connections = self:getConnectionManager()
  
  entities:destroy()
  connections:destroy()
  
  return Class.superclass.stop(self)
end

function Class:getConnectionManager()
  return self.connections
end

function Class:getEntityManager()
  return self.entities
end
