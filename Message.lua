require "Serializer"

local socket = require "socket"
local address,port = "127.0.0.1",25565
local udp = socket.udp()

Message = buildClass()

function Message:_init()
end

function Message:send()
  udp:sendto(self:serialize(), address, port)
end

function Message:serialize()
  return Serializer.serialize(self)
end

function Message.deserialize(data)
  return Serializer.deserialize(data)
end
