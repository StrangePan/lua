require "common/functions"
require "CustomNetworkedEntityManager"
require "ClientConnectionManager"

--
-- Client-specific entity manager. Ignores updates from anyone other than the
-- server.
--
ClientNetworkedEntityManager = buildClass(CustomNetworkedEntityManager)
local Class = ClientNetworkedEntityManager

function Class:_init(connectionManager)
  Class.superclass._init(self, connectionManager)
  assertType(connectionManager, ClientConnectionManager)
end

function Class:onReceiveEntityUpdate(message, connectionId)
  local server = self.connectionManager:getServerConnection()
  
  -- Ignore any incoming messages from anyone other than the server
  if not server or server.id ~= connectionId then
    return
  end
  
  return Class.superclass.onReceiveEntityUpdate(self, message, connectionId)
end
