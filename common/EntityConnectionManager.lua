require "Entity"
require "ConnectionManager"

--
-- Class that manages network events according to a Secretary event manager.
--
EntityConnectionManager = buildClass(Entity)
local Class = EntityConnectionManager

function Class:_init(connectionManager)
  Class.superclass._init(self)
  assertType(connectionManager, "connectionManager", ConnectionManager)
  self.connectionManager = connectionManager
end

function Class:registerWithSecretary(secretary)
  Class.superclass.registerWithSecretary(self, secretary)
  
  secretary:registerEventListener(self, self.onPreStep, EventType.PRE_STEP)
  secretary:registerEventListener(self, self.onShutdown, EventType.SHUTDOWN)
  secretary:registerEventListener(self, self.onDestroy, EventType.DESTROY, self)
  
  return self
end

function Class:onPreStep()
  self.connectionManager:receiveAllMessages()
end

function Class:onShutdown()
  self.connectionManager:terminateAllConnections()
end

function Class:onDestroy(entity)
  if entity ~= self then return end
  self:onShutdown()
  self.connectionManager = nil
end
