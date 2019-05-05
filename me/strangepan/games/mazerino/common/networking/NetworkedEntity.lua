local class = require "me.strangepan.libs.lua.v1.class"
local NetworkedEntityType = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityType"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local Entity = require "me.strangepan.games.mazerino.common.strangepan.secretary.Entity"

local PRINT_DEBUG = false

--
-- Represents an Entity that is available across a network and tied to similar
-- entities on remote program instances. Generally instantiated by a manager
-- of some sort who handles connections and permissions.
--
local NetworkedEntity = class.build()

--
-- Private static table of registered entity types that can be instantiated
-- via createNewInstance. New entity subclasses can be registered here by
-- statically calling NetworkedEntity.registerEntityType().
--
local registeredEntities = {}

--
-- Registers a subclass of NetworkedEntity to be associated with the provided
-- NetworkedEntityType so that it can be instantiated when createNewInstance is called.
-- If an entity has already been registered with the given NetworkedEntityType, then this
-- method will return `false`.
--
function NetworkedEntity.registerEntityType(entityType, entityNetworkedEntity)
  assert_that(entityType):is_a_number():is_a_key_in(NetworkedEntityType)
  assert_that(entityNetworkedEntity):is_instance_of(NetworkedEntity)
  assert(entityNetworkedEntity ~= NetworkedEntity, "Cannot register NetworkedEntity with itself!")
  if registeredEntities[entityType] then
    return false
  end
  registeredEntities[entityType] = entityNetworkedEntity
  return true
end

--
-- Creates a new instance of a registered network entity using the provided
-- ID, type, and instantiation parameters in the form of a table.
--
-- Subclasses call NetworkedEntity.registerEntityType(NetworkedEntitySubclass)
-- statically to register themselves so that their corresponding
-- createNewInstance method can be called.
--
-- If no entity has been associated with the given NetworkedEntityType, then this method
-- will return `nil`. Otherwise, if successful, the newly created entity will be
-- returned.
--
-- This method should **not** be called by subclasses.
--
-- manager: The NetworkedEntityManager that is invoking this method
-- id: The network ID that this new instance is assigned
-- entityType: The type of entity to instantiate
-- params: The instantiation params to use when creating the new entity in the
--   form of a single table. See `createNewInstance` method to create new
--   entity with individual construction params.
--
function NetworkedEntity.createNewInstanceWithParams(manager, id, entityType, params)
  assert_that(id):is_a_number():and_return()
  
  -- Ensure supplied entityType is indeed an NetworkedEntityType.
  assert_that(entityType):is_a_number():is_a_key_in(NetworkedEntityType)
  
  -- Ensure entity type is registered. Otherwise, return nil.
  if not registeredEntities[entityType] then
    return nil
  end
  
  -- Try to catch infinite recursion if user fails to override this method.
  assert(registeredEntities[entityType].createNewInstanceWithParams ~=
      NetworkedEntity.createNewInstanceWithParams,
      "Make sure createNewInstanceWithParams() is overridden")

  -- Instantiate and return new instance using given arguments.
  return registeredEntities[entityType].createNewInstanceWithParams(
      manager,
      id,
      entityType,
      params)
end

--
-- Creates a new instance of a registered network entity using the provided
-- ID, type, and instantiation parameters in the form of multiple unspecified
-- arguments that will be passed to the constructor of the local entity.
--
-- Subclasses call NetworkedEntity.registerEntityType(NetworkedEntitySubclass)
-- statically to register themselves so that their corresponding
-- createNewInstance method can be called.
--
-- If no entity has been associated with the given NetworkedEntityType, then this method
-- will return `nil`. Otherwise, if successful, the newly created entity will be
-- returned.
--
-- This method should **not** be called by subclasses.
--
-- manager: The NetworkedEntityManager that is invoking this method
-- id: The network ID that this new instance is assigned
-- entityType: The type of entity to instantiate
-- ...: The instantiation params to use when creating the new entity in the
--   form of multiple unspecified arguments. These arguments will be passed to
--   the newly created local instance. See `createNewInstanceWithParams` to
--   create a new entity with instantiation params received from a remote
--   instance.
--
function NetworkedEntity.createNewInstance(manager, id, entityType, ...)
  assert_that(id):is_a_number():and_return()
  
  -- Ensure supplied entityType is indeed an NetworkedEntityType.
  assert_that(entityType):is_a_number():is_a_key_in(NetworkedEntityType)
  
  -- Ensure entity type is registered. Otherwise, return nil.
  if not registeredEntities[entityType] then
    return nil
  end
  
  -- Try to catch infinite recursion if user fails to override this method.
  assert(
      registeredEntities[entityType].createNewInstance ~= NetworkedEntity.createNewInstance,
      "Make sure createNewInstance() is overridden")

  -- Instantiate and return new instance using given arguments.
  return registeredEntities[entityType].createNewInstance(
      manager, id, entityType, ...)
