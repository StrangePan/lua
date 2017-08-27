require "strangepan.util.functions"
require "networking.ConnectionManager"
require "strangepan.secretary.Entity"
require "networking.NetworkedEntityType"
require "networking.EntityUpdateType"
require "networking.NetworkedEntity"
require "EventCoordinator"

local Serializer = require "Serializer"

local PRINT_DEBUG = true

local F_NETWORK_ENTITY_ID = "i"
local F_ENTITY_UPDATE_TYPE = "u"
local F_ENTITY_TYPE = "e"
local F_CREATE_PARAMS = "d"
local F_SYNC_DATA = "d"
local F_INC_DATA = "d"
local F_SYNC_NUM = "n"

--
-- Maintains an internal list of entities that are connected to network
-- versions. Works to track and coordinate changes between networked entities.
--
NetworkedEntityManager = buildClass(Entity)
local Class = NetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self)
  assertType(connectionManager, "connectionManager", ConnectionManager)
  self.connectionManager = connectionManager

  -- Sparse array containing metadata on entities.
  -- key: entity ID
  -- val: table containing {
  --   entitiy: the entity
  --   idIndex: index of entity id in entityIds table
  -- }
  self.entities = {}
  self.entityIds = {n = 0}
  self.nextId = 1

  self.connectionManager:registerMessageListener(
    MessageType.ENTITY_UPDATE,
    self,
    self.onReceiveEntityUpdate)

  self.entityCreateCoordinators = EventCoordinator()
  self.entityDeleteCoordinators = EventCoordinator()

  -- Sparse containing metadata on all connections.
  -- key: connection ID. See table `connectionIds` to get non-sparse list of
  --      tracked connection IDs.
  -- value: connection metadata table {
  --   id = connection id (redundant, equal to key)
  --   entities = table of entity metadata for connection.
  --     key: entity ID
  --     value: {
  --       syncNum = number of last sync sent/received to/from connection
  --       updated = boolean if this was updated since last sync
  --       inSync = flag tracking if the entity is still in sync
  --   }
  -- }
  self.connections = {}

  -- Array containing all IDs of connections.
  -- Key: arbitrary numerical index
  -- Value: connection ID
  self.connectionIds = {}
end



--------------------------------------------------------------------------------
--                               LOCAL METHODS                                --
--------------------------------------------------------------------------------

--
-- Builds an entity string.
--
local function buildEntityChannelString(id)
  id = instanceOf(id, NetworkedEntity) and id:getNetworkId() or id
  return string.format("entity:%s", id)
end



--------------------------------------------------------------------------------
--                             CONNECTION METHODS                             --
--------------------------------------------------------------------------------

--
-- Gets the existing connection metadata object for the supplied arguments.
-- Arguments can be either an existing connection metadata object or a
-- connection ID.
--
function Class:getConnection(connection)
  if type(connection) == "number" then
    return self.connections[connection]
  end
  if type(connection) == "table" then
    if connection.id and self.connections[connection.id] == connection then
      return connection
    end
  end
end

--
-- Adds a connection ID to receive entity updates.
--
function Class:addConnection(connectionId)
  assertType(connectionId, "number")
  local connection = self:getConnection(connectionId)
  if connection then return end

  -- Create connection metadata and store
  connection = {
    id = connectionId,
    entities = {}
  }
  self.connections[connection.id] = connection

  if PRINT_DEBUG then
    print("adding connection "..connection.id.." to NetworkedEntityManager")
  end

  -- Append connection ID to list of existing connection IDs
  table.insert(self.connectionIds, connection.id)

  for entity in self:allEntities() do
    self:_sendEntityUpdate(
        entity,
        EntityUpdateType.CREATING,
        entity:getInstantiationParams(),
        connection.id)
  end
end

--
-- Removes a connection from receiving entity updates.
--
function Class:removeConnection(connectionId)
  assertType(connectionId, "number")
  local connection = self:getConnection(connectionId)
  if not connection then return end

  -- Delete all metadata on connection
  self.connections[connection.id] = nil
  for k,v in ipairs(self.connectionIds) do
    if v == connection.id then
      table.remove(self.connectionIds, k)
      break
    end
  end
