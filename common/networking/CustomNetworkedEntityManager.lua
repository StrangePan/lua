require "NetworkedEntityManager"

CustomNetworkedEntityManager = buildClass(NetworkedEntityManager)
local Class = CustomNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
end

require "NetworkedPlayer"
require "NetworkedActor"
require "NetworkedWall"
