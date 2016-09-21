require "PhysObject"
require "Footprint"
require "EventCoordinator"

Actor = buildClass(PhysObject)

function Actor:_init()
  Actor.superclass._init(self)
  
  self.angle = 0
  self.drawAngle = self.angle
  self.xStep = 32
  self.yStep = 32
  
  self.r = 127
  self.g = 127
  self.b = 255

  self:setSize(32, 32)
  self:setPosition(self.xStep, self.yStep)
  
  self.moveEventCoordinator = EventCoordinator()
  
  self.steps = {
       [Direction.UP] = {x =  0, y = -1},
    [Direction.RIGHT] = {x =  1, y =  0},
     [Direction.DOWN] = {x =  0, y =  1},
     [Direction.LEFT] = {x = -1, y =  0}
  }
end

function Actor:registerMoveListener(object, callback)
  return self.moveEventCoordinator:registerListener(object, callback)
end

function Actor:notifyMoveListeners(x, y, z)
  return self.moveEventCoordinator:notifyListeners(self, x, y, z)
end

function Actor:registerWithSecretary(secretary)
  Actor.superclass.registerWithSecretary(self, secretary)
  
  self.moveEventCoordinator:registerWithSecretary(secretary)
  
  -- Register for event callbacks
  secretary:registerEventListsner(self, self.onStep, EventType.STEP)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  secretary:setDrawLayer(self, DrawLayer.MAIN)
  
  return self
end

--
-- Attempts to move the player in the given direction. Returns `true` if the
-- player moved and `false` if not.
--
function Actor:move(direction)
  direction = Direction.fromId(direction)
  if direction == nil then
    return false
  end
  
  local xStep = self.steps[direction].x * self.xStep
  local yStep = self.steps[direction].y * self.yStep

  local x, y = self:getPosition()
  local xNext = x + xStep
  local yNext = y + yStep

  local t, r, b, l = self:getBoundingBox(xStep, yStep)
  local secretary = self:getSecretary()
  local collisions = secretary:getCollisions(t, r, b, l, Wall)
  
  -- Cancel jump if we would collide with a wall
  if table.getn(collisions) > 0 then
    collisions[1]:bump(key)
    return false
  end
  
  local w, h = self:getSize()
  Footprint(self.r, self.g, self.b, x, y, w, h):registerWithSecretary(secretary)
  self:setPosition(xNext, yNext)
  return true
end

function Actor:setPosition(x, y, z)
  local ox, oy, oz = self:getPosition()
  Actor.superclass.setPosition(self, x, y, z)
  
  x, y, z = self:getPosition()
  if ox ~= x or oy ~= y or oz ~= z then
    self:getSecretary():updateObject(self)
    self:notifyMoveListeners(x, y, z)
  end
end

function Actor:spin()
  self.angle = self.angle + math.pi * 2
end

function Actor:onStep()
  self:updateDrawState()
end

function Actor:updateDrawState()
  if math.abs(self.angle - self.drawAngle) < math.pi / 128 then
    self.angle = 0
    self.drawAngle = self.angle
  else
    self.drawAngle = self.drawAngle - (self.drawAngle - self.angle) * 0.375
  end
end

function Actor:draw()
  love.graphics.push()
  local x, y = self:getPosition()
  local w, h = self:getSize()
  local ox = w/2
  local oy = h/2
  love.graphics.setColor(self.r, self.g, self.b)
  love.graphics.translate(x + ox, y + oy)
  love.graphics.rotate(self.drawAngle)
  love.graphics.rectangle("fill", -ox, -oy, w, h)
  love.graphics.pop()
end
