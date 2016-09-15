require "common/class"
require "PhysObject"

Player = buildClass(PhysObject)

function Player:_init()
  Player.superclass._init(self)
  
  self.angle = 0
  self.drawAngle = self.angle
  self.xStep = 32
  self.yStep = 32

  self:setSize(32, 32)
  self:setPosition(self.xStep, self.yStep)
  
  self.steps = {
       ["up"] = {x =  0, y = -1},
    ["right"] = {x =  1, y =  0},
     ["down"] = {x =  0, y =  1},
     ["left"] = {x = -1, y =  0}
  }
end

function Player:registerWithSecretary(secretary)
  Player.superclass.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onKeyPress, EventType.KEYBOARD_DOWN)
  secretary:registerEventListener(self, self.onKeyRelease, EventType.KEYBOARD_UP)
  secretary:registerEventListener(self, self.onPostPhysics, EventType.POST_PHYSICS)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  
  return self
end

function Player:onKeyPress(key, scancode, isrepeat)
  if key == "q" then self.angle = self.angle - (math.pi / 2) end
  if key == "e" then self.angle = self.angle + (math.pi / 2) end
  
  -- only allows a single key at a time to be pressed
  if self.key ~= nil then
    return
  end
  
  if self.steps[key] == nil then
    return
  end
  self.key = key

  local xStep = self.steps[key].x * self.xStep
  local yStep = self.steps[key].y * self.yStep

  local x, y = self:getPosition()
  local xNext = x + xStep
  local yNext = y + yStep

  local t, r, b, l = self:getBoundingBox(xStep, yStep)
  local collisions = self:getSecretary():getCollisions(t, r, b, l, Wall)
  
  -- Cancel jump if we would collide with a wall
  if table.getn(collisions) > 0 then
    collisions[1]:bump(key)
    return
  end
  
  self:setPosition(xNext, yNext)
  self:getSecretary():updateObject(self)
end

function Player:onKeyRelease(key, scancode)
  if key == self.key then
    self.key = nil
  end
end

function Player:onPostPhysics()
  if math.abs(self.angle - self.drawAngle) < math.pi / 128 then
    self.drawAngle = self.angle
  else
    self.drawAngle = self.drawAngle - (self.drawAngle - self.angle) * 0.375
  end
end

function Player:draw()
  love.graphics.push()
  
  local x, y = self:getPosition()
  local w, h = self:getSize()
  local ox = w/2
  local oy = h/2
  
  love.graphics.setColor(127, 127, 255)
  love.graphics.translate(x + ox, y + oy)
  love.graphics.rotate(self.drawAngle)
  
  love.graphics.rectangle("fill", -ox, -oy, w, h)
  
  love.graphics.pop()
end
