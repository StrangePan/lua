local NetworkedActor = require "me.strangepan.games.mazerino.common.networking.NetworkedActor"
local Player = require "me.strangepan.games.mazerino.common.entities.Player"
local assert_that = require "me.strangepan.libs.lua.truth.v1.assert_that"
local class = require "me.strangepan.libs.lua.v1.class"
local NetworkedEntityType = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityType"

local PRINT_DEBUG = false

-- Message fields
local F_OWNER = "o"
local F_X = "x"
local F_Y = "y"
local F_RED = "r"
local F_GREEN = "g"
local F_BLUE = "b"

--
-- NetworkedPlayer for tying a Player to corresponding players on other instances.
--
local NetworkedPlayer = class.build(NetworkedActor)

--
-- Instantiates a Player and performs necessary setup.
--
function NetworkedPlayer.createNewInstanceWithParams(manager, id, entityType, params)
  if PRINT_DEBUG then print("NetworkedPlayer.createNewInstanceWithParams") end
  local ownerId = assert_that(params):is_a_number():and_return()
  return NetworkedPlayer(manager, id, entityType, params, Player(), ownerId)
end

--
-- Instantiates a Player and performs necessary setup.
--
function NetworkedPlayer.createNewInstance(manager, id, entityType, ...)
  local owner, x, y, r, g, b = ...
  return NetworkedPlayer.createNewInstanceWithParams(manager, id, entityType, {
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
NetworkedPlayer.registerEntityType(NetworkedEntityType.PLAYER, NetworkedPlayer)



function NetworkedPlayer:_init(manager, networkedId, entityType, params, player, ownerId)
  class.superclass(NetworkedPlayer)._init(self, manager, networkedId, entityType, params, player)
  assertNetworkedPlayer(player, Player)
  assert_that(ownerId):is_a_number():and_return()
  self.ownerId = ownerId
end

function NetworkedPlayer:getOwnerId()
  return self.ownerId
end

function NetworkedPlayer:getInstantiationParams(params)
  params = class.superclass(NetworkedPlayer).getInstantiationParams(self, params)
  return self:writePlayerState(params, "new")
end

--
-- Outputs the state of the player to the provided table.
-- Available modes:
-- - 'new': for new Players
-- - 'sync': for sync updates
--
function NetworkedPlayer:writePlayerState(state, mode)
  if mode == "new" then
    state[F_OWNER] = self:getOwnerId()
  end
  
  return state
end

return NetworkedPlayer
