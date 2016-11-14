require "common/functions"
require "common/class"
require "EventCoordinator"
require "MessageType"
require "messages"
require "Queue"
require "Serializer"

local PRINT_MESSAGES = true

--
-- Class that handles the sending and receiving of messages of UDP and
-- includes mechanisms for registering for message receipt callbacks
-- and handling message acknowledgements.
--
MessagePasser = buildClass()
local Class = MessagePasser

local ANY_MESSAGE_TYPE = "any"
local ACKMSG_RESEND_DELAY = 5 -- seconds

function Class:_init(udp)
  self.udp = udp
  self.inbox = Queue() -- raw inbox for received messages, ordered as received
  self.outbox = {} -- raw outbox for outgoing messages grouped by destination
  self.outboxDestinations = {}
  self.outboxDeleted = {}
  self.coordinators = {} -- event coordinators for incoming messages
  self.outgoingAckQueues = {} -- table of outgoing messages with ack requests
  self.outgoingAckDestinations = {}
  self.incomingAckQueues = {} -- table for tracking incoming messages with acks
  self.incomingAckSources = {}
end

--
-- Builds a message channel identification string.
--
local function buildAckKey(address, port, channel)
  return string.format("%s:%s:%s", address, port, channel)
end

--
-- Sends message object to the specified IP address and port number.
--
function Class:sendMessage(message, address, port)
  assertType(message, "message", "table")
  assertType(address, "address", "string")
  assertType(port, "port", "number")
  local outString = string.format("%s:%s", address, port)
  if not self.outbox[outString] then
    self.outbox[outString] = {
      queue = Queue(),
      address = address,
      port = port,
    }
  end
  self.outbox[outString].queue:push(message)
  self.outboxDestinations[outString] = true
  
  -- Debug
  if PRINT_MESSAGES then
    print("enqueued message to "..address..":"..port,
        Serializer.serialize(message))
  end
end

--
-- Sends message object to the specified IP address and port number, along
-- with a request that the receiver send back an acknowledgement of receipt,
-- blocking any other outgoing messages on the provided channel until the
-- client sends acknowledgement.
--
function Class:sendMessageWithAck(message, channel, address, port)
  assertType(message, "message", "table")
  assertType(channel, "channel", "string")
  assertType(address, "address", "string")
  assertType(port, "port", "number")
  return self:_sendMessageWithAck(
    MessageType.ACK_REQUEST, message, channel, address, port)
end

--
-- Sends message object to the specified IP address and port number, along
-- with a request that the receiver send back an acknowledgement of receipt,
-- blocking any other outgoing messages on the provided channel until the
-- client sends acknowledgement.
--
function Class:sendMessageWithAckReset(message, channel, address, port)
  assertType(message, "message", "table")
  assertType(channel, "channel", "string")
  assertType(address, "address", "string")
  assertType(port, "port", "number")
  return self:_sendMessageWithAck(
    MessageType.ACK_REQUEST_RESET, message, channel, address, port)
end

--
-- Internal method for adding an ack request or ack request with reset message
-- to the appropriate queue. First parameter can be either
-- MessageType.ACK_REQUEST or MessageType.ACK_REQUEST_RESET
--
function Class:_sendMessageWithAck(messageType, message, channel, address, port)
  assert(messageType == MessageType.ACK_REQUEST
      or messageType == MessageType.ACK_REQUEST_RESET,
      "Unsupported message type "..messageType)

  local ackKey = buildAckKey(address, port, channel)
  local outgoingAckQueue = self.outgoingAckQueues[ackKey]

  -- Create outgoing ackqueue if not already created
  local destKey = string.format("%s:%s", address, port)
  if not outgoingAckQueue then
    outgoingAckQueue = {
      channel = channel, -- ack channel string
      ackNum = 0,        -- acknowledgement number
      queue = Queue(),   -- message queue
      address = address, -- destination address
      port = port,       -- destination port
    }
    self.outgoingAckQueues[ackKey] = outgoingAckQueue

    -- Track ack queue by destination so we can delete it when necessary.
    if not self.outgoingAckDestinations[destKey] then
      self.outgoingAckDestinations[destKey] = {
        all = {},
        pending = {},
      }
    end
    self.outgoingAckDestinations[destKey].all[ackKey] = true
  end

  -- Mark outgoing ack queue as having messages pending
  self.outgoingAckDestinations[destKey].pending[ackKey] = true

  -- Update ack number
  local ackNum = outgoingAckQueue.ackNum + 1
  outgoingAckQueue.ackNum = ackNum

  -- Construct message to be sent
  local messageWithAck
  if messageType == MessageType.ACK_REQUEST then
    messageWithAck = messages.ackRequest(channel, ackNum, message)
  elseif messageType == MessageType.ACK_REQUEST_RESET then
    outgoingAckQueue.queue:clear()
    messageWithAck = messages.ackRequestReset(channel, ackNum, message)
  end

  -- Bundle ougoing message into a bundle containing metadata
  local outgoingBundle = {
    message = messageWithAck,
    sendTime = love.timer.getTime(),
    n = ackNum,
  }

  -- Enqueue message and send
  outgoingAckQueue.queue:push(outgoingBundle)
  self:sendMessage(messageWithAck, address, port)
