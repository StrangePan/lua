require "ConnectionManager"

--
-- Message handler and coordinator for clients.
--
ClientConnectionManager = buildClass(ConnectionManager)
local Class = ClientConnectionManager

--
-- Initializes a new connection object optimized for clients. Registers
-- as a listener for messageReceiver's messages and automaticaly handles
-- communication with server.
--
function Class:_init()
  Class.superclass._init(self, 25566)

  -- Constant values
  self.serverAddress = '127.0.0.1'
  self.serverPort = 25565
end

function Class:connectToServer()
  -- Initiate connection protocol to server.
  self:initiateConnection(self.serverAddress, self.serverPort)
end
