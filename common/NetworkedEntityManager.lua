require "common/class"
require "common/functions"
require "ConnectionManager"
require "NetworkedEntity"
require "EntityUpdateType"

local F_NETWORK_ENTITY_ID = "neid"
local F_ENTITY_UPDATE_TYPE = "utype"
local F_ENTITY_TYPE = "etype"
local F_CREATE_PARAMS = "params"

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
  if instanceOf(entity, NetworkedEntity) then
    return entity
  elseif instanceOf(entity, "number") then -- search for entity by ID
    return self.entities[entity]
  end
end

--
-- Creates a new entity and adds it to this manager.
--
function Class:createEntity(id, entityType, params)
  
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
-- Handles an EntityUpdateType.DESTROYING message. Performs any necessary
-- validation and cleanup.
--
function Class:onReceiveEntityDestroy(message, connectionId)
end

--
-- Handles an EntityUpdateType.SYNCHRONIZING message. Performs any necessary
-- validation and causes the associated entity to resynchronize state with the
-- contents of the received message.
--
function Class:onReceiveEntitySync(message, connectionId)
end

--
-- Handles an EntityUpdateType.INCREMENTING message. Performs any nessary
-- validation and causes the associated entity to incrementally change state
-- as long as the received state is in the correctly received order (i.e. no
-- incremental message was skipped since the last received update message).
--
function Class:onReceiveEntityInc(message, connectionId)
end
