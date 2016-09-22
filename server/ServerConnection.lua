require "Connection"
require "ConnectionStatus"

ServerConnection = buildClass(Connection)
local Class = ServerConnection

function Class:_init()
  Class.superclass._init(self, 25565)
  
  -- Initialize clients table
  self.clients = {}
  self.clientIds = {n = 0}
  self.nextId = 1
  
  -- Register for message callbacks
  self.receiver:registerListener(MessageType.CLIENT_CONNECT_INIT,
    self, self.onReceiveClientConnectInit)
  
  self.receiver:registerListener(MessageType.CLIENT_DISCONNECT,
    self, self.onReceiveClientDisconnect)
  
  self.receiver:registerListener(MessageType.PING,
    self, self.onReceivePing)
end

function Class:update()
  self.receiver:processIncomingMessages()
  
  local time = love.timer.getTime()
  for client in self:allClients() do
    local id = client.id
    
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

function Class:disconnectClient(id)
  local client = self:getClient(id)
  if client == nil then return end
  local clientString = self:createClientString(client.address, client.port)
  self.clients[id] = nil
  for k,v in ipairs(self.clientIds) do
    if v == id then
      table.remove(self.clientIds, k)
      self.clientIds.n = self.clientIds.n - 1
      break
    end
  end
  self.clientIds[clientString] = nil
  print("disconnected client "..id.." @ "..clientString)
end

function Class:onReceiveClientConnectInit(message, address, port)
  local client = self:getClient(address, port)
  if client == nil then
    client = {
      id = self.nextId,
      address = address,
      port = port,
      connectionStatus = ConnectionStatus.CONNECTED,
    }
    local clientString = self:createClientString(address, port)
    self.clients[client.id] = client
    self.clientIds.n = self.clientIds.n + 1
    self.clientIds[self.clientIds.n] = client.id
    self.clientIds[clientString] = client.id
    self.nextId = self.nextId + 1
    print("connected to new client "..clientString.." with id "..client.id)
  end
  
  client.lastReceivedTime = love.timer.getTime()
  self:sendMessage(messages.serverConnectAck(client.id), client.id)
end

function Class:onReceiveClientDisconnect(message, address, port)
  local client = self:getClient(address, port)
  client.lastReceivedTime = love.timer.getTime()
  self:disconnectClient(clientId)
end

function Class:onReceivePing(message, address, port)
  local client = self:getClient(address, port)
  client.lastReceivedTime = love.timer.getTime()
  print("received ping from "..client.id)
end

--
-- Gets the client object based on the parameters, which can be:
-- 1. clientId
-- 2. clientAddress, clientPort
-- 3. clientString
--
function Class:getClient(...)
  local args = {...}
  local id = nil
  
  if type(args[1]) == "string" then
    if type(args[2]) == "number" then
      id = self.clientIds[self:createClientString(args[1], args[2])]
    else
      id = self.clientIds[args[1]]
    end
  elseif type(args[1]) == "number" then
    id = args[1]
  end
  
  if id == nil then return nil end
  
  return self.clients[id]
end

function Class:allClients()
  local i = 0
  return function()
    i = i + 1
    if self.clientIds[i] then
      return self.clients[self.clientIds[i]]
    end
  end
end

function Class:allClientIds()
  local i = 0
  return function()
    i = i + 1
    return self.clientIds[i]
  end
end

function Class:createClientString(address, port)
  return string.format("%s:%s", address, port)
end

function Class:sendMessage(message, ...)
  local clientIds = {...}
  local clients = {n = 0}
  local time = love.timer.getTime()
  for _,clientId in ipairs(clientIds) do
    local client = self:getClient(clientId)
    if client ~= nil then
      clients.n = clients.n + 1
      clients[clients.n] = client
      client.lastSentTime = time
    end
  end
  self.clients.n = nil
  self.sender:sendMessage(message, unpack(clients))
end
