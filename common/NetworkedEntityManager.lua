require "common/class"
require "common/functions"
require "ConnectionManager"
require "NetworkedEntity"
require "EntityUpdateType"

local F_NETWORK_ENTITY_ID = "neid"
local F_ENTITY_UPDATE_TYPE = "utype"
local F_ENTITY_TYPE = "etype"
local F_CREATE_PARAMS = "params"
local F_SYNC_DATA = "sdata"
local F_INC_DATA = "idata"

--
-- Maintains an internal list of entities that are connected to network
-- versions. Works to track and coordinate changes between networked entities.
--
NetworkedEntityManager = buildClass()
local Class = NetworkedEntityManager

function Class:_init(connectionManager)
  self.connectionManager = connectionManager
  assertType(connectionManager, "connectionManager", ConnectionManager)
  self.entities = {}
end

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
    if self.entities[entity:getNetworkId()] == entity then
      return entity
    else
      return nil -- Not managed by this instance; return nil.
    end
  elseif instanceOf(entity, "number") then -- Search for entity by ID.
    return self.entities[entity]
  end
end

--
-- Creates a new entity and adds it to this manager.
--
function Class:createEntity(id, entityType, params)
  assertType(id, "id", "number")
  assert(EntityType.fromId(entityType), "entityType: "..entityType.." is not a valid EntityType")
  
  -- If an entity already exists with the given ID, then fail
  if self:getEntity(id) then
    return
  end
  
  -- Instantiate a new entity and hook everything up
  local entity = NetworkedEntity.createNewEntity(self, id, entityType, params)
  self.entities[id] = entity
  return entity
end

--
-- Delete an existing entity immediately; skips any animations and forces the
-- entity to cease existing.
--
function Class:deleteEntity(entity)
  entity = self:getEntity(entity)
  if not entity then return end
  
  -- DELETE RECORD OF ENTITY BEFORE PROPOGATING DESTRUCTION CALL
  -- TO AVOID INFINITE RECURSION
  self.entities[entity:getNetworkId()] = nil
  entity:delete()
end

--
-- Called to process and handle incoming entity update messages. Accepts
-- the message that was received as well as the ID of the connection that
-- sent the message.
--
function Class:onReceiveEntityUpdate(message, connectionId)
  local t = message[F_ENTITY_UPDATE_TYPE]
  
  if t == EntityUpdateType.CREATING then
    self:onReceiveEntityCreate(message, connectionId)
  elseif t == EntityUpdateType.DESTROYING then
    self:onReceiveEntityDestroy(message, connectionId)
  elseif t == EntityUpdateType.SYNCHRONIZING then
    self:onReceiveEntitySync(message, connectionId)
  elseif t == EntityUpdateType.INCREMENTING then
    self:onReceiveEntityInc(message, connectionId)
  else
    print("Unknown entity update type "..t)
  end
end

--
-- Handles an EntityUpdateType.CREATING message. Performs any necessary
-- validation and initiates the entity creation process.
--
function Class:onReceiveEntityCreate(message, connectionId)
  local id = message[F_NETWORK_ENTITY_ID]
  
  -- Verify that the entity doesn't already exist. If it does, then destroy it
  -- and create a new one with the same ID.
  local entity = self:getEntity(id)
  if entity then
    self:deleteEntity(entity)
  end
  
  -- Extract relevant information from message.
  local entityType = message[F_ENTITY_TYPE]
  local params = message[F_CREATE_PARAMS]
  
  self:createEntity(id, entityType, params)
end

--
-- Handles an EntityUpdateType.DELETE message. Performs any necessary
-- validation and cleanup and destroys the underlying entity.
--
function Class:onReceiveEntityDelete(message, connectionId)
  local id = message[F_NETWORK_ENTITY_ID]

  -- Verify that the entity already exists. If not, cancel; there's nothing
  -- left to do.
  local entity = self:getEntity(id)
  if not entity then return end

  -- Destroy the entity
  self:deleteEntity(entity)
end

--
-- Handles an EntityUpdateType.SYNCHRONIZING message. Performs any necessary
-- validation and causes the associated entity to resynchronize state with the
-- contents of the received message.
--
function Class:onReceiveEntitySync(message, connectionId)
  local id = message[F_NETWORK_ENTITY_ID]
  
  -- Verify that the entity already exists. If not, cancel; there's nothing
  -- left to do.
  local entity = self:getEntity(id)
  if not entity then return end
  
  entity:setSynchronizedData(message[F_SYNC_DATA])s
end

--
-- Handles an EntityUpdateType.INCREMENTING message. Performs any nessary
-- validation and causes the associated entity to incrementally change state
-- as long as the received state is in the correctly received order (i.e. no
-- incremental message was skipped since the last received update message).
--
function Class:onReceiveEntityInc(message, connectionId)
  local id = message[F_NETWORK_ENTITY_ID]
  
  -- Verify that the entity already exists. If not, cancel; there's nothing
  -- left to do.
  local entity = self:getEntity(id)
  if not entity then return end
  
  entity:performIncrementalUpdate(message[F_INC_DATA])
end
