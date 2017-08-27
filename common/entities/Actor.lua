require "strangepan.secretary.PhysObject"
require "entities.Footprint"
require "EventCoordinator"
require "Color"
require "entities.MazerinoTranslations"

Actor = buildClass(PhysObject)

function Actor:_init()
  Actor.superclass._init(self)
  
  self.angle = 0
  self.drawAngle = self.angle
  self.xStep = 1
  self.yStep = 1
  
  self.color = Color(127, 127, 255)

  self:setSize(1, 1)
  self:setPosition(0, 0)
  
  self.moveEventCoordinator = EventCoordinator()
  self.spinEventCoordinator = EventCoordinator()

  self.bumpStrength = 6
  self.bumpOffsetX = 0
  self.bumpOffsetY = 0
  
  self.steps = {
       [Direction.UP] = {x =  0, y = -1},
    [Direction.RIGHT] = {x =  1, y =  0},
     [Direction.DOWN] = {x =  0, y =  1},
     [Direction.LEFT] = {x = -1, y =  0}
  }
end

--
-- Callbacks receive:
-- actor: the Actor instance that moved
-- fromX: the starting X position
-- fromY: the starting Y position
-- direction: the direction of movement
-- success: boolean whether or not the movement was a success
--
function Actor:registerMoveListener(listener, callback)
  return self.moveEventCoordinator:registerListener(listener, callback)
end

function Actor:notifyMoveListeners(x, y, dir, success)
  return self.moveEventCoordinator:notifyListeners(self, x, y, dir, success)
end

function Actor:unregisterMoveListener(listener, callback)
  return self.moveEventCoordinator:unregisterListener(listener, callback)
end

--
-- Callbacks receive:
-- actor: the Actor instance that spun
--
function Actor:registerSpinListener(listener, callback)
  return self.spinEventCoordinator:registerListener(listener, callback)
end

function Actor:notifySpinListeners()
  return self.spinEventCoordinator:notifyListeners(self)
end

function Actor:unregisterSpinListener(listener, callback)
  return self.spinEventCoordinator:unregisterListener(listener, callback)
end

function Actor:registerWithSecretary(secretary)
  Actor.superclass.registerWithSecretary(self, secretary)
  
  self.moveEventCoordinator:registerWithSecretary(secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onStep, EventType.STEP)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  secretary:setDrawLayer(self, DrawLayer.MAIN)
  
  return self
end

--
-- Gets the actor's base color
--
function Actor:getColor()
  return self.color
end

--
-- Sets the actor's base color
--
function Actor:setColor(color)
  self.color = color
end

--
-- Attempts to move the player in the given direction. Returns `true` if the
-- player moved and `false` if not. Notifies registered move listeners.
--
function Actor:move(direction, force)
  local x, y = self:getPosition()
  local success = self:tryMove(direction, force)
  self:notifyMoveListeners(x, y, direction, success)
  return success
end

--
-- Attempts to move the actor one space in the specified direction. If the
-- actor successfully moves as a result, returns `true`.
--
function Actor:tryMove(direction, force)
  direction = Direction.fromId(direction)
  if direction == nil then
    return false
  end
  
  local xStep = self.steps[direction].x * self.xStep
  local yStep = self.steps[direction].y * self.yStep

  local x, y = self:getPosition()
  local xNext = x + xStep
  local yNext = y + yStep

  local secretary = self:getSecretary()
  if not force then
    local t, r, b, l = self:getBoundingBox(xStep, yStep)
    local collisions = secretary:getCollisions(t, r, b, l, Wall)

    -- Cancel jump if we would collide with a wall
    if table.getn(collisions) > 0 then
      collisions[1]:bump(direction)
      self:bump(direction)
      return false
    end
  end
  
  local r, g, b = self:getColor():getRGBA()
  Footprint(r, g, b, x, y):registerWithSecretary(secretary)
  self:setPosition(xNext, yNext)
  return true
end

function Actor:setPosition(x, y, z)
  local ox, oy, oz = self:getPosition()
  Actor.superclass.setPosition(self, x, y, z)
  
  x, y, z = self:getPosition()
  if ox ~= x or oy ~= y or oz ~= z then
    local secretary = self:getSecretary()
    if secretary then
      self:getSecretary():updateObject(self)
    end
  end
end

--
-- Bumps the actor in a given direction, which is simply an animation that
-- causes the entity to look like it's been nudged slightly in a given
-- direction.
--
function Actor:bump(direction)
  direction = Direction.fromId(direction)
  if direction == nil then
    return false
  end

  self.bumpOffsetX = self.steps[direction].x * self.bumpStrength
  self.bumpOffsetY = self.steps[direction].y * self.bumpStrength
end

--
-- Causes the actor to perform a "spin" emote and notifies listeners of event.
--
function Actor:spin()
  self:trySpin()
  self:notifySpinListeners()
  return true
end

--
-- Causes the actor to perform a "spin" emote.
--
function Actor:trySpin()
  -- Don't allow more than 2 spins to be queued up.
  if self.drawAngle < self.angle - math.pi * 2 then return end
  self.angle = self.angle + math.pi * 2
end

function Actor:onStep()
  self:updateDrawState()
end

local function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function Actor:updateDrawState()

  -- Update for spin animation
  if math.abs(self.angle - self.drawAngle) < math.pi / 128 then
    self.angle = 0
    self.drawAngle = self.angle
  else
    local delta = -(self.drawAngle - self.angle) * 0.25
    local maxdelta = math.pi / 12
    if delta < -maxdelta then
      delta = -maxdelta
    elseif delta > maxdelta then
      delta = maxdelta
    end
    self.drawAngle = self.drawAngle + delta
  end

  -- Update for bump animation
  if self.bumpOffsetX ~= 0 then
    self.bumpOffsetX = self.bumpOffsetX - sign(self.bumpOffsetX)
  end
  if self.bumpOffsetY ~= 0 then
    self.bumpOffsetY = self.bumpOffsetY - sign(self.bumpOffsetY)
  end
end

function Actor:draw()
  love.graphics.push()
  local x, y = toScreen(self:getPosition())
  x = x + self.bumpOffsetX
  y = y + self.bumpOffsetY
  local w, h = toScreen(self:getSize())
  local ox = w/2
  local oy = h/2
  love.graphics.setColor(self:getColor():getRGBA())
  love.graphics.translate(x + ox, y + oy)
  love.graphics.rotate(self.drawAngle)
  love.graphics.rectangle("fill", -ox, -oy, w, h)
  love.graphics.pop()
end
