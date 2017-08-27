require "strangepan.util.functions"
require "networking.CustomNetworkedEntityManager"
require "networking.Connection"
require "ServerConnectionManager"
require "networking.ConnectionStatus"

local Serializer = require "Serializer"

local PRINT_DEBUG = false

local F_NETWORK_ENTITY_ID = "i"
local F_ENTITY_UPDATE_TYPE = "u"
local F_INC_DATA = "d"
local F_SYNC_NUM = "n"

ServerNetworkedEntityManager = buildClass(CustomNetworkedEntityManager)
local Class = ServerNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
  assertType(connectionManager, "connectionManager", ServerConnectionManager)
  connectionManager:registerConnectionStatusListener(
      self, self.onConnectionStatusChanged)
end

--
-- Sends entity updates when connection status changes.
--
function Class:onConnectionStatusChanged(manager, connectionId, oldStatus)
  local newStatus = manager:getConnection(connectionId).status
  if newStatus == ConnectionStatus.CONNECTED
      and oldStatus == ConnectionStatus.STALLED then

    --
    -- Resync connected instance. If any entities have been updated since
    -- the connection went stale, send sync updates for those entities.
    --
    for entity in self:allEntities() do
      if self:_isUpdated(connectionId, entity:getNetworkId()) then
        self:_sendEntityUpdate(
            entity,
            EntityUpdateType.SYNCHRONIZING,
            entity:getSynchronizedState(),
            connectionId)
      end
    end
  end
end

--
-- Override default behavior to limit what kind of updates the server handles
-- and under what conditions to do so.
--
function Class:onReceiveEntityUpdate(message, connectionId)
  if PRINT_DEBUG then print("ServerNetworkedEntityManager:onReceiveEntityUpdate", Serializer.serialize(message)) end

  local id = message[F_NETWORK_ENTITY_ID]
  local entity = self:getEntity(id)
  local t = message[F_ENTITY_UPDATE_TYPE]
  if not entity then return end

  if PRINT_DEBUG then print("t:"..t, "id:"..id) end

  if t == EntityUpdateType.INCREMENTING
      and entity:getOwnerId() == connectionId then
    Class.superclass.onReceiveEntityUpdate(self, message, connectionId)

    if self:_isInSync(connectionId, id) then
      local params = message[F_INC_DATA]
      self:_broadcastEntityUpdate(
          entity, EntityUpdateType.INCREMENTING, params, connectionId)
    else
      self:_sendEntityUpdate(
          entity,
          EntityUpdateType.SYNCHRONIZING,
          entity:getSynchronizedState(),
          connectionId)
    end
  elseif t == EntityUpdateType.OUT_OF_SYNC then
    Class.superclass.onReceiveEntityUpdate(self, message, connectionId)
  end
end
