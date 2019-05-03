local Entity = require "me.strangepan.games.mazerino.common.strangepan.secretary.Entity"
local type = require "me.strangepan.games.mazerino.common.strangepan.util.type"
local Set = require "me.strangepan.games.mazerino.common.Set"
local class = require "me.strangepan.libs.lua.v1.class"

local LevelMap = class.build(Entity)

function LevelMap:_init()
  class.superclass(LevelMap)._init(self)
  
  self.entities = Set()
end

function LevelMap:addEntity(entity)
  assertClass(entity, Entity, "entity")
  self.entities:add(entity)
end

function LevelMap:destroy()
  for entity in self.entities:each() do
    entity:destroy()
  end
  class.superclass(LevelMap).destroy(self)
end

function LevelMap:registerWithSecretary(secretary)
  class.superclass(LevelMap).registerWithSecretary(self, secretary)
  for entity in self.entities:each() do
    entity:registerWithSecretary(secretary)
  end
end

function LevelMap:deregisterWithSecretary()
  for entity in self.entities:each() do
    entity:deregisterWithSecretary()
  end
  class.superclass(LevelMap).deregisterWithSecretary(self)
end

return LevelMap