end

--
-- Iterator function that loops through all existing connection Ids.
--
function Class:allConnectionIds()
  local i = 0
  return function()
    i = i + 1
    return self.connectionIds[i]
  end
end

--
-- Iterator function that loops through all existing connection metadatas.
--
function Class:allConnections()
  local i =0
  return function()
    i = i + 1
    return self.connections[self.connectionIds[i]]
  end
end



--------------------------------------------------------------------------------
--                               ENTITY METHODS                               --
--------------------------------------------------------------------------------

--
-- Gets an existing entity. Parameters can be:
-- - The entity object itself (just returns the parameter).
-- - The ID of the desired entity.
-- - Returns nil in all other cases.
--
function Class:getEntity(entity)

  -- If parameter is already a NetworkedEntity
  if instanceOf(entity, NetworkedEntity) then
    
    -- Verify entity is managed by this instance
    local e = self.entities[entity:getNetworkId()]
    if e and e.entity == entity then
      return entity
    else
      return nil -- Not managed by this instance; return nil.
    end
  elseif type(entity) == "number" then -- Search for entity by ID.
    local e = self.entities[entity]
    return e and e.entity
  end
end

--
-- Claims a specific ID or a new ID if none is specified for a new entity and
-- returns the id. If an entity already exists with the same ID, destroys that
-- entity. Adds the claimed ID to the end of the entityIds array.
--
function Class:claimId(id)
  id = id or self.nextId
  if self.nextId <= id then
    self.nextId = id + 1
  end
  if self:getEntity(id) then
    self:destroyEntity(id)
  end
  self.entityIds.n = self.entityIds.n + 1
  self.entityIds[self.entityIds.n] = id
  return id
end

--
-- Internal method for adding an existing method to this class and optionally
-- broadcasts its creation to connected instances. Does not validate arguments.
--
function Class:_addEntity(entity, broadcast)
  local id = entity:getNetworkId()
  self.entities[id] = {
    entity = entity,
    idIndex = self.entityIds.n,
  }
  entity:getLocalEntity():registerWithSecretary(self:getSecretary())

  for connection in self:allConnections() do
    self:_setInSync(connection, id, true)
  end

  if broadcast then
    self:_broadcastEntityUpdate(
        entity, EntityUpdateType.CREATING, entity:getInstantiationParams())
  end

  self:notifyEntityCreateListeners(entity)
  return entity
end

--
-- Creates a new local entity and adds it to this manager, assigning it
-- a specific ID and using the supplied `params` object to initialize object.
-- This method should be used to create a local representation of an existing
-- network entity.
--
-- Returns the newly created `NetworkedEntity`. Will delete any previous entity
-- using the provided ID.
--
function Class:createEntityWithParams(id, entityType, params)
  assertType(id, "id", "number")
  assert(NetworkedEntityType.fromId(entityType),
      "entityType: "..entityType.." is not a valid NetworkedEntityType")

  -- Claim an ID. Will destroy the previous entity at that ID.
  id = self:claimId(id)
  
  -- Instantiate a new entity and hook everything up
  local entity = NetworkedEntity.createNewInstanceWithParams(
      self, id, entityType, params)
  return self:_addEntity(entity, false)
end

--
-- Creates a new entity, automatically assigning it an ID and broadcasting its
-- creation to other connections. Instantiates the object with the supplied list
-- of arguments. See the specific implementation of the NetworkedEntity class
-- for the expected arguments.
--
function Class:spawnEntity(entityType, ...)
  assert(NetworkedEntityType.fromId(entityType),
      "entityType: "..entityType.." is not a valid NetworkedEntityType")

  -- Generate an ID.
  local id = self:claimId()

  if PRINT_DEBUG then
    print("spawning entity of type "..entityType.." with params:", ...)
  end

  -- Instantiate a new entity and hook everything up.
  local entity = NetworkedEntity.createNewInstance(
      self, id, entityType, ...)
  return self:_addEntity(entity, true)
