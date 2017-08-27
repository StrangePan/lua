require "strangepan.secretary.PhysObject"
require "Color"
require "entities.MazerinoTranslations"

Collectible = buildClass(PhysObject)

function Collectible:_init(x, y)
  Collectible.superclass._init(self)
  self:setPosition(x, y)
  self:setSize(1, 1)
  self.animationTime = 0
  self.animationStep = 1/512
  self.color = Color(255, 255, 255)
end

function Collectible:registerWithSecretary(secretary)
  Collectible.superclass.registerWithSecretary(self, secretary)
  secretary:registerEventListener(self, self.step, EventType.STEP)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
end

function Collectible:step()
  self.animationTime = self.animationTime + self.animationStep
  while self.animationTime >= 1 do
    self.animationTime = self.animationTime - 1
  end
end

function Collectible:draw()
  love.graphics.push()
  local x, y = toScreen(self:getPosition())
  local w, h = toScreen(self:getSize())
  local ow = w/2
  local oh = h/2
  love.graphics.setColor(self.color:getRGBA())
  love.graphics.translate(x + ow, y + oh)
  
  -- inner square
  love.graphics.push()
  local innerScale = 0.5
  love.graphics.rotate(self.animationTime * (math.pi*2))
  love.graphics.rectangle("fill", -ow * innerScale, -oh * innerScale, w * innerScale, h * innerScale)
  love.graphics.pop()
  
  -- outer box
  love.graphics.push()
  local outerScale = 0.625
  love.graphics.rotate(-self.animationTime * 1.25 * (math.pi*2))
  love.graphics.rectangle("line", -ow * outerScale, -oh * outerScale, w * outerScale, h * outerScale)
  love.graphics.pop()
  
  love.graphics.pop()
end