end

--
-- Sends multiple messages in a bundle that have been queued up by various
-- calls to the `sendMessage` functions.
--
function Class:releaseMessageBundle()
  local t = love.timer.getTime()

  -- Send acknowledgements for incoming ack requests
  for srcKey,srcTbl in pairs(self.incomingAckSources) do
    for ackKey in pairs(srcTbl.pending) do
      self:sendMessage(messages.ack(
          self.incomingAckQueues[ackKey].channel,
          self.incomingAckQueues[ackKey].ackNum),
          self.incomingAckQueues[ackKey].address,
          self.incomingAckQueues[ackKey].port)
      srcTbl[ackKey] = nil
    end
  end

  -- Resend messages in outgoing ack queue
  for destKey,destTbl in pairs(self.outgoingAckDestinations) do
    for ackKey in pairs(destTbl.pending) do
      local q = self.outgoingAckQueues[ackKey]
      for i,bundle in q.queue:items() do

        -- Only resend messages that are ACKMSG_RESEND_DELAY stale and no more
        -- than 5 per channel
        if bundle.sendTime + ACKMSG_RESEND_DELAY < t and i < 5 then
          if PRINT_MESSAGES then print("resending message "..bundle.ackNum.." on channel "..q.channel) end
          self:sendMessage(bundle.message, q.address, q.port)
          bundle.sendTime = t
        else
          break
        end
      end
      if q.queue:empty() then
        destTbl.pending[ackKey] = nil
      end
    end
  end

  -- Send all message in the outbox
  for destKey in pairs(self.outboxDestinations) do
    local outbox = self.outbox[destKey]
    local outgoing = {}

    while not outbox.queue:empty() do
      table.insert(outgoing, outbox.queue:pop())
    end

    if outgoing[1] then
      local data = Serializer.serialize(messages.bundle(unpack(outgoing)))
      if PRINT_MESSAGES then
        print("sending bundle", outbox.address..":"..outbox.port, "("..string.len(data)..")")
        print(data)
      end
      self.udp:sendto(data, outbox.address, outbox.port)
    end

    if outbox.queue:empty() then
      self.outboxDestinations[destKey] = nil
    end
  end

  for destKey in pairs(self.outboxDeleted) do
    self.outboxDestinations[destKey] = nil
    self.outbox[destKey] = nil
  end
end

--
-- Processes all incoming messages and notifies registered listeners as
-- appropriate.
--
function Class:receiveAllMessages()

  -- Receive messages from UDP
  repeat
    data, addr, port = self.udp:receivefrom()
    if data then
      message = Serializer.deserialize(data)
      if message then
        if PRINT_MESSAGES then print("received", data) end
        self.inbox:push({
          message = message,
          address = addr,
          port = port
        })
      else
        if PRINT_MESSAGES then print("unable to parse message: ", data) end
      end
    end
  until not data

  -- Process enqueued messages
  while not self.inbox:empty() do
    m = self.inbox:pop()
    local message = m.message
    local addr = m.address
    local port = m.port

    self.processed = {} -- temp table to prevent recursion
    self:processMessage(message, addr, port)
  end
end