end

--
-- Removes the entity from this instance. Optionally notifies connections of
-- destruction. Calls :destroy() on provided entity. Returns the destroyed
-- entity or `nil` if the entity was already destroyed.
--
function Class:_removeEntity(entity, broadcast)
  entity = self:getEntity(entity)
  if not entity then return nil end

  local id = entity:getNetworkId()

  if broadcast then
    self:_broadcastEntityUpdate(entity, EntityUpdateType.DESTROYING, nil)
  end

  -- DELETE RECORD OF ENTITY BEFORE PROPOGATING DESTRUCTION CALL
  -- TO AVOID INFINITE RECURSION
  self.entityIds[self.entities[id].idIndex] = nil
  self.entities[id] = nil
  for connection in self:allConnections() do
    connection.entities[id] = nil
  end

  self:notifyEntityDeleteListeners(entity)
  entity:delete()
  return entity
end

--
-- Deletes the entity from this entity manager and calls :destroy() on the
-- supplied entity. Does nothing if this manager does not recognize the entity.
--
function Class:destroyEntity(entity)
  return self:_removeEntity(entity, true)
end

--
-- Loops through all entities, cleaning up any sparseness in the array.
--
function Class:allEntities()
  local nextId = self:allEntityIds()
  return function()
    local id = nextId()
    return id and self.entities[id].entity or nil
  end
end

--
-- Loops through all entity IDs, cleaning up any sparseness in the array.
--
function Class:allEntityIds()
  local i = 0
  local j = 0
  local n = self.entityIds.n
  return function()
    i = i + 1
    j = j + 1
    while not self.entityIds[j] and j <= n do
      j = j + 1
      self.entityIds.n = self.entityIds.n - 1
    end
    self.entityIds[i] = self.entityIds[j]
    if self.entityIds[i] then
      self.entities[self.entityIds[i]].idIndex = i
    end
    return self.entityIds[i]
  end
end



--------------------------------------------------------------------------------
--                               HELPER METHODS                               --
--------------------------------------------------------------------------------

function Class:_incrementSyncNum(connection, entity)
  connection = self:getConnection(connection)
  entity = self:getEntity(entity)
  local id = entity:getNetworkId()
  if not connection.entities[id] then
    connection.entities[id] = {}
  end
  if not connection.entities[id].syncNum then
    connection.entities[id].syncNum = 1
  end
  connection.entities[id].syncNum = connection.entities[id].syncNum + 1
  return connection.entities[id].syncNum
end

function Class:_getSyncNum(connection, entity)
  connection = self:getConnection(connection)
  entity = self:getEntity(entity)
  local id = entity:getNetworkId()
  if not connection.entities[id] or not connection.entities[id].syncNum then
    return 1
  end
  return connection.entities[id].syncNum
end

function Class:_setSyncNum(connection, entity, value)
  connection = self:getConnection(connection)
  entity = self:getEntity(entity)
  local id = entity:getNetworkId()
  if not connection.entities[id] then
    connection.entities[id] = {}
  end
  connection.entities[id].syncNum = value
end

function Class:_isUpdated(connection, entity, value)
  connection = self:getConnection(connection)
  entity = self:getEntity(entity)
  local id = entity:getNetworkId()
  if not connection.entities[id] then
    connection.entities[id] = {}
  end
  return connection.entities[id].updated == true
end

function Class:_setUpdated(connection, entity, value)
  connection = self:getConnection(connection)
  entity = self:getEntity(entity)
  local id = entity:getNetworkId()
  if not connection.entities[id] then
    connection.entities[id] = {}
  end
  connection.entities[id].updated = true
end

function Class:_isInSync(connection, entity)
  connection = self:getConnection(connection)
  entity = self:getEntity(entity)
  local id = entity:getNetworkId()
  if not connection.entities[id] then
    connection.entities[id] = {}
  end
  return connection.entities[id].inSync == true
end

