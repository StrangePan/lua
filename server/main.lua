package.path = package.path .. ";./common/?.lua"

require "Serializer"

local socket = require "socket"

player = {
  x = 0,
  y = 0
}

function love.load()
  udp = socket.udp()
  udp:settimeout(0)
  udp:setsockname('*', 25565)
end

function love.update(dt)
  data, msg = udp:receive()
  if data then
    print("MESSAGEOMGOMGOMG")
    local message = Serializer.deserialize(data)
    
    player.x = message.to.x
    player.y = message.to.y
  end
end