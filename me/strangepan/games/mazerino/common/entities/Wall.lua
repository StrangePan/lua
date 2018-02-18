require "strangepan.util.class"
require "entities.Direction"
require "strangepan.secretary.PhysObject"
local translation = require "mazerino.util.translation"

Wall = buildClass(PhysObject)

function Wall:_init(x, y)
  Wall.superclass._init(self)
  
  self:setPosition(x or 0, y or 0)
  self:setSize(1, 1)
  
  self.xOffset = 0
  self.yOffset = 0
  self.drawScale = 0
  
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
  secretary:registerEventListener(self, self.onStep, EventType.STEP)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  return self
end

function Wall:onStep()
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
  if self.drawScale > 0.975 then
    self.drawScale = 1
  else
    self.drawScale = self.drawScale + 0.025
  end
end

function Wall:draw()
  love.graphics.setColor(255, 255, 255)
  local x, y = translation.toScreen(self:getPosition())
  x = x + self.xOffset
  y = y + self.yOffset
  local w, h = translation.toScreen(self:getSize())
  local scale = self.drawScale
  love.graphics.rectangle("fill", x + (w/2 - w/2 * scale), y + (h/2 - h/2 * scale), w * scale, h * scale)
end
