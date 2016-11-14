require "common/functions"
require "CustomNetworkedEntityManager"
require "Connection"
require "ServerConnectionManager"
require "ConnectionStatus"
require "Serializer"

local PRINT_DEBUG = false

local F_NETWORK_ENTITY_ID = "neid"
local F_ENTITY_UPDATE_TYPE = "utype"

ServerNetworkedEntityManager = buildClass(CustomNetworkedEntityManager)
local Class = ServerNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
  assertType(connectionManager, "connectionManager", ServerConnectionManager)
  connectionManager:registerConnectionStatusListener(
      self,
      self.onConnectionStatusChanged)

  self.pendingUpdates = {}
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
      if self.pendingUpdates[connectionId][entity:getNetworkId()] then
        self.connectionManager:sendMessageWithAck(
            messages.entityUpdate.sync(
                entity:getNetworkId(),
                entity:getEntityType(),
                entity:getSynchronizedState()),
            self:buildEntityChannelString(entity),
            connectionId)
        self.pendingUpdates[connectionId][entity:getNetworkId()] = false
      end
    end
  end
end

--
-- Whenever an entity broadcasts an update, make note so that any stalled
-- connections can be synchronized.
--
function Class:broadcastEntityUpdate(entity, update)
  local entityId = entity:getNetworkId()
  local recipients = {}
  for connectionId in self:allConnectionIds() do
    local connection = self.connectionManager:getConnection(connectionId)
    if connection and connection.status == ConnectionStatus.STALLED then
      self.pendingUpdates[connectionId][entityId] = true
    else
      table.insert(recipients, connectionId)
    end
  end

  for recipient in self:allConnectionIds() do
    table.insert(recipients, recipient)
  end
  local message = messages.entityUpdate.inc(entity:getNetworkId(), update)
  self.connectionManager:sendMessage(message, unpack(recipients))
end

--
-- Override default behavior to limit what kind of updates the server handles
-- and under what conditions to do so.
--
function Class:onReceiveEntityUpdate(message, connectionId)
  if PRINT_DEBUG then print("ServerNetworkedEntityManager:onReceiveEntityUpdate", Serializer.serialize(message)) end

  local t = message[F_ENTITY_UPDATE_TYPE]
  local id = message[F_NETWORK_ENTITY_ID]
  if not t or not id then return end
  local entity = self:getEntity(id)
  if not entity then return end

  if PRINT_DEBUG then print("t:"..t, "id:"..id, "own:"..entity:getOwnerId()) end
  
  if t == EntityUpdateType.INCREMENTING then
    if entity and entity:getOwnerId() == connectionId then
      Class.superclass.onReceiveEntityUpdate(self, message, connectionId)

      local destinations = {}
      for destination in self:allConnectionIds() do
        if destination ~= connectionId then
          table.insert(destinations, destination)
        end
      end
      self.connectionManager:sendMessage(message, unpack(destinations)) 
    end
  elseif t == EntityUpdateType.OUT_OF_SYNC then
    Class.superclass.onReceiveEntityUpdate(self, message, connectionId)
  end
end

function Class:addConnection(connectionId)
  Class.superclass.addConnection(self, connectionId)
  self.pendingUpdates[connectionId] = {}

  for entity in self:allEntities() do
      self.connectionManager:sendMessageWithAckReset(
          messages.entityUpdate.create(
              entity:getNetworkId(),
              entity:getEntityType(),
              entity:getInstantiationParams()),
          self:buildEntityChannelString(entity),
          connectionId)
  end
end

function Class:removeConnection(connectionId)
  Class.superclass.removeConnection(self, connectionId)
  self.pendingUpdates[connectionId] = nil
end
