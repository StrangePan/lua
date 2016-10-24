require "common/class"

--
-- Represents an Entity that is available across a network and tied to similar
-- entities on remote program instances. Generally instantiated by a manager
-- of some sort who handles connections and permissions.
--
NetworkedEntity = buildClass()
local Class = NetworkedEntity

--
-- Private static table of registered entity types that can be instantiated
-- via createNewInstance. New entity subclasses can be registered here by
-- statically calling NetworkedEntity.registerEntityType().
--
local registeredEntities = {}

--
-- Registers a subclass of NetworkedEntity to be associated with the provided
-- EntityType so that it can be instantiated when createNewInstance is called.
-- If an entity has already been registered with the given EntityType, then this
-- method will return `false`.
--
function Class.registerEntityType(entityType, entityClass)
  assert(EntityType.fromId(entityType), entityType.." is not a valid EntityType")
  assertType(entityClass, "entityClass", NetworkedEntity)
  assert(entityClass ~= Class, "Cannot register NetworkedEntity with itself!")
  if registeredEntities[entityType] then
    return false
  end
  registeredEntities[entityType] = entityClass
  return true
end

--
-- Creates a new instance of a registered network entity using the provided
-- ID, type, and instantiation parameters.
--
-- Subclasses call NetworkedEntity.registerEntityType(NetworkedEntitySubclass)
-- statically to register themselves so that their corresponding
-- createNewInstance method can be called.
--
-- If no entity has been associated with the given EntityType, then this method
-- will return `nil`. Otherwise, if successful, the newly created entity will be
-- returned.
--
-- This method should not be called by subclasses.
--
-- manager: The NetworkedEntityManager that is invoking this method
-- id: The network ID that this new instance is assigned
-- entityType: The type of entity to instantiate
-- params: The instantiation params ot use when creating the new entity 
--
function Class.createNewInstance(manager, id, entityType, params)
  assertType(id, "id", "number")
  
  -- Ensure supplied entityType is indeed an EntityType.
  assert(EntityType.fromId(entityType), entityType.." is not a valid EntityType")
  
  -- Ensure entity type is registered. Otherwise, return nil.
  if not registeredEntities[entityType] then
    return nil
  end
  
  -- Try to catch infinite recursion if user fails to override createNewInstance.
  assert(registeredEntities[entityType].createNewInstance ~= Class.createNewInstance, "Make sure .createNewInstance() is overridden")
  
  -- Instantiate and return new instance using given arguments.
  return registeredEntities[entityType].createNewInstance(manager, id, entityType, params)
end



--
-- Instantiates a new NetworkedEntity.
--
function Class:_init(manager, networkId, entityType, params, entity)
  Class.superclass._init(self)
  assertType(manager, "manager", NetworkedEntityManager)
  assertType(networkId, "networkId", "number")
  assert(EntityType.fromId(entityType), entityType.." is not a valid EntityType")
  assertType(entity, "entity", Entity)

  self.manager = manager
  self.id = networkId
  self.entityType = entityType
  self.entity = entity
end

--
-- Gets the NetworkedEntityManager that created this NetworkedEntity.
--
function Class:getManager()
  return self.manager
end

--
-- Gets the network ID of this NetworkedEntity.
--
function Class:getNetworkId()
  return self.id
end

--
-- Gets the entity type of this NetworkedEntity.
--
function Class:getEntityType()
  return self.entityType
end

--
-- Gets the local entity.
--
function Class:getLocalEntity()
  return self.entity
end

--
-- This method should be overridden and called by subclasses.
--
-- Sets the state of the NetworkedEntity based the contents of a received state
-- synchronization message.
--
function Class:setSynchronizedState(state)
end

--
-- This method should be overridden and called by subclasses.
--
-- Given a state object, prompts this NetworkedEntity to store its state into
-- the provided object.
--
function Class:getSynchronizedState(state)
end

--
-- This method should be overridden and called by subclasses.
--
-- Triggers an incremental state change on the entity based on the contents of
-- a received state incrementing message. In other words, an object has moved
-- 10 pixels over of the object has jumped; something incremental has changed
-- about the entity and the entity should handle it appropriately.
--
function Class:performIncrementalUpdate(update)
end

--
-- Deletes this entity; entity should be immediately destroyed and its
-- resources freed; no exceptions, and no animations.
--
function Class:delete()
  local entity = self:getLocalEntity()
  local manager = self:getManager()
  if manager and entity then
    return
  end

  self.entity = nil
  self.manager = nil
  entity:destroy()
  manager:deleteEntity(self)
end
