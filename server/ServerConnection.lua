require "common/class"
require "MessageReceiver"
require "MessageSender"

ServerConnection = buildClass()

function ServerConnection:_init()
  
  -- Initialize udp connection object
  self.socket = require "socket"
  self.udp = socket:udp()
  self.udp:settimeout(0)
  local res,err = self.udp:setsockname('*', 25565)
  if res == nil then
    print(err)
    return
  end
  
  -- Initialize clients table
  self.clients = {n = 0}
  
  -- Initialize sender/receiver objects
  self.sender = MessageSender(self.udp)
  self.receiver = MessageReceiver(self.udp)
  
  -- Register for message callbacks
  self.receiver:registerListener(MessageType.CLIENT_CONNECT_INIT,
    self, self.onReceiveClientConnectInit)
  
end

function ServerConnection:update()
  self.receiver:processIncomingMessages()
end

function ServerConnection:onReceiveClientConnectInit(message, address, port)
  local clientId = self:getClientId(address, port)
  if clientId == nil then
    self.clients.n = self.clients.n + 1
    clientId = self.clients.n
    self.clients[clientId] = {address = address, port = port}
    local clientString = self:createClientString(address, port)
    self.clients[clientString] = clientId
    print("connected to new client "..clientString.." with id "..clientId)
  end
  local client = self.clients[clientId]
  
  self.sender:sendMessage(messages.serverConnectAck(clientId),client)
end

--
-- Returns the ID of a client based on address and port
--
function ServerConnection:getClientId(address, port)
  local clientString = self:createClientString(address, port)
  if self.clients[clientString] then
    return self.clients[clientString]
  end
  return nil
end

function ServerConnection:createClientString(address, port)
  return string.format("%s:%s", address, port)
end
