local Direction = require "me.strangepan.games.specialdelivery.direction"
local class = require "me.strangepan.libs.lua.v1.class"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

local Path = class.build()

function Path:_init(graph)
  assert_that(graph):is_a_table()
  self.graph = graph
  self.direction = 1
end

local updateDirection = function(self)
  if self.start.edge == self.dest.edge then
    if self.start.dist < self.dest.dist then
      self.direction = Direction.FORWARD
    elseif self.start.dist > self.dest.dist then
      self.direction = Direction.BACKWARD
    end
  else
    if self.graph.edges[self.start.edge].to == self.nodes[1] then
      self.direction = Direction.FORWARD
    else
      self.direction = Direction.BACKWARD
    end
  end
end

function Path:setEndpoints(startEdgeId, startEdgeDist, endEdgeId, endEdgeDist)
  self.start = {
    edge = startEdgeId,
    dist = startEdgeDist,
  }
  self.dest = {
    edge = endEdgeId,
    dist = endEdgeDist,
  }
  
  self.nodes = self.graph:findPath(self.start.edge, self.start.dist, self.dest.edge, self.dest.dist)
  updateDirection(self)
  self.nextEdge = nil
  self:refreshDrawPoints()
end

function Path:setStart(startEdgeId, startEdgeDist)
  assert_that(startEdgeId):is_a_number():is_a_key_in(self.graph.edges)
  assert_that(startEdgeDist)
      :is_a_number()
      :is_greater_than_or_equal_to(0)
      :is_less_than_or_equal_to(self.graph:lengthOfEdge(startEdgeId))

  -- Trivial case, short-circuit. No need to recalculate path.
  if startEdgeId == self.start.edge then
    self.start.dist = startEdgeDist
    if self.drawPoints then
      self.drawPoints[1] = self.graph:pointOnEdge(self.start.edge, self.start.dist)
    end
    return
  end

  self.start.edge = startEdgeId
  self.start.dist = startEdgeDist

  -- See if new start is on path, short-circuit. No need to recalculate path.
  local newNodes
  local drawPointsOffset
  for i = 2,#self.nodes do
    if not newNodes then
      local edge = self.graph:edgeBetweenNodes(self.nodes[i-1], self.nodes[i])
      if edge and edge.id == startEdgeId then
        newNodes = {}
        drawPointsOffset = i - 1
        self.drawPoints[1 + i - drawPointsOffset] = self.drawPoints[1 + i]
        self.drawPoints[1 + i] = nil
      end
    end
    if newNodes then
      table.insert(newNodes, self.nodes[i])

      -- Draw points contain #nodes + 2 (start, end, and all nodes in between).
      self.drawPoints[2 + i - drawPointsOffset] = self.drawPoints[2 + i]
      self.drawPoints[2 + i] = nil
    end
  end
  if newNodes then
    self.nodes = newNodes
    updateDirection(self)
    self.nextEdge = nil
    return
  end

  -- Start does not exist on path; recalculate
  self.nodes = self.graph:findPath(self.start.edge, self.start.dist, self.dest.edge, self.dest.dist)
  updateDirection(self)
  self.nextEdge = nil
  self:refreshDrawPoints()
end

function Path:getDirectionToNextNode()
  return self.direction
end

function Path:getNextEdge()
  if not self.nextEdge then
    local nNodes
    if not self.nodes then
      nNodes = 0
    else
      nNodes = #self.nodes
    end
    if nNodes == 0 then
      self.nextEdge = nil
    elseif nNodes == 1 then
      self.nextEdge = self.dest.edge
    else
      self.nextEdge = self.graph:edgeBetweenNodes(self.nodes[1], self.nodes[2]).id
    end
  end
  return self.nextEdge
end

function Path:getNextNode()
  if not self.nodes then
    return nil
  end
  return self.nodes[1]
end

function Path:refreshDrawPoints()
  self.drawPoints = {}
  table.insert(self.drawPoints, self.graph:pointOnEdge(self.start.edge, self.start.dist))
  for _,nodeId in ipairs(self.nodes) do
    table.insert(self.drawPoints, self.graph.nodes[nodeId])
  end
  table.insert(self.drawPoints, self.graph:pointOnEdge(self.dest.edge, self.dest.dist))
end

function Path:draw()
  if not self.drawPoints then return end
  
  local points = self.drawPoints
  love.graphics.setColor(224, 76, 118)
  love.graphics.setLineWidth(12)
  love.graphics.ellipse('fill', points[1].x, points[1].y, 6, 6)
  for i = 2,#self.drawPoints,1 do
    love.graphics.line(points[i-1].x, points[i-1].y, points[i].x, points[i].y)
    love.graphics.ellipse('fill', points[i].x, points[i].y, 6, 6)
  end
end

return Path
