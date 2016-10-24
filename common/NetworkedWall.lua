require "NetworkedEntity"
require "Wall"

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
function Class.createNewInstance(manager, id, entityType, params, wall)
  wall = wall or Wall()
  assertType(wall, "wall", Wall)
  local instance = Class(manager, id, entityType, params, wall)
  instance:setSynchronizedState(params)
  return instance
end

--
-- Registers this class to be instantiated by the network.
--
Class.registerEntityType(EntityType.WALL, Class)



function Class:_init(manager, networkedId, entityType, params, wall)
  Class.superclass._init(self, manager, networkedId, entityType, params, wall)
end

function Class:setSynchronizedState(state)
  Class.superclass.setSynchronizedState(self, state)
  local wall = self:getLocalEntity()
  local x, y = state[F_X], state[F_Y]
  wall:setPosition(x, y)
end

function Class:getSynchronizedState(state)
  Class.superclass.getSynchronizedState(self, state)
  local wall = self:getLocalEntity()
  local x, y = wall:getPosition()
  state[F_X] = x
  state[F_Y] = y
end
