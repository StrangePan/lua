require "common/class"
require "MessageReceiver"
require "MessageSender"
require "ConnectionStatus"

-- message handler and coordinator for clients

ClientConnection = buildClass()

--
-- Initializes a new connection object optimized for clients. Registers
-- as a listener for messageReceiver's messages and automaticaly handles
-- communication with server.
--
function ClientConnection:_init()
  
  self.serverAddress = '127.0.0.1'
  self.serverPort = 25565
  self.server = {
    address = self.serverAddress,
    port = self.serverPort
  }
  
  -- Initialize udp connection object
  self.socket = require "socket"
  self.udp = socket:udp()
  self.udp:settimeout(0)
  local res,err = self.udp:setsockname('*', 25565)
  if res == nil then
    print(err)
    return
  end
  
  -- Initialize status variables
  self.connectionStatus = ConnectionStatus.DISCONNECTED
  self.connectionid = nil
  self.connectionSendTime = nil
  
  -- Initialize sender/receiver objects
  self.sender = MessageSender(self.udp)
  self.receiver = MessageReceiver(self.udp)
  
  -- Register for message callbacks
  self.receiver:registerListener(MessageType.SERVER_CONNECT_ACK,
    self, self.onReceiveServerConnectAck)
  
end

--
-- Gets the current status of the connection with the server.
-- Returns a ConnectionStatus enum value.
--
function ClientConnection:getConnectionStatus()
  return self.connectionStatus
end

--
-- Changes the connection status and notifies registered listeners if
-- necessary.
--
function ClientConnection:setConnectionStatus(status)
  self.connectionStatus = status
end

function ClientConnection:connectToServer()
  
  -- ignore command if already connected/connecting
  if self:getConnectionStatus() ~= ConnectionStatus.DISCONNECTED then
    return
  end
  
  -- initialize connection protocol
  self:requestConnectToServer()
  self:setConnectionStatus(ConnectionStatus.CONNECTING)
end

function ClientConnection:requestConnectToServer()
  print("ping server @ "..self.serverAddress..":"..self.serverPort)
  self.sender:sendMessage(messages.clientConnectInit(), self.server)
  self.connectionSendTime = love.timer.getTime()
end

--
-- Reads and processes incoming messages
--
function ClientConnection:update()
  self.receiver:processIncomingMessages()
  
  if self:getConnectionStatus() == ConnectionStatus.CONNECTING and
      love.timer.getTime() >= self.connectionSendTime + 3 then
    self:requestConnectToServer()
  end
end

--
-- Handles an incoming message of type MessageType.SERVER_CONNECT_ACK
--
function ClientConnection:onReceiveServerConnectAck(message, address, port)
  if self:shouldIgnore(message, address, port) then return end
  
  -- ignore message if not looking to connect
  if self:getConnectionStatus() ~= ConnectionStatus.CONNECTING then return end
  
  self.connectionid = message.id
  self:setConnectionStatus(ConnectionStatus.CONNECTED)
end

--
-- returns true if the given message should not be processed
--
function ClientConnection:shouldIgnore(message, address, port)
  return address ~= self.serverAddress or port ~= self.serverPort
end
