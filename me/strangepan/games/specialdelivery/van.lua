local class = require "me.strangepan.libs.lua.v1.class"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local gameGraph = require "me.strangepan.games.specialdelivery.graph"

local Van = class.build()

local FORWARD = 1
local BACKWARD = -1
local VAN_SPRITE = love.graphics.newImage('van.png')
local VAN_SPRITE_LIGHTS = love.graphics.newImage('van_lights.png')
local VAN_SPRITE_ORIGIN = {
  x = VAN_SPRITE:getWidth() / 2,
  y = VAN_SPRITE:getHeight() / 2,
}
local VAN_COLORS = {
  {94, 174, 255},
  {94, 255, 97},
  {231, 255, 124},
  {234, 142, 56},
}
local VAN_SPEED = 30 --px per sec

function Van:_init(edgeId, dist)
  assert_that(edgeId):is_a_number()
  assert_that(dist)
      :is_a_number()
      :is_greater_than_or_equal_to(0)
      :is_less_than_or_equal_to(gameGraph:lengthOfEdge(edgeId))
  
  self.location = {
    edgeId = edgeId,
    dist = dist
  }
  self.direction = FORWARD
  self.color = math.random(#VAN_COLORS)
end

function Van:update()
  local edgeLength = gameGraph:lengthOfEdge(self.location.edgeId)
  local pxPerStep = VAN_SPEED / 60
  local stepDist = pxPerStep * self.direction
  local dist = self.location.dist + stepDist
  while dist > edgeLength or dist < 0 do
    if dist > edgeLength then
      dist = edgeLength - (dist - edgeLength)
    elseif dist < 0 then
      dist = -dist
    end
    self.direction = -self.direction
  end
  self.location.dist = dist
end

function Van:mousepressed(x, y, button)
  if button ~= 1 then return false end
  local coords = gameGraph:pointOnEdge(self.location.edgeId, self.location.dist)
  if math.abs(x - coords.x) < 12 and math.abs(y - coords.y) < 12 then
    return true
  end
  return false
end

function Van:draw()
  local coords = gameGraph:pointOnEdge(self.location.edgeId, self.location.dist)
  local orientation = gameGraph:angleOfEdge(self.location.edgeId)
  if self.direction == BACKWARD then
    orientation = orientation + math.pi
  end
  
  local color = VAN_COLORS[self.color]
  love.graphics.setColor(color[1], color[2], color[3])
  love.graphics.draw(VAN_SPRITE, coords.x, coords.y, orientation, 1, 1, VAN_SPRITE_ORIGIN.x, VAN_SPRITE_ORIGIN.y)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(VAN_SPRITE_LIGHTS, coords.x, coords.y, orientation, 1, 1, VAN_SPRITE_ORIGIN.x, VAN_SPRITE_ORIGIN.y)
end

return Van
