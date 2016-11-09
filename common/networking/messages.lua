require "MessageType"
require "EntityUpdateType"

messages = {}

-- creates a message to attempt to connect to a server
function messages.connectionInit()
  return {
    type=MessageType.CONNECT_INIT
  }
end

function messages.connectionAck(playerId)
  return {
    type=MessageType.CONNECT_ACK,
    pid=playerId,
  }
end

function messages.disconnect()
  return {
    type=MessageType.DISCONNECT
  }
end

function messages.ping()
  return {
    type=MessageType.PING
  }
end

function messages.mapStatus(num, map)
  return {
    type=MessageType.MAP_STATUS,
    num,
    map=map:getStatus()
  }
end

function messages.ack(channel, ackNum)
  return {
    type=MessageType.ACK,
    c=channel,
    n=ackNum
  }
end

function messages.ackReset(channel, ackNum)
  return {
    type=MessageType.ACK_RESET,
    c=channel,
    n=ackNum
  }
end

function messages.ackRequest(channel, ackNum, message)
  return {
    type=MessageType.ACK_REQUEST,
    c=channel,
    n=ackNum,
    m=message,
  }
end

messages.entityUpdate = {}

function messages.entityUpdate.create(id, entityType, params)
  return {
    type=MessageType.ENTITY_UPDATE,
    neid = id,
    utype = EntityUpdateType.CREATING,
    etype = entityType,
    params = params,
  }
end

function messages.entityUpdate.sync(id, entityType, params)
  return {
    type=MessageType.ENTITY_UPDATE,
    neid = id,
    utype = EntityUpdateType.SYNCHRONIZING,
    etype = entityType,
    params = params,
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
