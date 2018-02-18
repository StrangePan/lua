require "strangepan.util.type"
require "networking.CustomNetworkedEntityManager"
require "ClientConnectionManager"

local F_NETWORK_ENTITY_ID = "i"

--
-- Client-specific entity manager. Ignores updates from anyone other than the
-- server.
--
ClientNetworkedEntityManager = buildClass(CustomNetworkedEntityManager)
local Class = ClientNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
  assertClass(connectionManager, ClientConnectionManager, "connectionManager")
end

function Class:onReceiveEntityUpdate(message, connectionId)
  local server = self.connectionManager:getServerConnection()

  -- Ignore any incoming messages from anyone other than the server
  if not server or server.id ~= connectionId then
    return
  end

  return Class.superclass.onReceiveEntityUpdate(self, message, connectionId)
end

function Class:onReceiveEntityInc(message, connectionId)
  local entity = self:getEntity(message[F_NETWORK_ENTITY_ID])

  if Class.superclass.onReceiveEntityInc(self, message, connectionId)
      and entity
      and not self:_isInSync(connectionId, entity) then
    self:_sendEntityUpdate(
        entity, EntityUpdateType.OUT_OF_SYNC, nil, connectionId)
  end
end
