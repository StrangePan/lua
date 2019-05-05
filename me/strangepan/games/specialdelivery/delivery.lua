local Path = require "me.strangepan.games.specialdelivery.path"
local class = require "me.strangepan.libs.lua.v1.class"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local gameGraph = require "me.strangepan.games.specialdelivery.graph"

local Delivery = class.build()

local START_SPRITE = love.graphics.newImage('pin_package.png')
local END_SPRITE = love.graphics.newImage('pin_destination.png')
local SPRITE_ORIGIN = {
  x = START_SPRITE:getWidth() / 2,
  y = START_SPRITE:getHeight() + 8,
}

function Delivery:_init(startEdgeId, startEdgeDist, endEdgeId, endEdgeDist)
  assert_that(startEdgeId):is_a_number()
  assert_that(startEdgeDist)
      :is_a_number()
      :is_greater_than_or_equal_to(0)
      :is_less_than_or_equal_to(gameGraph:lengthOfEdge(startEdgeId))
  assert_that(endEdgeId):is_a_number()
  assert_that(endEdgeDist)
      :is_a_number()
      :is_greater_than_or_equal_to(0)
      :is_less_than_or_equal_to(gameGraph:lengthOfEdge(endEdgeId))
  
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

return Delivery
