local NetworkedEntityManager = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityManager"
local class = require "me.strangepan.libs.util.v1.class"

local CustomNetworkedEntityManager = class.build(NetworkedEntityManager)

function CustomNetworkedEntityManager:_init(connectionManager)
  NetworkedEntityManager._init(self, connectionManager)
end

return CustomNetworkedEntityManager
