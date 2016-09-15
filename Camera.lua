require "common/class"
require "Entity"

Camera = buildClass(Entity)

function Camera:_init()
  Camera.superclass._init(self)
  
  self.x = 0
  self.y = 0
  self.drawX = self.x
  self.drawY = self.y
end

function Camera:moveTo(x, y)
  assertType(x, "x", "number")
  assertType(y, "y", "number")
  self.x = x
  self.y = y
end

function Camera:registerWithSecretary(secretary)
  Camera.superclass.registerWithSecretary(self, secretary)
  secretary:registerEventListener(self, self.onPreDraw, EventType.PRE_DRAW)
  secretary:registerEventListener(self, self.onPostPhysics, EventType.POST_PHYSICS)
  return self
end

function Camera:onPreDraw()
  love.graphics.origin()
  local width, height = love.graphics.getDimensions()
  love.graphics.translate((width/2)-self.drawX, (height/2)-self.drawY)
end

function Camera:onPostPhysics()
  local snapThreshold = 0.0078125
  local easeRatio = 0.25
  if math.abs(self.drawX - self.x) < snapThreshold then
    self.drawX = self.x
  else
    self.drawX = self.drawX - (self.drawX - self.x) * easeRatio
  end
  if math.abs(self.drawY - self.y) < snapThreshold then
    self.y = self.drawX
  else
    self.drawY = self.drawY - (self.drawY - self.y) * easeRatio
  end
end
