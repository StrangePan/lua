local NetworkedEntity = require "me.strangepan.games.mazerino.common.networking.NetworkedEntity"
local Actor = require "me.strangepan.games.mazerino.common.entities.Actor"
local Color = require "me.strangepan.games.mazerino.common.Color"
local class = require "me.strangepan.libs.lua.v1.class"
local NetworkedEntityType = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityType"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

-- Message fields.
local F_X = "x"
local F_Y = "y"
local F_RED = "r"
local F_GREEN = "g"
local F_BLUE = "b"
local F_DIR = "d"
local F_SUCCESS = "s"
local F_UPDATE_TYPE = "i" -- incremental update type

-- Incremental update types
local T_STEP = 1
local T_SPIN = 2

--
-- NetworkedActor for tying an actor entity to corresponding actors on other instances.
--
local NetworkedActor = class.build(NetworkedEntity)

--
-- Instantiates an Actor and performs necessary setup.
--
function NetworkedActor.createNewInstanceWithParams(manager, id, entityType, params)
  return NetworkedActor(manager, id, entityType, params, Actor())
end

--
-- Instantiates an Actor and performs necessary setup.
--
function NetworkedActor.createNewInstance(manager, id, entityType, ...)
  local x, y, r, g, b = ...
  return NetworkedActor.createNewInstanceWithParams(manager, id, entityType, {
      [F_X] = x,
      [F_Y] = y,
      [F_RED] = r,
      [F_GREEN] = g,
      [F_BLUE] = b,
  })
end

function NetworkedActor:_init(manager, networkedId, entityType, params, actor)
  class.superclass(NetworkedActor)._init(self, manager, networkedId, entityType, params, actor)
  assert_that(actor):is_instance_of(Actor)
  self:setActorState(params)
end

function NetworkedActor:startBroadcastingUpdates()
  if self:isBroadcastingUpdates() then return end
  class.superclass(NetworkedActor).startBroadcastingUpdates(self)

  -- Register for listener callbacks
  local actor = self:getLocalEntity()
  actor:registerMoveListener(self, self.onActorStep)
  actor:registerSpinListener(self, self.onActorSpin)
end

function NetworkedActor:stopBroadcastingUpdates()
  if not self:isBroadcastingUpdates() then return end
  local actor = self:getLocalEntity()
  actor:unregisterMoveListener(self, self.onActorStep)
  actor:unregisterSpinListener(self, self.onActorSpin)

  class.superclass(NetworkedActor).stopBroadcastingUpdates(self)
end

function NetworkedActor:getInstantiationParams(params)
  params = class.superclass(NetworkedActor).getInstantiationParams(self, params)
  return self:writeActorState(params, "new")
end

function NetworkedActor:setSynchronizedState(state)
  class.superclass(NetworkedActor).setSynchronizedState(self, state)
  self:setActorState(state)
end

--
-- Sets the state of the actor given a params/state object.
--
function NetworkedActor:setActorState(state)
  self:lock()
  local actor = self:getLocalEntity()
  local x, y = state[F_X], state[F_Y]
  local r, g, b = state[F_RED], state[F_GREEN], state[F_BLUE]
  if x and y then
    actor:setPosition(x, y)
  end
  if r and g and b then
    actor:setColor(Color(r, g, b))
  end
  self:unlock()
end

function NetworkedActor:getSynchronizedState(state)
  state = class.superclass(NetworkedActor).getSynchronizedState(self, state)
  return self:writeActorState(state, "sync")
end

--
-- Outputs the state of the actor to the provided table.
-- Available modes:
-- - 'new': for new Actors
-- - 'sync': for sync updates
--
function NetworkedActor:writeActorState(state, mode)
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

function NetworkedActor:performIncrementalUpdate(update)
  self:lock()
  local inSync = class.superclass(NetworkedActor).performIncrementalUpdate(self, update)

  if inSync then
    local updateType = update[F_UPDATE_TYPE]
    if updateType == T_STEP then
      inSync = self:performStepUpdate(update)
    elseif updateType == T_SPIN then
      inSync = self:performSpinUpdate(update)
    end
  end
  self:unlock()

  return inSync
end

--
-- Handles actors being moved.
--
function NetworkedActor:performStepUpdate(update)
  self:lock()
  local inSync = true
  local actor = self:getLocalEntity()
  local dir = update[F_DIR]
  local didMove = update[F_SUCCESS]

  -- Make sure actor is located where it's supposed to be.
  local x, y = actor:getPosition()
  if x ~= update[F_X] or y ~= update[F_Y] then
    inSync = false
  end

  -- If the update says the actor has moved, then force movement.
  -- Move the actor
  if inSync then
    inSync = actor:move(dir) == didMove
  end
  self:unlock()

  return inSync
end

--
-- Handles actors emoting a spin
--
function NetworkedActor:performSpinUpdate(update)
  self:lock()
  local actor = self:getLocalEntity()
  local inSync = actor:spin()
  self:unlock()
  return inSync
end

--
-- Builds incremental update message for an actor stepping.
--
function NetworkedActor:buildStepUpdate(x, y, dir, success)
  local msg = {}
  msg[F_UPDATE_TYPE] = T_STEP
  msg[F_X] = x
  msg[F_Y] = y
  msg[F_DIR] = dir
  msg[F_SUCCESS] = success
  return msg
end

--
-- Builds incremental update message for an actor spinning.
--
function NetworkedActor:buildSpinUpdate()
  local msg = {}
  msg[F_UPDATE_TYPE] = T_SPIN
  return msg
end

--
-- Handles actor stepping.
--
function NetworkedActor:onActorStep(actor, x, y, dir, success)
  if self:isLocked() or self:getLocalEntity() ~= actor then return end
  self:sendIncrementalUpdate(self:buildStepUpdate(x, y, dir, success))
end

--
-- Handles actors spinning.
--
function NetworkedActor:onActorSpin(actor)
  if self:isLocked() or self:getLocalEntity() ~= actor then return end
  self:sendIncrementalUpdate(self:buildSpinUpdate())
end

return NetworkedActor
