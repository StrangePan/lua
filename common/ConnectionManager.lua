require "common/class"
require "MessagePasser"
require "Connection"
require "ConnectionStatus"

--
-- Object that manages and maintains connections to other program instances,
-- initiating connections, sendings periodic pings, and provides mechanisms
-- for sending message objects to other connected instances.
--
ConnectionManager = buildClass()
local Class = ConnectionManager

--
-- Constructor for a connection manager. Requries a port to which to bind.
--
function Class:_init(port)
  self.port = port

  -- Initialize udp connection object.
  self.socket = require "socket"
  self.udp = socket:udp()
  self.udp:settimeout(0)
  local res,err = self.udp:setsockname('*', port)
  if res == nil then
    print(err)
    return
  end

  -- Initialize sender/receiver objects.
  self.passer = MessagePasser(self.udp)

  -- Initialize mechanisms for tracking connections.
  self.connections = {}
  self.connectionIds = {n = 0, nxt=1}
  self.pendingConnections = {}

  -- Register for message callbacks.
  self.passer:registerListener(nil,
    self, self.onReceiveMessage)

  self.passer:registerListener(MessageType.PING,
    self, self.onReceivePing)

  self.passer:registerListener(MessageType.CONNECT_INIT,
    self, self.onReceiveConnectionInit)

  self.passer:registerListener(MessageType.CONNECT_ACK,
    self, self.onReceiveConnectionAck)

  self.passer:registerListener(MessageType.DISCONNECT,
    self, self.onReceiveDisconnect)
end

--
-- Processes incoming messages and sends pings to connections whom we have not
-- pinged in a while and updates connection information for connections from
-- whom we have not heard in a while.
--
-- Should be called multiple times a second for more responsive results.
--
function Class:receiveAllMessages()
  self.passer:receiveAllMessages()

  local time = love.timer.getTime()
  for connection in self:allConnections() do
    local id = connection.id

    -- Periodically ping connection to ensure connection stays alive.
    if (connection.status == ConnectionStatus.CONNECTED or
        connection.status == ConnectionStatus.STALLED) and
        time >= connection.lastSentTime + 2 then
      self:sendMessage(messages.ping(), id)
    end

    -- handle timeouts
    if connection.status == ConnectionStatus.CONNECTING and
        time >= connection.lastSentTime + 3 then
      self:sendConnectionInit(connection)
    elseif connection.status == ConnectionStatus.CONNECTED and
        time >= connection.lastReceivedTime + 5 then
      connection.status = ConnectionStatus.STALLED
      print("connection "..id.." stalled")
    elseif connection.status == ConnectionStatus.STALLED and
        time >= connection.lastReceivedTime + 30 then
      self:terminateConnection(id, true)
      print("connection timed out")
    end
  end
end

--
-- Terminates all current connections and broadcasts connection termination
-- messages to all conected instances.
--
function Class:terminateAllConnections()
  for connection in self:allConnections() do
    self:terminateConnection(connection, true)
  end
end

--
-- Initiates a new connection; sends connection request to the specified
-- address and port.
--
function Class:initiateConnection(address, port)
  local connection = self:createConnection(address, port)
  if connection == nil then return end
  --connection.status = ConnectionStatus.CONNECTING
  self:sendConnectionInit(connection)
end

--
-- Creates new internal connection object to specified address and port.
-- Automatically assigns an ID.
--
function Class:createConnection(address, port)
  assertType(address, "address", "string")
  assertType(port, "port", "number")
  print('createConnection', address, port)
  if self:getConnection(address, port) then return end
  
  local id = self.connectionIds.nxt
  self.connectionIds.nxt = self.connectionIds.nxt + 1
  
  local connection = Connection(id, address, port)
  
  local connectionString = self:createConnectionString(address, port)
  self.connections[id] = connection
  self.connectionIds.n = self.connectionIds.n + 1
  self.connectionIds[self.connectionIds.n] = id
  self.connectionIds[connectionString] = id
  
  return connection
end

--
-- Destroys connection with supplied connectionId. Optionally sends the
-- notifies connection about the disconnect with a message.
--
function Class:terminateConnection(connection, sendDisconnect)
  local connection = self:getConnection(connection)
  if connection == nil then return end
  if sendDisconnect then
    assertType(sendDisconnect, "boolean")
    self:sendMessage(messages.disconnect(), connection)
  end
  return self:deleteConnection(connection)
end

--
-- Disconnects a connection from the connection's ID. Deletes tracked info and resets
-- internal state for that connection. Performs any necessary cleanup.
--
function Class:deleteConnection(connection)
  local connection = self:getConnection(connection)
  if connection == nil then return end
  local id = connection.id
  local connectionString = self:createConnectionString(connection.address, connection.port)
  self.connections[id]= nil
  for k,v in ipairs(self.connectionIds) do
    if v == id then
      table.remove(self.connectionIds, k)
      self.connectionIds.n = self.connectionIds.n - 1
      break
    end
  end
  self.connectionIds[connectionString] = nil
  print("disconnected from "..id.." @ "..connectionString)
