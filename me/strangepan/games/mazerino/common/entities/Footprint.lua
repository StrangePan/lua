local class = require "me.strangepan.libs.util.v1.class"
local Entity = require "me.strangepan.games.mazerino.common.strangepan.secretary.Entity"
local translation = require "me.strangepan.games.mazerino.common.mazerino.util.translation"
local EventType = require "me.strangepan.games.mazerino.common.strangepan.secretary.EventType"
local DrawLayer = require "me.strangepan.games.mazerino.common.strangepan.secretary.DrawLayer"

local Footprint = class.build(Entity)

function Footprint:_init(r, g, b, x, y)
  Entity._init(self)
  
  self.r = r
  self.g = g
  self.b = b
  self.x = translation.toScreen(x)
  self.y = translation.toScreen(y)
  self.w = translation.toScreen(1)
  self.h = translation.toScreen(1)
  
  self.a = 191
end

function Footprint:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  secretary:registerEventListener(self, self.onPostPhysics, EventType.POST_PHYSICS)
  secretary:registerEventListener(self, self.draw, EventType.DRAW, DrawLayer.BACKGROUND_PROPS)
  
  return self
end

function Footprint:onPostPhysics()
  self.a = self.a - 8
  self.x = self.x + 0.5
  self.y = self.y + 0.5
  self.w = self.w - 1
  self.h = self.h - 1
  
  if self.a <= 0 then
    self:destroy()
  end
end

function Footprint:draw()
  love.graphics.push()  
  love.graphics.translate(self.x + self.w / 2, self.y + self.h / 2)
  love.graphics.setColor(self.r, self.g, self.b, self.a)
  love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)
  love.graphics.pop()
end

return Footprint
