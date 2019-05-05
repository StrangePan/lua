local class = require "me.strangepan.libs.util.v1.class"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local ConnectionStatus = require "me.strangepan.games.mazerino.common.networking.ConnectionStatus"

--
-- Class for maintaining information on connections. Rather than using a
-- generic table, allows us to keep a record of exactly what datas are
-- available, check class, etc.
--
local Connection = class.build()

function Connection:_init(networkId, address, port, initTime)

  -- The unique identifier of this connection. Should never change.
  self.id = assert_that(networkId):is_a_number():and_return()
  
  -- The IP address of this connection. Should never change.
  self.address = assert_that(address):is_a_string():and_return()
  
  -- The port number of this connection. Should never change.
  self.port = assert_that(port):is_a_number():and_return()

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

return Connection