--
-- Internally processes receipt of a message. Automatically handles bundled
-- messages, recursive messages, received acknowledgements, acknowledgement
-- requests, and acknowledgement resets.
--
function Class:processMessage(message, addr, port)
  
  -- short-circuit if we've already processed this message
  if self.processed[message] then return end
  self.processed[message] = true
  local notifyListeners = true
  
  if message.type == MessageType.BUNDLE then
    -- Split apart bundles and process each contained message
    for i,submessage in ipairs(message) do
      self:processMessage(submessage, addr, port)
    end
    
  elseif message.type == MessageType.ACK then
    -- Process an acknowledgement message
    local channel = message.c
    local ackNum = message.n
    local ackKey = buildAckKey(addr, port, channel)
    local destKey = string.format("%s:%s", addr, port)
    local outgoingAck = self.outgoingAckQueues[ackKey]

    -- Pop messages with acknowledgement number less than or equal to that was
    -- received.
    notifyListeners = false
    if outgoingAck then
      while not outgoingAck.queue:empty()
          and outgoingAck.queue:peek().n <= ackNum do
        outgoingAck.queue:pop()
        notifyListeners = true
      end
      if outgoingAck.queue:empty() then
        self.outgoingAckDestinations[destKey].pending[ackKey] = nil
      end
    end
    
  elseif message.type == MessageType.ACK_REQUEST
      or message.type == MessageType.ACK_REQUEST_RESET then

    -- Unwrap acknowledgement requests and process contained message
    local channel = message.c
    local ackNum = message.n
    local innerMessage = message.m
    local ackKey = buildAckKey(addr, port, channel)
    local srcKey = string.format("%s:%s", addr, port)
    local incomingAck = self.incomingAckQueues[ackKey]

    -- Create new channel if necessary. Only create channels if ackNum is 1
    -- so that we avoid recreating ack queues when they've been recently
    -- deleted.
    if not incomingAck and ackNum == 1 then
      incomingAck = {
        channel = channel,
        ackNum = 0,
        address = addr,
        port = port,
      }
      self.incomingAckQueues[ackKey] = incomingAck

      -- Create table for tracking ack channels by source
      if not self.incomingAckSources[srcKey] then
        self.incomingAckSources[srcKey] = {
          all = {},     -- all incoming ack queues from src
          pending = {}, -- incoming ack channels to be ack'ed
        }
      end

      self.incomingAckSources[srcKey].all[ackKey] = true
    end

    -- Process inner message
    if incomingAck
        and ((message.type == MessageType.ACK_REQUEST
                and ackNum == incomingAck.ackNum + 1)
            or (message.type == MessageType.ACK_REQUEST_RESET
                and ackNum > incomingAck.ackNum)) then
        incomingAck.ackNum = ackNum
        self:processMessage(innerMessage, addr, port)
    else
      notifyListeners = false
    end

    -- Mark channel to be acknowledged in future
    if incomingAck then
      self.incomingAckSources[srcKey].pending[ackKey] = true
    end
  end
  
  -- Notify listeners of message received unless otherwise specified not to
  if notifyListeners then
    self:notifyListeners(message, addr, port)
  end
end

--
-- Deletes all ack queues associated with the given address and port. Note:
-- this causes any incoming ack-request messages with on the deleted channels
-- to be discarded; use this only when it's time to erase all records of
-- communication with the given address and port.
--
function Class:freeResources(address, port)
  local destKey = string.format("%s:%s", address, port)
  for ackKey in pairs(self.outgoingAckDestinations[destKey].all) do
    self.outgoingAckQueues[ackKey] = nil
  end
  self.outgoingAckDestinations[destKey] = nil
  for ackKey in pairs(self.incomingAckSources[destKey].all) do
    self.incomingAckQueues[ackKey] = nil
  end
  self.incomingAckSources[destKey] = nil
  self.outboxDeleted[destKey] = true -- mark outbox contents for deletion
end

--
-- Notifies registered listeners of the provided message's type of receipt
-- of message, providing sender address and port.
--
function Class:notifyListeners(message, addr, port)
  if type(message) ~= "table" then return end
  local t = message.type
  
  -- Notify listeners registerd with message type-agnostic event coordinator.
  if self.coordinators[ANY_MESSAGE_TYPE] ~= nil then
    self.coordinators[ANY_MESSAGE_TYPE]:notifyListeners(message, addr, port)
  end
  
  -- Notify listeners registerd with message type-specific event coordinators.
  if t ~= nil and self.coordinators[t] ~= nil then
    self.coordinators[t]:notifyListeners(message, addr, port)
  end
end

--
-- Registers a listener to receive callbacks when a message is received.
-- The callback will only be called when receiving messages of the specified
-- MessageType.
--
-- If first parameter is nil, then listener will receive callbacks for ALL
-- message types!
--
-- Callback function will receive
-- 1. message object
-- 2. sender IP address
-- 3. sender port
--
function Class:registerListener(messageType, listener, callback)
  -- Validate parameters.
  if messageType == nil then
    messageType = ANY_MESSAGE_TYPE
  else
    messageType = MessageType.fromId(messageType)
    assert(messageType ~= nil)
  end
  assertType(callback, "callback", "function")
  
  -- Lazily instantiate event coordinators.
  if not self.coordinators[messageType] then
    self.coordinators[messageType] = EventCoordinator()
  end
  
  -- Register for callbacks.
  self.coordinators[messageType]:registerListener(listener, callback)
end
