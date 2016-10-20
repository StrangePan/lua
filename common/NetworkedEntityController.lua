require "common/class"
require "common/functions"
require "Entity"

NetworkedEntityController = buildClass()
local Class = NetworkedEntityController

function Class:_init(networkId, localEntity)
  self.networkId = networkId
  self.entity = localEntity
  assertType(localEntity, "localEntity", Entity)
  
  -- 
  self.entityState
  
  -- Network status of the object
  self.networkStatus = nil
end

--
-- Get the shared network ID of this entity.
--
function Class:getNetworkId()
  return self.networkId
end

--
-- Gets whether or not the local instance of the entity is merely a slave to
-- some other instance of the entity running on an external program instance.
-- In other words, this method asks "is this object merely a local
-- representation of another object?"
--
-- If this method returns true, it means that the `Entity` returned by the
-- :getLocalEntity() method is controlled by a remote instance of the program.
--
function Class:isNetworkSlave()
  return false -- TODO
end

--
-- Gets the ID of the network connection that is responsible for controlling
-- this entity.
--
function Class:getNetworkMasterId()
end

function Class:getLocalEntity()
  return self.entity
end

function Class:getLastKnownStatus()
  return self.status
end
