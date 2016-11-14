require "common/class"
require "MessagePasser"
require "Connection"
require "ConnectionStatus"

local PRINT_DEBUG = true

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
  Class.superclass._init(self)
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
  self.coordinators = {}
  self.connectionStatusCoordinator = EventCoordinator()

  -- Register for message callbacks.
  self.passer:registerListener(nil, self, self.onReceiveMessage)
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
      if time < connection.initTime + 60 then
        if connection.didInit then
          self:sendConnectionInit(connection)
        else
          self:sendConnectionAck(connection)
        end
      else
        self:terminateConnection(connection, false)
        if PRINT_DEBUG then print("connection "..id.." timed out") end
      end
    elseif connection.status == ConnectionStatus.CONNECTED and
        time >= connection.lastReceivedTime + 5 then
      self:setConnectionStatus(connection, ConnectionStatus.STALLED)
      if PRINT_DEBUG then print("connection "..id.." stalled") end
    elseif connection.status == ConnectionStatus.STALLED and
        time >= connection.lastReceivedTime + 30 then
      self:terminateConnection(id, true)
      if PRINT_DEBUG then print("connection "..id.." timed out") end
    end
  end
end

--
-- Terminates all current connections and broadcasts connection termination
-- messages to all conected instances.
--
function Class:terminateAllConnections()
  local connections = {}
  for connection in self:allConnections() do
    table.insert(connections, connection)
  end
  for _,connection in ipairs(connections) do
    self:terminateConnection(connection, true)
  end
end

--
-- Initiates a new connection; sends connection request to the specified
-- address and port.
--
function Class:initiateConnection(address, port)
  local connection = self:createConnection(address, port)
  if not connection then return end
  connection.didInit = true
  self:sendConnectionInit(connection)
end

--
-- Creates new internal connection object to specified address and port.
-- Automatically assigns an ID.
--
function Class:createConnection(address, port)
  assertType(address, "address", "string")
  assertType(port, "port", "number")
  if self:getConnection(address, port) then return end
  
  local id = self.connectionIds.nxt
  self.connectionIds.nxt = self.connectionIds.nxt + 1
  
  local connection = Connection(id, address, port, love.timer.getTime())
  
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
  if not connection then return end
  if sendDisconnect then
    assertType(sendDisconnect, "boolean")
    self:sendMessage(messages.disconnect(), connection)
  end
  self:setConnectionStatus(connection, ConnectionStatus.DISCONNECTED)
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
  if PRINT_DEBUG then print("disconnected from "..id.." @ "..connectionString) end
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
  end
  
  if type(args[1]) == "string" then
    id = self.connectionIds[self:createConnectionString(args[1], args[2])]
  elseif type(args[1]) == "number" then
    id = args[1]
  end
  
  if not id then
    return nil
  end
  if self.connections[id] then
    return self.connections[id]
  else
    if PRINT_DEBUG then print("No connection with ID "..id) end
  end
end

--
-- Sets the status of the supplied status to the supplied status. Notifies
-- registered listeners if new status is different from old status.
--
function Class:setConnectionStatus(connection, status)
  assert(
      ConnectionStatus.fromId(status),
      status.." is not a valid ConnectionStatus")
  connection = self:getConnection(connection)
  if not connection then return end
  local oldStatus = connection.status or ConnectionStatus.DISCONNECTED
  connection.status = status
  
  -- Notify listeners
  if oldStatus ~= status then
    self:notifyConnectionStatusListeners(connection.id, oldStatus)
  end
end

--
-- Registers a callback function to receive callbacks when this manager
-- receives a message of the given type. Callbacks receive:
-- message: The message that was received.
-- connectionId: The ID of the connection that sent the message.
--
function Class:registerMessageListener(messageType, listener, callback)
  assert(MessageType.fromId(messageType), messageType.." is not a valid MessageType")
  if not self.coordinators[messageType] then
    self.coordinators[messageType] = EventCoordinator()
  end
  self.coordinators[messageType]:registerListener(listener, callback)
end

--
-- Notifies registered listeners of the given message's type of a received
-- message from connection with ID connectionId.
--
function Class:notifyMessageListeners(message, connectionId)
  if self.coordinators[message.t] then
    self.coordinators[message.t]:notifyListeners(message, connectionId)
  end
end

--
-- Callbacks receive:
-- connectionManager: the ConnectionManager that triggered the event.
-- connectionId: The ID of the connection whose status changed.
-- oldStatus: The previous status of the connection.
--
function Class:registerConnectionStatusListener(listener, callback)
  self.connectionStatusCoordinator:registerListener(listener, callback)
end

--
-- Notifies registered listeners of old connections that a connection's status
-- has changed.
--
function Class:notifyConnectionStatusListeners(connectionId, oldStatus)
  self.connectionStatusCoordinator:notifyListeners(self, connectionId, oldStatus)
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
  return self:sendMessage(message, unpack(self.connectionIds))
end

--
-- Sends a message object to all connections along with a request that
-- the recipients acknowledge receipt of the message, blocking further messages
-- on the same channel until the connections confirm that they have received
-- this one.
function Class:broadcastMessageWithAck(message, channel)
  self:sendMessageWithAck(message, channel, unpack(self.connectionIds))
end

--
-- Sends a message object to all connections along with a request that
-- the recipients acknowledge receipt of the message, blocking further messages
-- on the same channel until the connections confirm that they have received
-- this one. The broadcasted messages will also skip any other pending
-- acknowledgement requests and indicate that the receiver reset its internal
-- acknowledgement tracker to synchronize with this message.
--
function Class:broadcastMessageWithAckReset(message, channel)
  self:sendMessageWithAck(message, channel, unpack(self.connectionIds))
end

