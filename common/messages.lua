require "MessageType"

messages = {}

messages[MessageType.CLIENT_CONNECT_INIT] = {
  -- empty message
}

messages[MessageType.SERVER_CONNECT_ACK] = {
  id = 0, -- CHANGE
}



-- initialize common message fields
for i,msg in ipairs(messages) do
  msg.type = i
end
