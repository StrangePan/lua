require "me.strangepan.games.mazerino.common.networking.NetworkedEntityManager"

CustomNetworkedEntityManager = buildClass(NetworkedEntityManager)
local Class = CustomNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
end

require "me.strangepan.games.mazerino.common.networking.NetworkedPlayer"
require "me.strangepan.games.mazerino.common.networking.NetworkedActor"
require "me.strangepan.games.mazerino.common.networking.NetworkedWall"
