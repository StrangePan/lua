require "common/class"
require "PhysObject"

Wall = buildClass(PhysObject)

function Wall:_init(x, y)
  Wall.superclass._init(self)
  
  self:setPosition(x, y)
  self:setSize(32, 32)
  
  self.xOffset = 0
  self.yOffset = 0
  
  self.bumpStrength = 6
  self.bumps = {
       [Direction.UP] = {x =  0, y = -1},
    [Direction.RIGHT] = {x =  1, y =  0},
     [Direction.DOWN] = {x =  0, y =  1},
     [Direction.LEFT] = {x = -1, y =  0}
  }
end

function Wall:bump(direction)
  if self.bumps[direction] == nil then
    return
  end
  
  self.xOffset = self.bumps[direction].x * self.bumpStrength
  self.yOffset = self.bumps[direction].y * self.bumpStrength
end

function Wall:registerWithSecretary(secretary)
  Wall.superclass.registerWithSecretary(self, secretary)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  secretary:registerEventListener(self, self.onPostPhysics, EventType.POST_PHYSICS)
  return self
end

function Wall:onPostPhysics()
  if self.xOffset <= -1 then
    self.xOffset = self.xOffset + 1
  elseif self.xOffset >= 1 then
    self.xOffset = self.xOffset - 1
  else
    self.xOffset = 0
  end
  if self.yOffset <= -1 then
    self.yOffset = self.yOffset + 1
  elseif self.yOffset >= 1 then
    self.yOffset = self.yOffset - 1
  else
    self.yOffset = 0
  end
end

function Wall:draw()
  love.graphics.setColor(255, 255, 255)
  local x, y = self:getPosition()
  x = x + self.xOffset
  y = y + self.yOffset
  local w, h = self:getSize()
  love.graphics.rectangle("fill", x, y, w, h)
end
