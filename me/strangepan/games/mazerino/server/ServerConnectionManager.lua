local ConnectionManager = require "me.strangepan.games.mazerino.common.networking.ConnectionManager"
local class = require "me.strangepan.libs.util.v1.class"

--
-- Connection handler for servers; maintains connections to multiple clients.
-- Sends periodic pings to clients in order to keep the connection alive.
--
local ServerConnectionManager = class.build(ConnectionManager)

function ServerConnectionManager:_init()
  class.superclass(ServerConnectionManager)._init(self, 25565)
end

return ServerConnectionManager
