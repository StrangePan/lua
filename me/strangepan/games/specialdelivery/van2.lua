require "graph_walker"
require "path"
require "direction"

Van2 = {}
Van2.__index = Van2
setmetatable(Van2, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})

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
Van2.VAN_SPEED = 30 --px per sec

function Van2:_init(path)
  self.color = math.random(#VAN_COLORS)

  self.walker = GraphWalker(gameGraph, path.start.edge, path.start.dist)
  self.walker:setDestination(path.dest.edge, path.dest.dist)
  self.walker:setSpeed(Van2.VAN_SPEED / 60)
  self.walker:setEdgeChangedListener(self, self.onEdgeChanged)
  self.walker:setDestinationReachedListener(self, self.onDestReached)
end

function Van2:destroy()
  self.walker:setEdgeChangedListener()
  self.walker:setDestinationReachedListener()
end

function Van2:update()
  self.walker:update()
end

function Van2:draw()
  local coords = gameGraph:pointOnEdge(self.walker.location.edgeId, self.walker.location.dist)
  local orientation = gameGraph:angleOfEdge(self.walker.location.edgeId)
  if self.walker.path:getDirectionToNextNode() == Direction.BACKWARD then
    orientation = orientation + math.pi
  end
  
  local color = VAN_COLORS[self.color]
  love.graphics.setColor(color[1], color[2], color[3])
  love.graphics.draw(VAN_SPRITE, coords.x, coords.y, orientation, 1, 1, VAN_SPRITE_ORIGIN.x, VAN_SPRITE_ORIGIN.y)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(VAN_SPRITE_LIGHTS, coords.x, coords.y, orientation, 1, 1, VAN_SPRITE_ORIGIN.x, VAN_SPRITE_ORIGIN.y)
end

function Van2:onDestReached()
  print("destination reached")
  self:destroy()
  walkerVan = nil -- destroy self, placeholder
end

function Van2:onEdgeChanged()
  print("changed edge")
end
