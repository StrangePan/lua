require "strangepan.secretary.Entity"
require "strangepan.util.type"
require "Set"

Map = buildClass(Entity)

function LevelMap:_init()
  LevelMap.superclass._init(self)
  
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
  LevelMap.superclass.destroy(self)
end

function LevelMap:registerWithSecretary(secretary)
  LevelMap.superclass.registerWithSecretary(self, secretary)
  for entity in self.entities:each() do
    entity:registerWithSecretary(secretary)
  end
end

function LevelMap:deregisterWithSecretary()
  for entity in self.entities:each() do
    entity:deregisterWithSecretary()
  end
  LevelMap.superclass.deregisterWithSecretary(self)
end
