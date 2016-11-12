require "NetworkedActor"
require "Player"

local PRINT_DEBUG = false

-- Message fields
local F_OWNER = "owner"
local F_X = "x"
local F_Y = "y"
local F_RED = "r"
local F_GREEN = "g"
local F_BLUE = "b"

--
-- Class for tying a Player to corresponding players on other instances.
--
NetworkedPlayer = buildClass(NetworkedActor)
local Class = NetworkedPlayer

--
-- Instantiates a Player and performs necessary setup.
--
function Class.createNewInstanceWithParams(manager, id, entityType, params)
  if PRINT_DEBUG then print("NetworkedPlayer.createNewInstanceWithParams") end
  local ownerId = assertType(params[F_OWNER], "number")
  return Class(manager, id, entityType, params, Player(), ownerId)
end

--
-- Instantiates a Player and performs necessary setup.
--
function Class.createNewInstance(manager, id, entityType, ...)
  local owner, x, y, r, g, b = ...
  return Class.createNewInstanceWithParams(manager, id, entityType, {
      [F_OWNER] = owner,
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
Class.registerEntityType(NetworkedEntityType.PLAYER, Class)



function Class:_init(manager, networkedId, entityType, params, player, ownerId)
  Class.superclass._init(self, manager, networkedId, entityType, params, player)
  assertType(player, Player)
  assertType(ownerId, "number")
  self.ownerId = ownerId
end

function Class:getOwnerId()
  return self.ownerId
end

function Class:getInstantiationParams(params)
  params = Class.superclass.getInstantiationParams(self, params)
  return self:writePlayerState(params, "new")
end

--
-- Outputs the state of the player to the provided table.
-- Available modes:
-- - 'new': for new Players
-- - 'sync': for sync updates
--
function Class:writePlayerState(state, mode)
  if mode == "new" then
    state[F_OWNER] = self:getOwnerId()
  end
  
  return state
end
