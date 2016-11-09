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
  
  self.playerId = nil
end

function Class:connectToServer()
  -- Initiate connection protocol to server.
  self:initiateConnection(self.serverAddress, self.serverPort)
end

--
-- Gets the connection object representing the server.
--
function Class:getServerConnection()
  return self:getConnection(self.serverAddress, self.serverPort)
end

--
-- Handle connection to server.
--
function Class:onReceiveConnectionAck(message, address, port)
  Class.superclass.onReceiveConnectionAck(self, message, address, port)
  if address ~= self.serverAddress or port ~= self.serverPort then
    return
  end
  self.playerId = message.pid
end
