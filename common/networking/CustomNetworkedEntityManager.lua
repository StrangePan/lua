require "networking.NetworkedEntityManager"

CustomNetworkedEntityManager = buildClass(NetworkedEntityManager)
local Class = CustomNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
end

require "networking.NetworkedPlayer"
require "networking.NetworkedActor"
require "networking.NetworkedWall"