function Class:_setInSync(connection, entity, value)
  connection = self:getConnection(connection)
  entity = self:getEntity(entity)
  local id = entity:getNetworkId()
  if not connection.entities[id] then
    connection.entities[id] = {}
  end
  connection.entities[id].inSync = value
end



--------------------------------------------------------------------------------
--                           SENDING ENTITY UPDATES                           --
--------------------------------------------------------------------------------

--
-- Sends an incremental entity update to all connected remote instances.
-- Can include any number of optional connection IDs to exclude when
-- broadcasting.
--
function Class:publishIncrementalUpdate(entity, update, ...)
  self:_broadcastEntityUpdate(
    entity, EntityUpdateType.INCREMENTING, update, ...)
end

--
-- Internal. Send the supplied update data to all known connections except for
-- the ones supplied as optional arguments. Performs validation.
--
function Class:_broadcastEntityUpdate(entity, updateType, update, ...)

  -- Mark supplied optional excluded IDs in table for quick lookup
  local excluded = {}
  for _,i in ipairs({...}) do
    excluded[i] = true
  end

  -- Compile destination table
  local destinations = {}
  for connectionId in self:allConnectionIds() do
    if not excluded[connectionId] then
      table.insert(destinations, connectionId)
    end
  end

  -- Send the message
  return self:_sendEntityUpdate(
      entity, updateType, update, unpack(destinations))
end

--
-- Internal. Send thesupplied update data to all listed connections. Performs
-- validation.
--
function Class:_sendEntityUpdate(entity, updateType, update, ...)
  entity = self:getEntity(entity)
  assert(entity, "entity not of supported type or not recognized by manager")
  assert(
      EntityUpdateType.fromId(updateType),
      updateType.." not valid EntityUpdateType")
  if updateType == EntityUpdateType.CREATING
      or updateType == EntityUpdateType.SYNCHRONIZING
      or updateType == EntityUpdateType.INCREMENTING then
    assertType(update, "table")
  end

  -- Establish up some local variables
  local id = entity:getNetworkId()
  local entityType
  if updateType == EntityUpdateType.CREATING
      or updateType == EntityUpdateType.SYNCHRONIZING then
    entityType = entity:getEntityType()
  end

  if PRINT_DEBUG and updateType == EntityUpdateType.SYNCHRONIZING then
    print("sending sync of entity "..id.." to:", ...)
  end

  -- Loop through all known IDs, constructing and sending messages to each
  -- and updating tracking variables for each based on message type.
  for _,connection in ipairs({...}) do
    connection = self:getConnection(connection)
    if connection then
      local message
      local syncNum
      local requiresAck = false

      -- Build message
      if updateType == EntityUpdateType.CREATING then
        self:_setInSync(connection, entity, true)
        message = messages.entityUpdate.create(id, entityType, update)
        requiresAck = true
      elseif updateType == EntityUpdateType.DESTROYING then
        self:_setUpdated(connection, entity, false)
        self:_setInSync(connection, entity, true)
        message = messages.entityUpdate.destroy(id)
        requiresAck = true
      elseif updateType == EntityUpdateType.SYNCHRONIZING then
        self:_setUpdated(connection, entity, false)
        self:_setInSync(connection, entity, true)
        syncNum = self:_incrementSyncNum(connection, entity)
        message = messages.entityUpdate.sync(id, entityType, update, syncNum)
        requiresAck = true
      elseif updateType == EntityUpdateType.INCREMENTING then
        self:_setUpdated(connection, entity, true)
        syncNum = self:_getSyncNum(connection, entity)
        message = messages.entityUpdate.inc(id, update, syncNum)
      elseif updateType == EntityUpdateType.OUT_OF_SYNC then
        syncNum = self:_getSyncNum(connection, entity)
        message = messages.entityUpdate.outOfSync(id, syncNum)
      end

      -- Send message
      if requiresAck then
        self.connectionManager:sendMessageWithAckReset(
            message, buildEntityChannelString(id), connection.id)
      else
        self.connectionManager:sendMessage(message, connection.id)
      end
    end
  end
end



