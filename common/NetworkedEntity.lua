require "common/class"

--
-- Represents an entity that is available across a network and tied to similar
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
--
function Class.registerEntityType(entityType, entityClass)
  assert(EntityType.fromId(entityType), entityType.." is not a valid EntityType")
  assertType(entityClass, "entityClass", NetworkedEntity)
  assert(entityClass ~= Class, "Cannot register NetworkedEntity with itself!")
  assert(not registeredEntities[entityType], "EntityType "..entityType.." already registered.")
  registeredEntities[entityType] = entityClass
end

--
-- Creates a new instance of a registered network entity using the provided
-- ID, type, and instantiation parameters.
--
-- Subclasses call NetworkedEntity.registerEntityType(NetworkedEntitySubclass)
-- statically to register themselves so that their corresponding
-- createNewInstance method can be called.
--
function Class.createNewInstance(id, entityType, params)
  assertType(id, "id", "number")
  
  -- Ensure supplied entityType is indeed an EntityType.
  assert(EntityType.fromId(entityType), entityType.." is not a valid EntityType")
  
  -- Ensure entity type is registered.
  assert(registeredEntities[entityType], "EntityType "..entityType.." not registered.")
  
  -- Try to catch infinite recursion if user fails to override createNewInstance.
  assert(registeredEntities[entityType].createNewInstance ~= Class.createNewInstance, "Make sure .createNewInstance() is overridden")
  
  -- Instantiate and return new instance using given arguments.
  return registeredEntities[entityType].createNewInstance(id, entityType, params)
end



--
-- Instantiates a new NetworkedEntity.
--
function Class:_init(networkId, entityType, params)
  Class.superclass._init(self)
  self.id = networkId
  assertType(networkId, "networkId", "number")
  self.entityType = entityType
  assert(EntityType.fromId(entityType), entityType.." is not a valid EntityType")
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
