require "NetworkedEntity"
require "Actor"
require "Color"

-- Message fields.
local F_X = "x"
local F_Y = "y"
local F_RED = "r"
local F_GREEN = "g"
local F_BLUE = "b"
local F_FROM = "from"
local F_TO = "to"
local F_DIR = "dir"
local F_UPDATE_TYPE = "type"

-- Update types
local T_MOVE = 1
local T_SPIN = 2

--
-- Class for tying an actor entity to corresponding actors on other instances.
--
NetworkedActor = buildClass(NetworkedEntity)
local Class = NetworkedActor

--
-- Instantiates an Actor and performs necessary setup.
--
function Class.createNewInstanceWithParams(manager, id, entityType, params)
  return Class(manager, id, entityType, params, Actor())
end

--
-- Instantiates an Actor and performs necessary setup.
--
function Class.createNewInstance(manager, id, entityType, ...)
  local x, y, r, g, b = ...
  return Class.createNewInstanceWithParams(manager, id, entityType, {
      [F_X] = x,
      [F_Y] = y,
      [F_RED] = r,
      [F_GREEN] = g,
      [F_BLUE] = b,
  })
end

--
-- Registers this class to be instantiated by the network.
--
Class.registerEntityType(NetworkedEntityType.ACTOR, Class)



function Class:_init(manager, networkedId, entityType, params, actor)
  Class.superclass._init(self, manager, networkedId, entityType, params, actor)
  assertType(actor, "actor", Actor)
  self:setActorState(params)
end

function Class:getInstantiationParams(params)
  params = Class.superclass.getInstantiationParams(self, params)
  return self:writeActorState(params, "new")
end

function Class:setSynchronizedState(state)
  Class.superclass.setSynchronizedState(self, state)
  self:setActorState(state)
end

--
-- Sets the state of the actor given a params/state object.
--
function Class:setActorState(state)
  local actor = self:getLocalEntity()
  local x, y = state[F_X], state[F_Y]
  local r, g, b = state[F_RED], state[F_GREEN], state[F_BLUE]
  if x and y then
    actor:setPosition(x, y)
  end
  if r and g and b then
    actor:setColor(Color(r, g, b))
  end
end

function Class:getSynchronizedState(state)
  state = Class.superclass.getSynchronizedState(self, state)
  return self:writeActorState(state, "sync")
end

--
-- Outputs the state of the actor to the provided table.
-- Available modes:
-- - 'new': for new Actors
-- - 'sync': for sync updates
--
function Class:writeActorState(state, mode)
  local actor = self:getLocalEntity()
  local x, y = actor:getPosition()
  state[F_X] = x
  state[F_Y] = y
  
  if mode == "new" then
    local r, g, b = actor:getColor():getRGBA()
    state[F_RED] = r
    state[F_GREEN] = g
    state[F_BLUE] = b
  end
  
  return state
end

function Class:performIncrementalUpdate(update)
  Class.superclass.performIncrementalUpdate(self, update)
  local updateType = update[F_UPDATE_TYPE]
  if updateType == T_MOVE then
    self:performMoveUpdate(update)
  elseif updateType == T_SPIN then
    self:performSpinUpdate(update)
  end
end

--
-- Handles actors being moved
--
function Class:performMoveUpdate(update)
  local actor = self:getLocalEntity()
  local from = update[F_FROM]
  local to = update[F_TO]
  local dir = update[F_DIR]
  
  -- Make sure actor is located where it's supposed to be
  local x, y = actor:getPosition()
  if x ~= from[F_X] or y ~= from[F_Y] then
    actor:setPosition(from[F_X], from[F_Y])
  end
  
  -- If the update says the actor has moved, then force movement
  local force = x ~= to[F_X] or y ~= to[F_Y]
  
  -- Move the actor
  actor:move(update[F_DIR], force)
  
  -- If the actor for some reason is not located where it's supposed to be,
  -- the force-set it's position.
  x, y = actor:getPosition()
  if x ~= to[F_X] or y ~= to[F_Y] then
    actor:setPosition(to[F_X], to[F_Y])
  end
end

--
-- Handles actors emoting a spin
--
function Class:performSpinUpdate(update)
  local actor = self:getLocalEntity()
  actor:spin()
end
