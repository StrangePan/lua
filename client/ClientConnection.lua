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
  local res,err = self.udp:setsockname('*', 25566)
  if res == nil then
    print(err)
    return
  end
  
  -- Initialize status variables
  self.connectionStatus = ConnectionStatus.DISCONNECTED
  self.connectionId = nil
  self.connectionSendTime = nil
  self.lastReceivedTime = nil
  self.lastSentTime = nil
  
  -- Initialize sender/receiver objects
  self.sender = MessageSender(self.udp)
  self.receiver = MessageReceiver(self.udp)
  
  -- Register for message callbacks
  self.receiver:registerListener(MessageType.SERVER_CONNECT_ACK,
    self, self.onReceiveServerConnectAck)
  
  self.receiver:registerListener(MessageType.PING,
    self, self.onReceivePing)
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
  print("attempting to connect to server @ "..self.serverAddress..":"..self.serverPort)
  self:sendMessage(messages.clientConnectInit())
  self.connectionSendTime = love.timer.getTime()
end

function ClientConnection:disconnectFromServer()
  if self:getConnectionStatus() == ConnectionStatus.DISCONNECTED then
    return
  end
  print("disconnected from server")
  self:sendMessage(messages.clientDisconnect())
  self.connectionSendTime = nil
  self.lastReceivedTime = nil
  self.connectionId = nil
  self:setConnectionStatus(ConnectionStatus.DISCONNECTED)
end

--
-- Reads and processes incoming messages
--
function ClientConnection:update()
  self.receiver:processIncomingMessages()
  
  local time = love.timer.getTime()
  
  -- ping server periodically
  if time >= self.lastSentTime + 2 then
    self:sendMessage(messages.ping())
  end
  
  -- handle timeouts
  if self:getConnectionStatus() == ConnectionStatus.CONNECTING and
      time >= self.connectionSendTime + 3 then
    self:requestConnectToServer()
  elseif self:getConnectionStatus() == ConnectionStatus.CONNECTED and
      time >= self.lastReceivedTime + 5 then
    self:setConnectionStatus(ConnectionStatus.STALLED)
    print("connection stalled")
  elseif self:getConnectionStatus() == ConnectionStatus.STALLED and
      time >= self.lastReceivedTime + 30 then
    self:disconnectFromServer()
    print("connection timed out")
  end
end

--
-- Handles an incoming message of type MessageType.SERVER_CONNECT_ACK
--
function ClientConnection:onReceiveServerConnectAck(message, address, port)
  if self:shouldIgnore(message, address, port) then return end
  self:updateLastReceivedTime()
  
  -- ignore message if not looking to connect
  if self:getConnectionStatus() ~= ConnectionStatus.CONNECTING then return end
  
  print("connected to server with client id "..message.id)
  self.connectionId = message.id
  self:setConnectionStatus(ConnectionStatus.CONNECTED)
end

function ClientConnection:onReceivePing(message, address, port)
  if self:shouldIgnore(message, address, port) then return end
  self:updateLastReceivedTime()
  print("received ping")
end

--
-- returns true if the given message should not be processed
--
function ClientConnection:shouldIgnore(message, address, port)
  return address ~= self.serverAddress or port ~= self.serverPort
end

--
-- Updates the last received message time to prevent connection going stale
--
function ClientConnection:updateLastReceivedTime()
  self.lastReceivedTime = love.timer.getTime()
  if self:getConnectionStatus() == ConnectionStatus.STALLED then
    self:setConnectionStatus(ConnectionStatus.CONNECTED)
  end
end

function ClientConnection:sendMessage(message)
  self.sender:sendMessage(message, self.server)
  self.lastSentTime = love.timer.getTime()
end
