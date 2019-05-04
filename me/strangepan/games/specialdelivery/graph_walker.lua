local Path = require "me.strangepan.games.specialdelivery.path"
local class = require "me.strangepan.libs.lua.v1.class"
local assert_that = require "me.strangepan.libs.lua.truth.v1.assert_that"

local GraphWalker = class.build()

--
-- A class that can traverse a graph at a constant number of pixels per step. Requires:
-- - a graph object.
-- - the id of the starting edge.
-- - the number of pixels along the edge it is located.
--
function GraphWalker:_init(graph, edgeId, dist)
  assert_that(graph):is_a_table()
  assert_that(edgeId):is_a_number()
  assert_that(dist):is_a_number()
      :is_greater_than_or_equal_to(0)
      :is_less_than_or_equal_to(graph:lengthOfEdge(edgeId))

  self.graph = graph
  self.location = {
    edgeId = edgeId,
    dist = dist
  }
  self.speed = 0
  self.rolloverPxNextStep = 0
end

--
-- Sets a destination edge and distance along that edge. Find the shortest path from current
-- location to destination.
--
function GraphWalker:setDestination(edgeId, dist)
  self.path = Path(self.graph)
  self.path:setEndpoints(self.location.edgeId, self.location.dist, edgeId, dist)
end

-- Speed in pixels per step (per time :update() is called).
function GraphWalker:setSpeed(pxPerStep)
  self.pxPerStep = pxPerStep
end

--
-- Allows a listener to know when the walker changes current edge.
--
-- If destination reached and edge changed occur at the same time, destination reached
-- callback will be triggered first.
--
function GraphWalker:setEdgeChangedListener(listener, callback)
  if not listener or not callback then
    self.edgeChangeListener = nil
  end
  self.edgeChangeListener = {listener = listener, callback = callback}
end

--
-- Allows a listener to know when the destination has been reached.
-- 
-- If destination reached and edge changed occur at the same time, destination reached
-- callback will be triggered first.
--
function GraphWalker:setDestinationReachedListener(listener, callback)
  if not listener or not callback then
    self.destReachedListener = nil
  end
  self.destReachedListener = {listener = listener, callback = callback}
end

local clamp = function(min, mid, max) return math.max(min, math.min(mid, max)) end
local MIN_STEP_SIZE = 1 / 512

--
-- Incrementally moves walker along its preloaded path. Actual distance travelled may not be exactly
-- constant; any distance remaining will be rolled over on the following call to :update().
--
function GraphWalker:update()
  local pxThisStep = -self.rolloverPxNextStep
  while self.path and pxThisStep < self.pxPerStep - MIN_STEP_SIZE do
    local onDestEdge = self.path.start.edge == self.path.dest.edge
    local edgeLength = self.graph:lengthOfEdge(self.path.start.edge)
    local direction = self.path:getDirectionToNextNode()
    local projectStepDist = (self.pxPerStep - pxThisStep) * direction

    local actualNextDist
    local reachedDest = false
    
    -- Check if we're going to step over the destination
    if onDestEdge and math.abs(projectStepDist) >= math.abs(self.path.dest.dist - self.path.start.dist) then
      actualNextDist = self.path.dest.dist
      reachedDest = true
    else
      actualNextDist = clamp(0, self.path.start.dist + projectStepDist, edgeLength)
    end
    
    local actualStepDist = actualNextDist - self.path.start.dist
    pxThisStep = pxThisStep + math.abs(actualStepDist)
    
    local actualNextEdge = self.path.start.edge
    local changedEdges = false

    -- Relocate to next edge, update path and self location.
    if not onDestEdge and (actualNextDist == 0 or actualNextDist == edgeLength) then

      -- Assume both not nil. Only time they'd be nil if we're on same edge as destination.
      local nextEdge = self.graph.edges[self.path:getNextEdge()]
      local nextNode = self.path:getNextNode()
      if nextEdge.to == nextNode then
        actualNextDist = self.graph:lengthOfEdge(nextEdge.id)
      else
        actualNextDist = 0
      end
      actualNextEdge = nextEdge.id
      changedEdges = true
    end

    self.path:setStart(actualNextEdge, actualNextDist)
    self.location.edgeId = actualNextEdge
    self.location.dist = actualNextDist

    if reachedDest then
      self.pxPerStep = 0
      if self.destReachedListener then
        self.destReachedListener.callback(self.destReachedListener.listener)
      end
    end
    if changedEdges then
      if self.edgeChangeListener then
        self.edgeChangeListener.callback(self.edgeChangeListener.listener)
      end
    end
  end
  
  self.rolloverPxNextStep = math.min(0, self.pxPerStep - pxThisStep)
end

return GraphWalker