require "common/class"
require "PhysObject"

Player = buildClass(PhysObject)

function Player:_init()
  Player.superclass._init(self)
  
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
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
end

function Player:onKeyPress(key, scancode, isrepeat)
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

function Player:draw()
  love.graphics.setColor(63, 63, 255)
  local x, y = self:getPosition()
  local w, h = self:getSize()
  love.graphics.rectangle("fill", x, y, w, h)
end
