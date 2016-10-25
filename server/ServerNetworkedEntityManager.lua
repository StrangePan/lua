require "CustomNetworkedEntityManager"
require "Connection"
require "ConnectionManager"
require "ConnectionStatus"

ServerNetworkedEntityManager = buildClass(CustomNetworkedEntityManager)
local Class = ServerNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
end

function Class:onConnectionStatusChanged(manager, connectionId, oldStatus)
  print("onConnectionStatusChanged", manager, connectionId, oldStatus)
  Class.superclass.onConnectionStatusChanged(
      self,
      manager,
      connectionId,
      oldStatus)
  local newStatus = manager:getConnection(connectionId).status
  if newStatus == ConnectionStatus.CONNECTED
      and oldStatus ~= ConnectionStatus.STALLED then
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
