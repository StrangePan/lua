require 'path'

Delivery = {}
Delivery.__index = Delivery
setmetatable(Delivery, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})

local START_SPRITE = love.graphics.newImage('pin_package.png')
local END_SPRITE = love.graphics.newImage('pin_destination.png')
local SPRITE_ORIGIN = {
  x = START_SPRITE:getWidth() / 2,
  y = START_SPRITE:getHeight() + 8,
}

function Delivery:_init(startEdgeId, startEdgeDist, endEdgeId, endEdgeDist)
  assert(type(startEdgeId) == 'number')
  assert(type(startEdgeDist) == 'number')
  assert(startEdgeDist >= 0 and startEdgeDist <= gameGraph:lengthOfEdge(startEdgeId))
  assert(type(endEdgeId) == 'number')
  assert(type(endEdgeDist) == 'number')
  assert(endEdgeDist >= 0 and endEdgeDist <= gameGraph:lengthOfEdge(endEdgeId))
  
  self.path = Path(gameGraph)
  self.path:setEndpoints(startEdgeId, startEdgeDist, endEdgeId, endEdgeDist)
  self.startCoords = gameGraph:pointOnEdge(self.path.start.edge, self.path.start.dist)
  self.endCoords = gameGraph:pointOnEdge(self.path.dest.edge, self.path.dest.dist)
end

function Delivery:draw()
  self.path:draw()
  love.graphics.setColor(224, 76, 118)
  love.graphics.draw(START_SPRITE, self.startCoords.x, self.startCoords.y, 0, 1, 1, SPRITE_ORIGIN.x, SPRITE_ORIGIN.y)
  love.graphics.draw(END_SPRITE, self.endCoords.x, self.endCoords.y, 0, 1, 1, SPRITE_ORIGIN.x, SPRITE_ORIGIN.y)
end