end

--
-- Gets the connection object based on the parameters, which can be:
-- 1. connectionId
-- 2. IP address, port
--
function Class:getConnection(...)
  local args = {...}
  local id = nil
  
  
  if instanceOf(args[1], Connection) then
    return args[1]
  else
  end
  
  
  if type(args[1]) == "string" then
    id = self.connectionIds[self:createConnectionString(args[1], args[2])]
  elseif type(args[1]) == "number" then
    id = args[1]
  end
  
  if id == nil then
    return nil
  end
  return self.connections[id]
end

--
-- Iterator function for looping through all connection objects.
--
function Class:allConnections()
  local i = 0
  return function()
    i = i + 1
    if self.connectionIds[i] then
      return self.connections[self.connectionIds[i]]
    end
  end
end

--
-- Iterator function for looping through the IDs of all connections.
--
function Class:allConnectionIds()
  local i = 0
  return function()
    i = i + 1
    return self.connectionIds[i]
  end
end

--
-- Creates an connection identifying string based on the source IP and port
--
function Class:createConnectionString(address, port)
  return string.format("%s:%s", address, port)
end

--
-- Sends a message object to all connections.
--
function Class:broadcastMessage(message)
  return self:broadcastMessageWithAck(message, nil)
end

--
-- Sends a message object to all connections along with a request that
-- the recipients acknowledge receipt of the message, blocking further messages
-- on the same channel until the connections confirm that they have received this
-- one.
function Class:broadcastMessageWithAck(message, channel)
  self:sendMessageWithAck(message, channel, unpack(self.connectionIds))
end

--
-- Sends a message object to any number of connections. Optional parameters
-- may be a list of connection IDs to send the message to.
--
function Class:sendMessage(message, ...)
  return self:sendMessageWithAck(message, nil, ...)
end

--
-- Sends a message object to any number of connections along with a request that
-- the recipients acknowledge receipt of the message, blocking further messages
-- on the same channel until the connections confirm that they have received
-- this one.
--
function Class:sendMessageWithAck(message, channel, ...)
  local connections = {...}
  local time = love.timer.getTime()
  
  -- Convert submitted arguments to connection objects
  for i,connection in ipairs(connections) do
    connection = self:getConnection(connection)
    if connection then
      connections[i] = connection
      connection.lastSentTime = time
    end
  end

  -- Send messages to connections
  for _,connection in ipairs(connections) do
    if channel then
      self.passer:sendMessageWithAck(message, channel, connection.address, connection.port)
    else
      self.passer:sendMessage(message, connection.address, connection.port)
    end
  end
end

function Class:sendConnectionInit(connection)
  connection = self:getConnection(connection)
  if connection == nil then return end
  
  local id = connection.id
  print("attempting to connect to "..id.." @ "..connection.address..":"..connection.port)
  connection.status = ConnectionStatus.CONNECTING
  self:sendMessage(messages.connectionInit(), id)
end

--
-- Callback function for when MessagePasser receives any message at all.
-- Updates the last received message time for the sender if the sender is
-- a known connection.
--
function Class:onReceiveMessage(message, address, port)
  print("Received message from "..address..":"..port)
  local connection = self:getConnection(address, port)
  if connection then
    connection.lastReceivedTime = love.timer.getTime()
    if connection.status == ConnectionStatus.STALLED then
      connection.status = ConnectionStatus.CONNECTED
    end
  end
end

--
-- Callback function for messages of type PING. Updates ping time from sender
-- to ensure connection is still alive.
--
function Class:onReceivePing(message, address, port)
  local connection = self:getConnection(address, port)
  print("received ping from "..connection.id)
end

--
-- Callback function for messages of type CONNECT_INIT. Initializes a
-- connection with another instance and sets up connection data. Responds with
-- acknowledgement.
--
function Class:onReceiveConnectionInit(message, address, port)
  local connection = self:createConnection(address, port)
  if connection == nil then return end
  
  local id = connection.id
  print("connection request "..id.." received from "..address..":"..port)
  connection.status = ConnectionStatus.CONNECTED
  connection.lastReceivedTime = love.timer.getTime()
  self:sendMessage(messages.connectionAck(), id)
end

--
-- Callback function for messages of type CONNECT_ACK. Confirms connection
-- to the remote instance.
--
function Class:onReceiveConnectionAck(message, address, port)
  local connection = self:getConnection(address, port)
  if connection == nil then return end
  
  -- Ignore message if not looking to connect.
  if connection.status ~= ConnectionStatus.CONNECTING then return end
  
  print("connected to instance "..connection.id.." at "..connection.address..":"..connection.port)
  connection.status = ConnectionStatus.CONNECTED
end

--
-- Callback function for messages of type CLIENT_DISCONNECT.
--
-- Terminates connection to sender. Does not send acknowledgement.
--
function Class:onReceiveDisconnect(message, address, port)
  local connection = self:getConnection(address, port)
  self:terminateConnection(connection, true)
end