end



--
-- Instantiates a new NetworkedEntity.
--
function NetworkedEntity:_init(manager, networkId, entityType, params, entity)
  -- assert_that(manager):is_instance_of(NetworkedEntityManager) -- circular dependency
  assert_that(networkId):is_a_number():and_return()
  assert_that(entityType):is_a_number():is_a_key_in(NetworkedEntityType)
  assert_that(entity):is_instance_of(Entity)

  self.manager = manager
  self.id = networkId
  self.entityType = entityType
  self.entity = entity
  self.lockCounter = 0

  self.broadcasting = false
end

--
-- Gets the NetworkedEntityManager that created this NetworkedEntity.
--
function NetworkedEntity:getManager()
  return self.manager
end

--
-- Gets the network ID of this NetworkedEntity.
--
function NetworkedEntity:getNetworkId()
  return self.id
end

--
-- Gets the entity type of this NetworkedEntity.
--
function NetworkedEntity:getEntityType()
  return self.entityType
end

--
-- Gets the local entity.
--
function NetworkedEntity:getLocalEntity()
  return self.entity
end

--
-- Gets the owner ID of this networked entity. Default implementation returns
-- nil.
--
function NetworkedEntity:getOwnerId()
  return nil
end

--
-- Commands this entity to register any necessary listeners and begin
-- sending out incremental entity updates when necessary.
--
function NetworkedEntity:startBroadcastingUpdates()
  if PRINT_DEBUG then print("NetworkedEntity:startBroadcastingUpdates()") end
  self.broadcasting = true
end

function NetworkedEntity:isBroadcastingUpdates()
  return self.broadcasting
end

--
-- Commands this entity to unregister any necessary listeners and stop sending
-- out incremental entity updates.
--
function NetworkedEntity:stopBroadcastingUpdates()
  self.broadcasting = true
end

--
-- This method should be overridden and called by subclasses.
--
-- Given a params object, prompts this NetworkedEntity to put relevant
-- instantiation parameters into the provided object. This object will be used
-- to create local copies of this entity on connected instances. If no params
-- object is supplied, this method should still return a valid object
-- containing valid entity instantiation parameters.
--
-- Returns a params object containing the local entity's params.
--
function NetworkedEntity:getInstantiationParams(params)
  return params or {}
end

--
-- This method should be overridden and called by subclasses.
--
-- Sets the state of the NetworkedEntity based the contents of a received state
-- synchronization message.
--
function NetworkedEntity:setSynchronizedState(state)
end

--
-- This method should be overridden and called by subclasses.
--
-- Given a state object, prompts this NetworkedEntity to store its state into
-- the provided object. If no state object is supplied, this method shoud still
-- return a valid object containing this object's state.
--
-- Returns a state object containing the local entity's state.
--
function NetworkedEntity:getSynchronizedState(state)
  return state or {}
end

--
-- This method should be overridden and called by subclasses.
--
-- Triggers an incremental state change on the entity based on the contents of
-- a received state incrementing message. In other words, an object has moved
-- 10 pixels over of the object has jumped; something incremental has changed
-- about the entity and the entity should handle it appropriately.
--
function NetworkedEntity:performIncrementalUpdate(update)
  return true
end

--
-- Sends an incremental update to other connected entities through this class's
-- `EntityManager`.
--
-- *This method will not do anything if `isLocked()` is true.*
--
function NetworkedEntity:sendIncrementalUpdate(update)
  if self:isLocked() then return end
  if PRINT_DEBUG then print("NetworkedEntity:sendIncrementalUpdate()") end
  return self:getManager():publishIncrementalUpdate(self, update)
end

--
-- Deletes this entity; entity should be immediately destroyed and its
-- resources freed; no exceptions, and no animations.
--
function NetworkedEntity:delete()
  local entity = self:getLocalEntity()
  local manager = self:getManager()
  if not manager and not entity then
    return
  end

  self:stopBroadcastingUpdates()

  self.entity = nil
  self.manager = nil
  entity:destroy()
  manager:destroyEntity(self)
end

--
-- Increments the internal lock counter. Check if locks are currently in place
-- with `isLocked()`.
--
function NetworkedEntity:lock()
  self.lockCounter = self.lockCounter + 1
end

--
-- Decrements the internal lock counter. To check if locks are currently in
-- place with `isLocked()`.
--
function NetworkedEntity:unlock()
  self.lockCounter = self.lockCounter - 1
end

--
-- Checks if the entity is currently locked because of an event resolution
-- operation. Returns `true` if a lock is in place, `false` if not.
--
function NetworkedEntity:isLocked()
  return self.lockCounter > 0
end

return NetworkedEntity
