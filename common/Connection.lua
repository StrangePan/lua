require "common/class"
require "MessagePasser"

Connection = buildClass()
local Class = Connection

function Class:_init(port)
  self.port = port
  
  -- Initialize udp connection object
  self.socket = require "socket"
  self.udp = socket:udp()
  self.udp:settimeout(0)
  local res,err = self.udp:setsockname('*', port)
  if res == nil then
    print(err)
    return
  end

  -- Initialize sender/receiver objects
  self.passer = MessagePasser(self.udp)
end
