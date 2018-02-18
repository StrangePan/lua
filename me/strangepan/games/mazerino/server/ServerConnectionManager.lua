require "networking.ConnectionManager"

--
-- Connection handler for servers; maintains connections to multiple clients.
-- Sends periodic pings to clients in order to keep the connection alive.
--
ServerConnectionManager = buildClass(ConnectionManager)
local Class = ServerConnectionManager

function Class:_init()
  Class.superclass._init(self, 25565)
end
