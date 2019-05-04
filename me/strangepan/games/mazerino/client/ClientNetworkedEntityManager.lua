local ClientConnectionManager = require "me.strangepan.games.mazerino.client.ClientConnectionManager"
local CustomNetworkedEntityManager = require "me.strangepan.games.mazerino.common.networking.CustomNetworkedEntityManager"
local assert_that = require "me.strangepan.libs.lua.truth.v1.assert_that"
local class = require "me.strangepan.libs.lua.v1.class"
local EntityUpdateType = require "me.strangepan.games.mazerino.common.networking.EntityUpdateType"

local F_NETWORK_ENTITY_ID = "i"

--
-- Client-specific entity manager. Ignores updates from anyone other than the
-- server.
--
local ClientNetworkedEntityManager = class.build(CustomNetworkedEntityManager)

function ClientNetworkedEntityManager:_init(connectionManager)
  CustomNetworkedEntityManager._init(self, connectionManager)
  assert_that(connectionManager):is_instance_of(ClientConnectionManager)
end

function ClientNetworkedEntityManager:onReceiveEntityUpdate(message, connectionId)
  local server = self.connectionManager:getServerConnection()

  -- Ignore any incoming messages from anyone other than the server
  if not server or server.id ~= connectionId then
    return
  end

  return class.superclass(ClientNetworkedEntityManager).onReceiveEntityUpdate(self, message, connectionId)
end

function ClientNetworkedEntityManager:onReceiveEntityInc(message, connectionId)
  local entity = self:getEntity(message[F_NETWORK_ENTITY_ID])

  if class.superclass(ClientNetworkedEntityManager).onReceiveEntityInc(self, message, connectionId)
      and entity
      and not self:_isInSync(connectionId, entity) then
    self:_sendEntityUpdate(
        entity, EntityUpdateType.OUT_OF_SYNC, nil, connectionId)
  end
end

return ClientNetworkedEntityManager
