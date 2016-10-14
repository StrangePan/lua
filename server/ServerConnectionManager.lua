require "ConnectionManager"
require "ConnectionStatus"

--
-- Connection handler for servers; maintains connections to multiple clients.
-- Sends periodic pings to clients in order to keep the connection alive.
--
ServerConnectionManager = buildClass(ConnectionManager)
local Class = ServerConnectionManager

function Class:_init()
  Class.superclass._init(self, 25565)
  
  -- Initialize clients table
  self.clients = {}
  self.clientIds = {n = 0}
  self.nextId = 1
  
  -- Register for message callbacks.
  self.passer:registerListener(nil,
    self, self.onReceiveMessage)
  
  self.passer:registerListener(MessageType.CLIENT_CONNECT_INIT,
    self, self.onReceiveClientConnectInit)
  
  self.passer:registerListener(MessageType.CLIENT_DISCONNECT,
    self, self.onReceiveClientDisconnect)
  
  self.passer:registerListener(MessageType.PING,
    self, self.onReceivePing)
end

--
-- Periodicall called by framework. Processes incoming messages and sends pings to
-- clients whom we have not pinged in a while and updates connection information
-- for clients from whomw e have not heard in a while.
--
function Class:update()
  self.passer:receiveAllMessages()
  
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

--
-- Disconnects a client from the client's ID. Deletes tracked info and resets
-- internal state for that client. Performs any necessary cleanup.
--
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

--
-- Callback function for when MessagePasser receives any message at all.
-- Updates the last received message time for the sender if the sender is
-- a known client.
--
function Class:onReceiveMessage(message, address, port)
  local client = self:getClient(address, port)
  if client ~= nil then
    client.lastReceivedTime = love.timer.getTime()
  end
end

--
-- Callback function for messages of type CLIENT_CONNECT.
--
-- Initializes a connection with a client and sets up client data and
-- responds with acknowledgement.
--
function Class:onReceiveClientConnectInit(message, address, port)
  local client = self:getClient(address, port)
  if client == nil then
    client = {
      id = self.nextId,
      address = address,
      port = port,
      connectionStatus = ConnectionStatus.CONNECTED,
      hasMap = false
    }
    local clientString = self:createClientString(address, port)
    self.clients[client.id] = client
    self.clientIds.n = self.clientIds.n + 1
    self.clientIds[self.clientIds.n] = client.id
    self.clientIds[clientString] = client.id
    self.nextId = self.nextId + 1
    print("connected to new client "..clientString.." with id "..client.id)
  end
  
  -- Update ping time and send acknowledgement.
  client.lastReceivedTime = love.timer.getTime()
  self:sendMessage(messages.serverConnectAck(client.id), client.id)
end

--
-- Callback function for messages of type CLIENT_DISCONNECT.
--
-- Terminates connection to sender. Does not send acknowledgement.
--
function Class:onReceiveClientDisconnect(message, address, port)
  local client = self:getClient(address, port)
  self:disconnectClient(clientId)
end

--
-- Callback function for messages of type PING.
--
-- Updates ping time from sender to ensure connection is still alive.
--
function Class:onReceivePing(message, address, port)
  local client = self:getClient(address, port)
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

--
-- Iterator function for looping through all client objects
--
function Class:allClients()
  local i = 0
  return function()
    i = i + 1
    if self.clientIds[i] then
      return self.clients[self.clientIds[i]]
    end
  end
end

--
-- Iterator function for looping through the IDs of all clients
--
function Class:allClientIds()
  local i = 0
  return function()
    i = i + 1
    return self.clientIds[i]
  end
end

--
-- Creates an client identifying string based on the source IP and port
--
function Class:createClientString(address, port)
  return string.format("%s:%s", address, port)
end

--
-- Sends a message object to all connected clients.
--
function Class:broadcastMessage(message)
  return self:broadcastMessageWithAck(message, nil)
end

--
-- Sends a message object to all connected clients along with a request that
-- the clients acknowledge receipt of the message, blocking further messages
-- on the same channel until the clients confirm that they have received this
-- one.
function Class:broadcastMessageWithAck(message, channel)
  self:sendMessageWithAck(message, channel, unpack(self.clientIds))
end

--
-- Sends a message object to any number of clients. Optional parameters
-- may be a list of client IDs to send the message to.
--
function Class:sendMessage(message, ...)
  return self:sendMessageWithAck(message, nil, ...)
end

--
-- Sends a message object to any number of clients along with a request that
-- the clients acknowledge receipt of the message, blocking further messages
-- on the same channel until the clients confirm that they have received
-- this one.
--
function Class:sendMessageWithAck(message, channel, ...)
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
  clients.n = nil
  for _,client in ipairs(clients) do
    if channel then
      self.passer:sendMessageWithAck(message, channel, client.address, client.port)
    else
      self.passer:sendMessage(message, client.address, client.port)
    end
  end
end
