require "strangepan.util.class"
require "strangepan.util.type"
require "networking.ConnectionStatus"

--
-- Class for maintaining information on connections. Rather than using a
-- generic table, allows us to keep a record of exactly what datas are
-- available, check class, etc.
--
Connection = buildClass()
local Class = Connection

function Class:_init(networkId, address, port, initTime)

  -- The unique identifier of this connection. Should never change.
  self.id = assertNumber(networkId, "networkId")
  
  -- The IP address of this connection. Should never change.
  self.address = assertString(address, "address")
  
  -- The port number of this connection. Should never change.
  self.port = assertNumber(port, "port")

  -- The connection status; defaults to ConnectionStatus.DISCONNECTED.
  self.status = ConnectionStatus.DISCONNECTED
  
  -- The last numeric time a message was received from this connection.
  -- Defaults to 0
  self.lastReceivedTime = 0
  
  -- The last numeric time this connection was sent a message.
  -- Defaults to 0
  self.lastSentTime = 0

  -- Did we init the connection? If false, a remote instance initiated.
  self.didInit = false

  -- Time connection was initiated. In the case of an incoming connection, time
  -- when initial contact was received.
  self.initTime = initTime or os.time()
end