--
-- Sends a message object to any number of connections. Optional parameters
-- may be a list of connection IDs to send the message to.
--
function Class:sendMessage(message, ...)
  return self:sendMessageOfType("plain", message, nil, ...)
end

--
-- Sends a message object to any number of connections along with a request that
-- the recipients acknowledge receipt of the message, blocking further messages
-- on the same channel until the connections confirm that they have received
-- this one.
--
function Class:sendMessageWithAck(message, channel, ...)
  return self:sendMessageOfType("ack", message, channel, ...)
end

--
-- Sends a message object to any number of connections along with a request that
-- the recipients acknowledge receipt of the message, blocking further messages
-- on the same channel until the connections confirm that they have received
-- this one. This message will also skip any other pending acknowlegement
-- requests and indicate that the receiver reset its internal acknowledgement
-- tracker to synchronize with this message.
--
function Class:sendMessageWithAckReset(message, channel, ...)
  return self:sendMessageOfType("reset", message, channel, ...)
end

--
-- Internal function for sending messages. All message passing methods go
-- through here. mtype is a string with the following valid values:
-- "plain"
-- "ack"
-- "reset"
--
function Class:sendMessageOfType(mtype, message, channel, ...)
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
    if mtype == "plain" then
      self.passer:sendMessage(message, connection.address, connection.port)
    elseif mtype == "ack" then
      self.passer:sendMessageWithAck(message, channel, connection.address, connection.port)
    elseif mtype == "reset" then
      self.passer:sendMessageWithAckReset(message, channel, connection.address, connection.port)
    end
  end
end

--
-- Sends a connection init message to the supplied connection.
--
function Class:sendConnectionInit(connection)
  connection = self:getConnection(connection)
  if not connection then return end
  local id = connection.id

  if PRINT_DEBUG then print("attempting to connect to "..id.." @ "..connection.address..":"..connection.port) end
  self:setConnectionStatus(connection, ConnectionStatus.CONNECTING)
  self:sendMessage(messages.connectionInit(), id)
end

--
-- Sends a connection ack message to the supplied connection.
--
function Class:sendConnectionAck(connection)
  connection = self:getConnection(connection)
  if not connection then return end
  local id = connection.id

  if PRINT_DEBUG then print("attempting to connect to "..id.." @ "..connection.address..":"..connection.port) end
  self:setConnectionStatus(connection, ConnectionStatus.CONNECTING)
  self:sendMessage(messages.connectionAck(id), id)
end


--
-- Simple map mapping message types to internal handler functions.
--
local callbackMap = {
  [MessageType.PING] = "onReceivePing",
  [MessageType.CONNECT_INIT] = "onReceiveConnectionInit",
  [MessageType.CONNECT_ACK] = "onReceiveConnectionAck",
  [MessageType.CONNECT_ACK_ACK] = "onReceiveConnectionAckAck",
  [MessageType.DISCONNECT] = "onReceiveDisconnect",
}

--
-- Callback function for when MessagePasser receives any message at all.
-- Updates the last received message time for the sender if the sender is
-- a known connection.
--
function Class:onReceiveMessage(message, address, port)
  local connection = self:getConnection(address, port)
  if connection then
    connection.lastReceivedTime = love.timer.getTime()
    if connection.status == ConnectionStatus.STALLED then
      self:setConnectionStatus(connection, ConnectionStatus.CONNECTED)
    end
  end
  
  if callbackMap[message.t] then
    self[callbackMap[message.t]](self, message, address, port)
  end
  
  connection = self:getConnection(address, port)
  if connection then
    self:notifyMessageListeners(message, connection.id)
  end
end

--
-- Callback function for messages of type PING. Updates ping time from sender
-- to ensure connection is still alive.
--
function Class:onReceivePing(message, address, port)
  local connection = self:getConnection(address, port)
end

--
-- Callback function for messages of type CONNECT_INIT. Initializes a
-- connection with another instance and sets up connection data. Responds with
-- acknowledgement.
--
function Class:onReceiveConnectionInit(message, address, port)
  local connection = self:createConnection(address, port)
  local didCreate = connection ~= nil
  connection = connection or self:getConnection(address, port)
  if not connection then return end

  local id = connection.id
  if didCreate then
    connection.lastReceivedTime = love.timer.getTime()
  elseif connection.status ~= ConnectionStatus.CONNECTING then
    return
  end

  if PRINT_DEBUG then print("connection request received from "..id.." @ "..address..":"..port) end
  self:sendConnectionAck(connection)
end

--
-- Callback function for messages of type CONNECT_ACK. Confirms connection
-- to the remote instance.
--
function Class:onReceiveConnectionAck(message, address, port)
  local connection = self:getConnection(address, port)
  if not connection then return end
  local id = connection.id

  -- Ignore message if not looking to connect.
  if connection.status ~= ConnectionStatus.CONNECTING 
      and connection.status ~= ConnectionStatus.CONNECTED then
    return
  end

  if PRINT_DEBUG then print("connected to instance "..connection.id.." at "..connection.address..":"..connection.port) end
  self:sendMessage(messages.connectionAckAck(id), id)
  self:setConnectionStatus(connection, ConnectionStatus.CONNECTED)
end

--
-- Callback function for messages of type CONNECT_ACK_ACK. Confirms connection
-- to remote instance.
--
function Class:onReceiveConnectionAckAck(message, address, port)
  local connection = self:getConnection(address, port)
  if not connection then return end

  -- Ignore message if not looking to connect
  if connection.status ~= ConnectionStatus.CONNECTING then
    return
  end

  if PRINT_DEBUG then print("connected to instance "..connection.id.." at "..connection.address..":"..connection.port) end
  self:setConnectionStatus(connection, ConnectionStatus.CONNECTED)
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
