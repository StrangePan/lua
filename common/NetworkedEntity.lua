require "common/class"
require "Entity"

NetworkedEntity = buildClass()
local Class = NetworkedEntity

function Class:_init(networkId, localEntity)
  self.networkId = networkId
  self.entity = localEntity
end

function Class:getNetworkId()
  return self.networkId
end

function Class:getLocalEntity()
  return self.entity
end
