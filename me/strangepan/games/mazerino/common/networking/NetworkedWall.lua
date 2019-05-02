require "me.strangepan.games.mazerino.common.networking.NetworkedEntity"
require "me.strangepan.games.mazerino.common.entities.Wall"

-- Message fields.
local F_X = "x"
local F_Y = "y"

--
-- Class for tying an wall entity to corresponding walls on other instances.
--
NetworkedWall = buildClass(NetworkedEntity)
local Class = NetworkedWall

--
-- Instantiates an Wall and performs necessary setup.
--
function Class.createNewInstanceWithParams(manager, id, entityType, params)
  local x, y = params[F_X], params[F_Y]
  local wall = Wall(x, y)
  return Class(manager, id, entityType, params, wall)
end

--
-- Instantiates an Actor and performs necessary setup.
--
function Class.createNewInstance(manager, id, entityType, ...)
  local x, y = ...
  return Class.createNewInstanceWithParams(manager, id, entityType, {
      [F_X] = x,
      [F_Y] = y,
  })
end

--
-- Registers this class to be instantiated by the network.
--
Class.registerEntityType(NetworkedEntityType.WALL, Class)



function Class:_init(manager, networkedId, entityType, params, wall)
  Class.superclass._init(self, manager, networkedId, entityType, params, wall)
end

function Class:getInstantiationParams(params)
  params = Class.superclass.getInstantiationParams(self, params)
  return self:writeWallState(params)
end

function Class:setSynchronizedState(state)
  Class.superclass.setSynchronizedState(self, state)
  local wall = self:getLocalEntity()
  local x, y = state[F_X], state[F_Y]
  if x and y then
    wall:setPosition(x, y)
  end
end

function Class:getSynchronizedState(state)
  state = Class.superclass.getSynchronizedState(self, state)
  return self:writeWallState(state)
end

--
-- Outputs the state of the wall to the provided table.
--
function Class:writeWallState(state)
  local wall = self:getLocalEntity()
  local x, y = wall:getPosition()
  state[F_X] = x
  state[F_Y] = y
  return state
end
