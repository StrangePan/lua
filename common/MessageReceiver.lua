require "common/class"
require "common/functions"
require "messages"
require "Serializer"

MessageReceiver = buildClass()

function MessageReceiver:_init(udp)
  self.udp = udp
  self.coordinators = {}
end

function MessageReceiver:processIncomingMessages()
  repeat
    data, err, addr, port = self.udp:receivefrom()
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

function MessageReceiver:processMessage(message, addr, port)
  
  -- short-circuit if we've already processed this message
  if self.processed[message] then return end
  self.processed[message] = true
  
  if message.type == MessageType.BUNDLE then
    for i,submessage in ipairs(message) do
      self:processMessage(message, addr, port)
    end
  else
    self:notifyListeners(message, addr, port)
  end
end

function MessageReceiver:notifyListeners(message, addr, port)
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
function MessageReceiver:registerListener(messageType, listener, callback)
  messageType = MessageType.fromId(messageType)
  assert(messageType ~= nil)
  assertType(callback, "callback", "function")
  if self.coordinators[messageType] == nil then
    self.coordinators[messageType] = EventCoordinator()
  end
  self.coordinators[messageType]:registerListener(listener, callback)
end
