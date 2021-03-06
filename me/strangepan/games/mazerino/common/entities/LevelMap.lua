local Entity = require "me.strangepan.libs.secretary.v1.Entity"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local Set = require "me.strangepan.games.mazerino.common.Set"
local class = require "me.strangepan.libs.util.v1.class"

local LevelMap = class.build(Entity)

function LevelMap:_init()
  Entity._init(self)
  
  self.entities = Set()
end

function LevelMap:addEntity(entity)
  assert_that(entity):is_instance_of(Entity):and_return()
  self.entities:add(entity)
end

function LevelMap:destroy()
  for entity in self.entities:each() do
    entity:destroy()
  end
  Entity.destroy(self)
end

function LevelMap:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  for entity in self.entities:each() do
    entity:registerWithSecretary(secretary)
  end
end

function LevelMap:deregisterWithSecretary()
  for entity in self.entities:each() do
    entity:deregisterWithSecretary()
  end
  Entity.deregisterWithSecretary(self)
end

return LevelMap
