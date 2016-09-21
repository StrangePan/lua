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

-- bundles multiple messages into a single message bundle
function messages.bundle(...)
  local msgs = {...}
  local bundle = {type = MessageType.CLIENT_CONNECT_INIT}
  for i,msg in ipairs(msgs) do
    bundle[i] = msg
  end
  return bundle
end
