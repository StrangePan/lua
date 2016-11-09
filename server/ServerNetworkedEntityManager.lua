require "common/functions"
require "CustomNetworkedEntityManager"
require "Connection"
require "ServerConnectionManager"
require "ConnectionStatus"

ServerNetworkedEntityManager = buildClass(CustomNetworkedEntityManager)
local Class = ServerNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
  assertType(connectionManager, "connectionManager", ServerConnectionManager)
  connectionManager:registerConnectionStatusListener(
    self,
    self.onConnectionStatusChanged)
end

--
-- Sends entity updates when connection status changes.
--
function Class:onConnectionStatusChanged(manager, connectionId, oldStatus)
  local newStatus = manager:getConnection(connectionId).status
  if newStatus == ConnectionStatus.CONNECTED then
    if oldStatus == ConnectionStatus.STALLED then
      for entity in self:allEntities() do
        self.connectionManager:sendMessageWithAck(
            messages.entityUpdate.sync(
                entity:getNetworkId(),
                entity:getEntityType(),
                entity:getSynchronizedState()),
            self:buildEntityChannelString(entity),
            connectionId)
      end
    else
      for entity in self:allEntities() do
        self.connectionManager:sendMessageWithAck(
            messages.entityUpdate.create(
                entity:getNetworkId(),
                entity:getEntityType(),
                entity:getInstantiationParams()),
            self:buildEntityChannelString(entity),
            connectionId)
      end
    end
  end
end
