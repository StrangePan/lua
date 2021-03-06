local NetworkedEntity = require "me.strangepan.games.mazerino.common.networking.NetworkedEntity"
local Wall = require "me.strangepan.games.mazerino.common.entities.Wall"
local class = require "me.strangepan.libs.util.v1.class"

local PRINT_DEBUG = false

-- Message fields.
local F_X = "x"
local F_Y = "y"

--
-- NetworkedWall for tying an wall entity to corresponding walls on other instances.
--
local NetworkedWall = class.build(NetworkedEntity)

--
-- Instantiates an Wall and performs necessary setup.
--
function NetworkedWall.createNewInstanceWithParams(manager, id, entityType, params)
  local x, y = params[F_X], params[F_Y]
  if PRINT_DEBUG then print ("NetworkedWall.createNewInstanceWithParams", x , y) end
  local wall = Wall(x, y)
  return NetworkedWall(manager, id, entityType, params, wall)
end

--
-- Instantiates an Actor and performs necessary setup.
--
function NetworkedWall.createNewInstance(manager, id, entityType, ...)
  local x, y = ...
  return NetworkedWall.createNewInstanceWithParams(manager, id, entityType, {
      [F_X] = x,
      [F_Y] = y,
  })
end

function NetworkedWall:_init(manager, networkedId, entityType, params, wall)
  NetworkedEntity._init(self, manager, networkedId, entityType, params, wall)
end

function NetworkedWall:getInstantiationParams(params)
  params = NetworkedEntity.getInstantiationParams(self, params)
  return self:writeWallState(params)
end

function NetworkedWall:setSynchronizedState(state)
  NetworkedEntity.setSynchronizedState(self, state)
  local wall = self:getLocalEntity()
  local x, y = state[F_X], state[F_Y]
  if x and y then
    wall:setPosition(x, y)
  end
end

function NetworkedWall:getSynchronizedState(state)
  state = NetworkedEntity.getSynchronizedState(self, state)
  return self:writeWallState(state)
end

--
-- Outputs the state of the wall to the provided table.
--
function NetworkedWall:writeWallState(state)
  local wall = self:getLocalEntity()
  local x, y = wall:getPosition()
  state[F_X] = x
  state[F_Y] = y
  return state
end

return NetworkedWall
