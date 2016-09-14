require "common/class"
require "PhysObject"

Wall = buildClass(PhysObject)

function Wall:_init(x, y)
  Wall.superclass._init(self)
  
  self:setPosition(x, y)
  self:setSize(32, 32)
end

function Wall:registerWithSecretary(secretary)
  Wall.superclass.registerWithSecretary(self, secretary)

  secretary:registerEventListener(self, self.draw, EventType.DRAW)
end

function Wall:draw()
  love.graphics.setColor(255, 255, 255)
  local x, y = self:getPosition()
  local w, h = self:getSize()
  love.graphics.rectangle("fill", x, y, w, h)
end
