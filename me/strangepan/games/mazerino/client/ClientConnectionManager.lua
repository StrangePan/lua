local ConnectionManager = require "me.strangepan.games.mazerino.common.networking.ConnectionManager"
local class = require "me.strangepan.libs.lua.v1.class"

--
-- Message handler and coordinator for clients.
--
local ClientConnectionManager = class.build(ConnectionManager)

--
-- Initializes a new connection object optimized for clients. Registers
-- as a listener for messageReceiver's messages and automaticaly handles
-- communication with server.
--
function ClientConnectionManager:_init()
  math.randomseed(os.time())
  class.superclass(ClientConnectionManager)._init(self, math.random(25566, 25666))

  -- Constant values
  --self.serverAddress = '74.51.150.17'
  self.serverAddress = '127.0.0.1'
  self.serverPort = 25565
  
  self.playerId = nil
end

function ClientConnectionManager:connectToServer()
  -- Initiate connection protocol to server.
  self:initiateConnection(self.serverAddress, self.serverPort)
end

--
-- Gets the connection object representing the server.
--
function ClientConnectionManager:getServerConnection()
  return self:getConnection(self.serverAddress, self.serverPort)
end

--
-- Handle connection to server.
--
function ClientConnectionManager:onReceiveConnectionAck(message, address, port)
  class.superclass(ClientConnectionManager).onReceiveConnectionAck(self, message, address, port)
  if address ~= self.serverAddress or port ~= self.serverPort then
    return
  end
  self.playerId = message.p
end

return ClientConnectionManager
