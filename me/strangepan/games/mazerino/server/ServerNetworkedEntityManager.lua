local ConnectionStatus = require "me.strangepan.games.mazerino.common.networking.ConnectionStatus"
local CustomNetworkedEntityManager = require "me.strangepan.games.mazerino.common.networking.CustomNetworkedEntityManager"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local ServerConnectionManager = require "me.strangepan.games.mazerino.server.ServerConnectionManager"
local Serializer = require "me.strangepan.games.mazerino.common.Serializer"
local class = require "me.strangepan.libs.util.v1.class"
local EntityUpdateType = require "me.strangepan.games.mazerino.common.networking.EntityUpdateType"

local PRINT_DEBUG = false

local F_NETWORK_ENTITY_ID = "i"
local F_ENTITY_UPDATE_TYPE = "u"
local F_INC_DATA = "d"
local F_SYNC_NUM = "n"

local ServerNetworkedEntityManager = class.build(CustomNetworkedEntityManager)

function ServerNetworkedEntityManager:_init(connectionManager)
  CustomNetworkedEntityManager._init(self, connectionManager)
  assert_that(connectionManager):is_instance_of(ServerConnectionManager):and_return()
  connectionManager:registerConnectionStatusListener(
      self, self.onConnectionStatusChanged)
end

--
-- Sends entity updates when connection status changes.
--
function ServerNetworkedEntityManager:onConnectionStatusChanged(manager, connectionId, oldStatus)
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
function ServerNetworkedEntityManager:onReceiveEntityUpdate(message, connectionId)
  if PRINT_DEBUG then print("ServerNetworkedEntityManager:onReceiveEntityUpdate", Serializer.serialize(message)) end

  local id = message[F_NETWORK_ENTITY_ID]
  local entity = self:getEntity(id)
  local t = message[F_ENTITY_UPDATE_TYPE]
  if not entity then return end

  if PRINT_DEBUG then print("t:"..t, "id:"..id) end

  if t == EntityUpdateType.INCREMENTING
      and entity:getOwnerId() == connectionId then
    CustomNetworkedEntityManager.onReceiveEntityUpdate(self, message, connectionId)

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
    CustomNetworkedEntityManager.onReceiveEntityUpdate(self, message, connectionId)
  end
end

return ServerNetworkedEntityManager
