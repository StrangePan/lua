require "common/class"
require "MessageReceiver"
require "MessageSender"
require "ConnectionStatus"

ServerConnection = buildClass()

function ServerConnection:_init()
  
  -- Initialize udp connection object
  self.socket = require "socket"
  self.udp = socket:udp()
  self.udp:settimeout(0)
  local res,err = self.udp:setsockname('*', 25565)
  if res == nil then
    print(err)
    return
  end
  
  -- Initialize clients table
  self.clients = {n = 0}
  
  -- Initialize sender/receiver objects
  self.sender = MessageSender(self.udp)
  self.receiver = MessageReceiver(self.udp)
  
  -- Register for message callbacks
  self.receiver:registerListener(MessageType.CLIENT_CONNECT_INIT,
    self, self.onReceiveClientConnectInit)
  
  self.receiver:registerListener(MessageType.CLIENT_DISCONNECT,
    self, self.onReceiveClientDisconnect)
  
  self.receiver:registerListener(MessageType.PING,
    self, self.onReceivePing)
  
end

function ServerConnection:update()
  self.receiver:processIncomingMessages()
  
  local time = love.timer.getTime()
  for id,client in ipairs(self.clients) do
    
    -- periodically ping client
    if time >= client.lastSentTime + 2 then
      self:sendMessage(messages.ping(), id)
    end
    
    -- handle timeouts
    if client.connectionStatus == ConnectionStatus.CONNECTED and
        time >= client.lastReceivedTime + 5 then
      client.connectionStatus = ConnectionStatus.STALLED
      print("connection to client "..id.." stalled")
    elseif client.connectionStatus == ConnectionStatus.STALLED and
        time >= client.lastReceivedTime + 30 then
      self:disconnectClient(id)
      print("connection timed out")
    end
  end
end

function ServerConnection:disconnectClient(id)
  local client = self.clients[id]
  local clientString = self:createClientString(client.address, client.port)
  self.clients[id] = nil
  self.clients[clientString] = nil
  print("disconnected client "..id.." @ "..clientString)
end

function ServerConnection:onReceiveClientConnectInit(message, address, port)
  local clientId = self:getClientId(address, port)
  if clientId == nil then
    self.clients.n = self.clients.n + 1
    clientId = self.clients.n
    self.clients[clientId] = {
      address = address,
      port = port,
      connectionStatus = ConnectionStatus.CONNECTED,
      lastReceivedTime = love.timer.getTime()
    }
    local clientString = self:createClientString(address, port)
    self.clients[clientString] = clientId
    print("connected to new client "..clientString.." with id "..clientId)
  end
  local client = self.clients[clientId]
  client.lastReceivedTime = love.timer.getTime()
  
  self:sendMessage(messages.serverConnectAck(clientId), clientId)
end

function ServerConnection:onReceiveClientDisconnect(message, address, port)
  local clientId = self:getClientId(address, port)
  if clientId == nil then return end
  
  local client = self.clients[clientId]
  client.lastReceivedTime = love.timer.getTime()
  self:disconnectClient(clientId)
end

function ServerConnection:onReceivePing(message, address, port)
  local clientId = self:getClientId(address, port)
  if clientId == nil then return end
  local client = self.clients[clientId]
  client.lastReceivedTime = love.timer.getTime()
  print("received ping from "..clientId)
end

--
-- Returns the ID of a client based on address and port
--
function ServerConnection:getClientId(address, port)
  local clientString = self:createClientString(address, port)
  if self.clients[clientString] then
    return self.clients[clientString]
  end
  return nil
end

function ServerConnection:createClientString(address, port)
  return string.format("%s:%s", address, port)
end

function ServerConnection:sendMessage(message, ...)
  local clientIds = {...}
  local clients = {}
  local time = love.timer.getTime()
  for _,clientId in ipairs(clientIds) do
    clients[clientId] = self.clients[clientId]
    clients[clientId].lastSentTime = time
  end
  self.sender:sendMessage(message, unpack(clients))
end
