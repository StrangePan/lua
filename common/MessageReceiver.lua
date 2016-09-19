require "common/class"
require "common/functions"
require "messages"
require "Queue"

MessageReceiver = buildClass()

function MessageReceiver:_init(address, port)
  self.socket = require "socket"
  self.udp = self.socket:udp()
  
  if address and port then
    self.udp:setpeername(address, port)
  end
  
  self.udp:settimeout(0)
  
  self.coordinators = {}
end

function MessageReceiver:processIncomingMessages()
  repeat
    data, err = self.udp:receive()
    if data then
      message = Serializer.deserialize(data)
      if message ~= nil then
        self:notifyListeners(message)
      end
    end
  until data == nil
end

function MessageReceiver:notifyListeners(message)
  local t = message.type
  
  -- if message has no type, then no listeners to notify
  if t == nil then return end
  
  -- if eventcoordinator does not exist, then no listeners to notify
  if self.coordinators[t] == nil then return end
  
  self.coordinators[t]:notifyListeners(message)
end

function MessageReceiver:registerListener(messageType, listener, callback)
  messageType = MessageType.fromId(messageType)
  assert(messageType ~= nil)
  assertType(callback, "callback", "function")
  if self.coordinators[messageType] == nil then
    self.coordinators[messageType] = EventCoordinator()
  end
  self.coordinators[messageType]:registerListener(listener, callback)
end
