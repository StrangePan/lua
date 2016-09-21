require "MessageType"

messages = {}

-- creates a message to attempt to connect to a server
function messages.clientConnectInit()
  return {
    type=MessageType.CLIENT_CONNECT_INIT
  }
end

function messages.serverConnectAck(clientId)
  return {
    type=MessageType.SERVER_CONNECT_ACK,
    id=clientId
  }
end

function messages.clientDisconnect()
  return {
    type=MessageType.CLIENT_DISCONNECT
  }
end

function messages.ping()
  return {
    type=MessageType.PING
  }
end

-- bundles multiple messages into a single message bundle
function messages.bundle(...)
  local msgs = {...}
  local bundle = {type = MessageType.CLIENT_CONNECT_INIT}
  for i,msg in ipairs(msgs) do
    bundle[i] = msg
  end
  return bundle
end
