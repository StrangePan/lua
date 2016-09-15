require "common/class"
require "Entity"

Camera = buildClass(Entity)

function Camera:_init()
  Camera.superclass._init(self)
  
  self.x = 0
  self.y = 0
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
  return self
end

function Camera:onPreDraw()
  love.graphics.origin()
  local width, height = love.graphics.getDimensions()
  love.graphics.translate((width/2)-self.x, (height/2)-self.y)
end
