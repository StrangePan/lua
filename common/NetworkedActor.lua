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
function Class.createNewInstance(manager, id, entityType, params, actor)
  actor = actor or Actor()
  assertType(actor, "actor", Actor)
  local instance = Class(manager, id, entityType, params, actor)
  instance:setSynchronizedState(params)
  return instance
end

--
-- Registers this class to be instantiated by the network.
--
Class.registerEntityType(EntityType.ACTOR, Class)



function Class:_init(manager, networkedId, entityType, params, actor)
  Class.superclass._init(self, manager, networkedId, entityType, params, actor)
end

function Class:setSynchronizedState(state)
  Class.superclass.setSynchronizedState(self, state)
  local actor = self:getLocalEntity()
  local x, y = state[F_X], state[F_Y]
  local r, g, b = state[F_RED], state[F_GREEN], state[F_BLUE]
  actor:setPosition(x, y)
  actor:setColor(Color(r, g, b))
end

function Class:getSynchronizedState(state)
  Class.superclass.getSynchronizedState(self, state)
  local actor = self:getLocalEntity()
  local x, y = actor:getPosition()
  local r, g, b = actor:getColor():getRGBA()
  state[F_X] = x
  state[F_Y] = y
  color[F_RED] = r
  color[F_GREEN] = g
  color[F_BLUE] = b
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
