require "common/class"
require "Queue"

MessagePasser = buildClass()
local Class = MessagePasser

function Class:_init(udp)
  self.udp = udp
  self.inbox = {}
  self.outbox = {}
  self.coordinators = {}
end

local function buildAckKey(address, port, channel)
  return string.format("%s:%s:%s", address, port, channel)
end

function Class:sendMessage(message, address, port)
  local data = Serializer.serialize(message)
  self.udp:sendto(data, address, port)
end

function Class:sendMessageWithAck(message, channel, address, port)
  local ackKey = buildAckKey(address, port, channel)
  local outbox = self.outbox[ackKey]
  if outbox == nil then
    outbox = {ackNum = 0, queue = Queue()}
    self.outbox[ackKey] = outbox
  end
  outbox.ackNum = outbox.ackNum + 1
  local messageWithAck = messages.ackRequest(channel, outbox.ackNum, message)
  outbox.queue:push(messageWithAck)
  self:sendMessage(messageWithAck, address, port)
end

function Class:receiveAllMessages()
  repeat
    data, addr, port = self.udp:receivefrom()
    if data then
      message = Serializer.deserialize(data)
      if message ~= nil then
        self.processed = {}
        self:processMessage(message, addr, port)
      else
        print("unable to parse message: ", data)
      end
    end
  until data == nil
end

function Class:processMessage(message, addr, port)
  
  -- short-circuit if we've already processed this message
  if self.processed[message] then return end
  self.processed[message] = true
  local notifyListeners = true
  
  if message.type == MessageType.BUNDLE then
    -- Split apart bundles and process each contained message
    for i,submessage in ipairs(message) do
      self:processMessage(message, addr, port)
    end
    
  elseif message.type == MessageType.ACK then
    -- Process an acknowledgement message sent by client
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
      self:processMessage(message, addr, port)
    else
      notifyListeners = false
    end
    
    -- Reply with acknowledgement
    self:sendMessage(messages.ack(channel, inbox.ackNum), addr, port)
    
  elseif message.type == MessageType.ACK_RESET then
    -- Reset acknowledgements for given inbox channel
    local channel = message.c
    local ackNum = message.n
    local ackKey = buildAckKey(addr, port, channel)
    local inbox = self.inbox[ackKey]
    if inbox == nil then
      inbox = {ackNum = 0}
      self.inbox[ackKey] = inbox
    end
    inbox.ackNum = ackNum
    
    -- Reply with acknowledgement
    self:sendMessage(messages.ack(channel, inbox.ackNum), addr, port)
    
  end
  
  -- Notify listeners of message received unless otherwise specified not to
  if notifyListeners then
    self:notifyListeners(message, addr, port)
  end
end

function Class:notifyListeners(message, addr, port)
  if type(message) ~= "table" then return end
  local t = message.type
  
  -- if message has no type, then no listeners to notify
  if t == nil then return end
  
  -- if eventcoordinator does not exist, then no listeners to notify
  if self.coordinators[t] == nil then return end
  
  self.coordinators[t]:notifyListeners(message, addr, port)
end

--
-- Callback function will receive
-- 1. message object
-- 2. sender IP address
-- 3. sender port
--
function Class:registerListener(messageType, listener, callback)
  messageType = MessageType.fromId(messageType)
  assert(messageType ~= nil)
  assertType(callback, "callback", "function")
  if self.coordinators[messageType] == nil then
    self.coordinators[messageType] = EventCoordinator()
  end
  self.coordinators[messageType]:registerListener(listener, callback)
end
