require "common/class"
require "common/functions"
require "ConnectionStatus"

--
-- Class for maintaining information on connections. Rather than using a
-- generic table, allows us to keep a record of exactly what datas are
-- available, check class, etc.
--
Connection = buildClass()
local Class = Connection

function Class:_init(networkId, address, port)
  assertType(networkId, "networkId", "number")
  assertType(address, "address", "string")
  assertType(port, "port", "number")
  
  -- The unique identifier of this connection. Should never change.
  self.id = networkId
  
  -- The IP address of this connection. Should never change.
  self.address = address
  
  -- The port number of this connection. Should never change.
  self.port = port
  
  -- The connection status; defaults to ConnectionStatus.DISCONNECTED.
  self.status = ConnectionStatus.DISCONNECTED
  
  -- The last numeric time a message was received from this connection.
  -- Defaults to 0
  self.lastReceivedTime = 0
  
  -- The last numeric time this connection was sent a message.
  -- Defaults to 0
  self.lastSentTime = 0
end
