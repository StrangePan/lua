require "common/class"

Connection = buildClass()
local Class = Connection

function Class:_init(networkId)
  self.id = networkId
end

function Class:getNetworkId()
  return self.id
end
