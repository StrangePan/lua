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

function Class:_init(udp)
  self.udp = udp
  self.inbox = {}
  self.outbox = {}
  self.coordinators = {}
  self.outgoingMessages = {}
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
  if not self.outgoingMessages[outString] then
    self.outgoingMessages[outString] = Queue()
  end
  self.outgoingMessages[outString]:push(
      {message=message, address=address, port=port})
  if PRINT_MESSAGES then print("enqueued", Serializer.serialize(message)) end
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
  local ackKey = buildAckKey(address, port, channel)
  local outbox = self.outbox[ackKey]
  if not outbox then
    outbox = {ackNum = 0, queue = Queue()}
    self.outbox[ackKey] = outbox
  end
  outbox.ackNum = outbox.ackNum + 1
  local messageWithAck = messages.ackRequest(channel, outbox.ackNum, message)
  outbox.queue:push(messageWithAck)
  self:sendMessage(messageWithAck, address, port)
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
  local ackKey = buildAckKey(address, port, channel)
  local outbox = self.outbox[ackKey]
  if not outbox then
    outbox = {ackNum = 0, queue = Queue()}
    self.outbox[ackKey] = outbox
  end
  outbox.ackNum = outbox.ackNum + 1
  outbox.queue:clear()
  local messageWithAck = messages.ackRequestReset(
    channel, outbox.ackNum, message)
  outbox.queue:push(messageWithAck)
  self:sendMessage(messageWithAck, address, port)
end

--
-- Processes all incoming messages and notifies registered listeners as
-- appropriate.
--
function Class:receiveAllMessages()
  repeat
    data, addr, port = self.udp:receivefrom()
    if data then
      message = Serializer.deserialize(data)
      if message ~= nil then
        if PRINT_MESSAGES then print("received", data) end
        self.processed = {}
        self:processMessage(message, addr, port)
      else
        print("unable to parse message: ", data)
      end
    end
  until data == nil
end

--
-- Sends multiple messages in a bundle that have been queued up by various
-- calls to the `sendMessage` functions.
--
function Class:releaseMessageBundle()
  for _,outgoingMessages in pairs(self.outgoingMessages) do
    local address
    local port
    local outgoing = {}
    local i = 1
    while not outgoingMessages:empty() do
      local message = outgoingMessages:pop()
      address = message.address
      port = message.port
      outgoing[i] = message.message
      i = i + 1
    end
    if outgoing[1] then
      local data = Serializer.serialize(messages.bundle(unpack(outgoing)))
      print("sending bundle", address..":"..port, "("..string.len(data)..")")
      print(data)
      self.udp:sendto(data, address, port)
    end
  end
  self.outgoingMessages = {}
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
    local outbox = self.outbox[ackKey]
    if outbox ~= nil then
      while outbox.ackNum < ackNum do
        outbox.queue:pop()
        outbox.ackNum = outbox.ackNum + 1
      end
    end
    
  elseif message.type == MessageType.ACK_REQUEST then
    -- Unwrap acknowledgement requests and process contained message
    local channel = message.c
    local ackNum = message.n
    local innerMessage = message.m
    local ackKey = buildAckKey(addr, port, channel)
    local inbox = self.inbox[ackKey]
    if inbox == nil then
      inbox = {ackNum = 0}
      self.inbox[ackKey] = inbox
    end

    if ackNum == inbox.ackNum + 1 then
      inbox.ackNum = ackNum
      self:processMessage(innerMessage, addr, port)
    else
      notifyListeners = false
    end
    
    -- Reply with acknowledgement
    self:sendMessage(messages.ack(channel, inbox.ackNum), addr, port)
    
  elseif message.type == MessageType.ACK_REQUEST_RESET then
    -- Unwrap acknowledgements requests and process contained message
    -- while resetting acknowledgements for given inbox channel
    local channel = message.c
    local ackNum = message.n
    local innerMessage = message.m
    local ackKey = buildAckKey(addr, port, channel)
    local inbox = self.inbox[ackKey]
    if inbox == nil then
      inbox = {ackNum = 0}
      self.inbox[ackKey] = inbox
    end
    
    if ackNum > inbox.ackNum then
      inbox.ackNum = ackNum
      self:processMessage(innerMessage, addr, port)
    else
      notifyListeners = false
    end
    
    -- Reply with acknowledgement
    self:sendMessage(messages.ack(channel, inbox.ackNum), addr, port)
  end
  
  -- Notify listeners of message received unless otherwise specified not to
  if notifyListeners then
    self:notifyListeners(message, addr, port)
  end
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