--------------------------------------------------------------------------------
--                          RECEIVING ENTITY UPDATES                          --
--------------------------------------------------------------------------------

--
-- Handles any incoming entity update messages. Is responsible for extracting
-- the inner data from the network message before processing.
--
function Class:onReceiveEntityUpdate(message, connectionId)
  local t = message[F_ENTITY_UPDATE_TYPE]
  
  if t == EntityUpdateType.CREATING then
    return self:onReceiveEntityCreate(message, connectionId)
  elseif t == EntityUpdateType.DESTROYING then
    return self:onReceiveEntityDestroy(message, connectionId)
  elseif t == EntityUpdateType.SYNCHRONIZING then
    return self:onReceiveEntitySync(message, connectionId)
  elseif t == EntityUpdateType.INCREMENTING then
    return self:onReceiveEntityInc(message, connectionId)
  elseif t == EntityUpdateType.OUT_OF_SYNC then
    return self:onReceiveEntityOutOfSync(message, connectionId)
  else
    print("Unknown entity update type "..t)
  end
end

--
-- Handles an EntityUpdateType.CREATING message. Performs any necessary
-- validation and initiates the entity creation process.
--
function Class:onReceiveEntityCreate(message, connectionId)

  -- Extract relevant information from message.
  local id = message[F_NETWORK_ENTITY_ID]
  local entityType = message[F_ENTITY_TYPE]
  local params = message[F_CREATE_PARAMS]

  -- Create the new entity. Do not worry about colliding IDs, since ths method
  -- will destroy any local entities with matching IDs.
  self:createEntityWithParams(id, entityType, params)
end

--
-- Handles an EntityUpdateType.DESTROYING message. Performs any necessary
-- validation and cleanup and destroys the underlying entity.
--
function Class:onReceiveEntityDestroy(message, connectionId)
  local id = message[F_NETWORK_ENTITY_ID]
  local entity = self:getEntity(id)

  -- Remove the entity. Manually handle broadcast of destruction message.
  if entity then
    self:_broadcastEntityUpdate(
        entity, EntityUpdateType.DESTROYING, nil, connectionId)
  end

  entity = self:_removeEntity(id)
  return entity ~= nil
end

--
-- Handles an EntityUpdateType.SYNCHRONIZING message. Performs any necessary
-- validation and causes the associated entity to resynchronize state with the
-- contents of the received message.
--
function Class:onReceiveEntitySync(message, connectionId)
  local id = message[F_NETWORK_ENTITY_ID]
  local syncNum = message[F_SYNC_NUM]
  local params = message[F_SYNC_DATA]

  if PRINT_DEBUG then
    print("received sync for "..id.." from "..connectionId)
    print("syncNum: ", syncNum, "local syncNum:", self:_getSyncNum(connectionId, id))
    print(Serializer.serialize(message))
  end

  -- Verify that the entity already exists. If not, cancel; there's nothing
  -- left to do.
  local entity = self:getEntity(id)
  if not entity then return end

  if not syncNum or self:_getSyncNum(connectionId, id) >= syncNum then
    return
  end

  self:_setSyncNum(connectionId, id, syncNum)
  entity:setSynchronizedState(params)
  self:_setInSync(connectionId, id, true)
  self:_setUpdated(connectionId, id, false)
end

--
-- Handles an EntityUpdateType.INCREMENTING message. Performs any nessary
-- validation and causes the associated entity to incrementally change state.
-- If the received update's base sync number is not equal to the most recently
-- received sync num, then thism ethod does nothing.
--
-- Returns true if the entity was notified of the update.
--
function Class:onReceiveEntityInc(message, connectionId)
  local id = message[F_NETWORK_ENTITY_ID]
  local syncNum = message[F_SYNC_NUM]
  local params = message[F_INC_DATA]

  -- Verify that the entity already exists and that the message's base sync
  -- number matches the local one.
  local entity = self:getEntity(id)
  if not entity
      or self:_getSyncNum(connectionId, id) ~= syncNum
      or not self:_isInSync(connectionId, id) then
    return false
  end

  local inSync = entity:performIncrementalUpdate(params)
  self:_setInSync(connectionId, id, inSync)

  if inSync then
    for connection in self:allConnections() do
      if connection.id ~= connectionId then
        self:_setUpdated(connection.id, entity, true)
      end
    end
  end

  return true
