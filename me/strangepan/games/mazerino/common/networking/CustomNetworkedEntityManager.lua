local NetworkedEntityManager = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityManager"
local class = require "me.strangepan.libs.lua.v1.class"

local CustomNetworkedEntityManager = class.build(NetworkedEntityManager)

function CustomNetworkedEntityManager:_init(connectionManager)
  class.superclass(CustomNetworkedEntityManager)._init(self, connectionManager)
end

local NetworkedPlayer = require "me.strangepan.games.mazerino.common.networking.NetworkedPlayer"
local NetworkedActor = require "me.strangepan.games.mazerino.common.networking.NetworkedActor"
local NetworkedWall = require "me.strangepan.games.mazerino.common.networking.NetworkedWall"
