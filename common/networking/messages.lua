require "MessageType"
require "EntityUpdateType"

messages = {}

-- creates a message to attempt to connect to a server
function messages.connectionInit()
  return {
    t=MessageType.CONNECT_INIT
  }
end

function messages.connectionAck(playerId)
  return {
    t=MessageType.CONNECT_ACK,
    p=playerId,
  }
end

function messages.connectionAckAck(playerId)
  return {
    t=MessageType.CONNECT_ACK_ACK,
    p=playerId,
  }
end

function messages.disconnect()
  return {
    t=MessageType.DISCONNECT
  }
end

function messages.ping()
  return {
    t=MessageType.PING
  }
end

function messages.ack(channel, ackNum)
  return {
    t=MessageType.ACK,
    c=channel,
    n=ackNum
  }
end

function messages.ackRequest(channel, ackNum, message)
  return {
    t=MessageType.ACK_REQUEST,
    c=channel,
    n=ackNum,
    m=message,
  }
end

function messages.ackRequestReset(channel, ackNum, message)
  return {
    t=MessageType.ACK_REQUEST_RESET,
    c=channel,
    n=ackNum,
    m=message,
  }
end

messages.entityUpdate = {}

function messages.entityUpdate.create(id, entityType, params)
  return {
    t=MessageType.ENTITY_UPDATE,
    i=id,
    u=EntityUpdateType.CREATING,
    e=entityType,
    d=params,
  }
end

function messages.entityUpdate.destroy(id)
  return {
    t=MessageType.ENTITY_UPDATE,
    i=id,
    u=EntityUpdateType.DESTROYING,
  }
end

function messages.entityUpdate.sync(id, entityType, params, syncNum)
  return {
    t=MessageType.ENTITY_UPDATE,
    i=id,
    u=EntityUpdateType.SYNCHRONIZING,
    e=entityType,
    d=params,
    n=syncNum,
  }
end

function messages.entityUpdate.inc(id, params, baseSync)
  return {
    t=MessageType.ENTITY_UPDATE,
    i=id,
    u=EntityUpdateType.INCREMENTING,
    d=params,
    n=baseSync,
  }
end

function messages.entityUpdate.outOfSync(id, baseSync)
  return {
    t=MessageType.ENTITY_UPDATE,
    i=id,
    u=EntityUpdateType.OUT_OF_SYNC,
    n=baseSync,
  }
end

-- bundles multiple messages into a single message bundle
function messages.bundle(...)
  local msgs = {...}
  local bundle = {
    t = MessageType.BUNDLE
  }
  for i,msg in ipairs(msgs) do
    bundle[i] = msg
  end
  return bundle
end