end

--
-- Handles an EntityUpdateType.OUT_OF_SYNC message. Sends the current state of
-- the entity.
--
function Class:onReceiveEntityOutOfSync(message, connectionId)
  local id = message[F_NETWORK_ENTITY_ID]
  local syncNum = message[F_SYNC_NUM]

  -- Short circuit if we don't know that entity or if we've already sent a sync
  local entity = self:getEntity(id)
  if not entity or self:_getSyncNum(connectionId, id) ~= syncNum then
    return false
  end

  self:_sendEntityUpdate(
    entity,
    EntityUpdateType.SYNCHRONIZING,
    entity:getSynchronizedState(),
    connectionId)
  return true
end



--------------------------------------------------------------------------------
--                            ENTITY NOTIFICATIONS                            --
--------------------------------------------------------------------------------

--
-- Listeners receive the NetworkedEntityManager triggering event and the entity
-- being created. Only receives notifications for the supplied entityType or
-- all entities if entityType is nil.
--
function Class:registerEntityCreateListener(listener, callback, entityType)
  self:_registerEntityEventListener(
      listener, callback, entityType, self.entityCreateCoordinators)
end

--
-- Listeners receive the NetworkedEntityManager triggering event and the entity
-- being destroyed. Only receives notifications for the supplied entityType or
-- all entities if entityType is nil.
--
function Class:registerEntityDeleteListener(listener, callback, entityType)
  self:_registerEntityEventListener(
      listener, callback, entityType, self.entityDeleteCoordinators)
end

--
-- Registers an entity listener for the given entity update type or all entity
-- update types.
--
function Class:_registerEntityEventListener(
    listener, callback, entityType, coordinators)
  if entityType then
    assert(NetworkedEntityType.fromId(entityType),
        "Undefined NetworkedEntityType "..entityType)
  else
    entityType = "any"
  end
  coordinator = coordinators[entityType]
  if not coordinator then
    coordinator = EventCoordinator()
    coordinators[entityType] = coordinator
  end
  coordinator:registerListener(listener, callback)
end

--
-- Notifies listeners of entity creation.
--
function Class:notifyEntityCreateListeners(entity)
  self:_notifyEntityEventListeners(entity, self.entityCreateCoordinators)
end

--
-- Notifies listeners of entity deletion.
--
function Class:notifyEntityDeleteListeners(entity)
  self:_notifyEntityEventListeners(entity, self.entityDeleteCoordinators)
end

--
-- Notifies listeners of any type of entity event.
--
function Class:_notifyEntityEventListeners(entity, coordinators)
  entity = self:getEntity(entity)
  if not entity then return end
  local entityType = entity:getEntityType()
  local coordinator = coordinators["any"]
  if coordinator then
    coordinator:notifyListeners(self, entity)
  end
  coordinator = coordinators[entityType]
  if coordinator then
    coordinator:notifyListeners(self, entity)
  end
end

--
-- Removes a registered listener.
--
function Class:unregisterEntityCreateListener(listener, callback)
  self:_unregisterEntityEventListener(
      listener, callback, self.entityCreateCoordinator)
end

--
-- Removes a registered listener.
--
function Class:unregisterEntityDeleteListener(listener, callback)
  self:_unregisterEntityEventListener(
      listener, callback, self.entityDeleteCoordinator)
end

--
-- Unregisters a listener of the given type.
--
function Class:_unregisterEntityEventListener(listener, callback, coordinators)
  entity = self:getEntity(entity)
  if not entity then return end
  local entityType = entity:getEntityType()
  local coordinator = coordinators["any"]
  if coordinator then
    coordinator:unregisterListeners(listener, callback)
  end
  coordinator = coordinators[entityType]
  if coordinator then
    coordinator:unreigsterListeners(listener, callback)
  end
end
