require "priorityqueue"

local graph = {
  nextNode = 1,
  nodes = {},
  nextEdge = 1,
  edges = {},
}

function graph:addNode(x, y)
  assert(type(x) == "number")
  assert(type(y) == "number")

  local nodeId = self.nextNode
  self.nextNode = self.nextNode + 1
  self.nodes[nodeId] = {
    id = nodeId,
    x = x,
    y = y,
    edges = {}
  }

  return nodeId
end

function graph:addEdge(from, to, weight)
  weight = weight or 1
  assert(type(from) == "number")
  assert(self.nodes[from])
  assert(type(to) == "number" and self.nodes[to])
  assert(self.nodes[to])
  assert(type(weight) == "number")
  assert(from ~= to)

  -- see if edge already exists and update it if it does
  for _,edgeId in ipairs(self.nodes[from].edges) do
    local edge = self.edges[edgeId]
    if edge.from == to or edge.to == to then
      edge.weight = weight
      return
    end
  end

  -- add edge if it doesn't already exist
  local edgeId = self.nextEdge
  self.nextEdge = self.nextEdge + 1
  self.edges[edgeId] = {
    id = edgeId,
    from = from,
    to = to,
    weight = weight,
  }
  
  table.insert(self.nodes[from].edges, edgeId)
  table.insert(self.nodes[to].edges, edgeId)
end

function graph:pointOnEdge(edgeId, dist)
  assert(type(edgeId) == "number")
  assert(self.edges[edgeId])
  assert(type(dist) == "number")
  assert(dist >= 0 and dist <= self:lengthOfEdge(edgeId))
  local edge = self.edges[edgeId]
  local from = self.nodes[edge.from]
  local to = self.nodes[edge.to]
  local percentage = self:percentageAlongEdge(edgeId, dist)
  return {
    x = from.x + percentage * (to.x - from.x),
    y = from.y + percentage * (to.y - from.y),
  }
end

function graph:angleOfEdge(edgeId)
  assert(type(edgeId) == 'number')
  assert(self.edges[edgeId])
  local edge = self.edges[edgeId]
  local from = self.nodes[edge.from]
  local to = self.nodes[edge.to]
  local angle = math.atan2(to.y - from.y, to.x - from.x)
  while angle < 0 do
    angle = angle + math.pi * 2
  end
  return angle
end

function graph:lengthOfEdge(edgeId)
  assert(type(edgeId) == 'number')
  assert(self.edges[edgeId])
  local edge = self.edges[edgeId]
  if not edge.length then
    local dx = self.nodes[edge.from].x - self.nodes[edge.to].x
    local dy = self.nodes[edge.from].y - self.nodes[edge.to].y
    edge.length = math.sqrt(dx * dx + dy * dy)
  end
  return edge.length
end

function graph:percentageAlongEdge(edgeId, dist)
  assert(type(edgeId) == 'number')
  assert(type(dist) == 'number')
  return dist / self:lengthOfEdge(edgeId)
end

-- Get edge connecting nodes with IDs from and to. Returns nil if none exist.
function graph:edgeBetweenNodes(from, to)
  assert(type(from) == 'number')
  assert(self.nodes[from])
  assert(type(to) == 'number')
  assert(self.nodes[to])
  for _,edgeId in ipairs(self.nodes[from].edges) do
    local edge = self.edges[edgeId]
    if edge.from == to or edge.to == to then
      return edge
    end
  end
end

-- from: ID of starting edge
-- fromDist: percentage [0-1] along starting edge
-- to: ID of destination edge
-- toDist: percentage [0-1] along destination edge
--
-- Returns:
-- 1. table of node IDs between starting and ending edge, or nil if no path exists
function graph:findPath(from, fromDist, to, toDist)
  assert(type(from) == 'number')
  assert(self.edges[from])
  assert(type(fromDist) == 'number')
  assert(fromDist >= 0 and fromDist <= self:lengthOfEdge(from))
  assert(type(to) == 'number')
  assert(self.edges[to])
  assert(type(toDist) == 'number')
  assert(toDist >= 0 and toDist <= self:lengthOfEdge(to))
  
  -- Short-circuit if both points exist on same edge.
  -- Assumes that shorter, cheaper path doesn't exist.
  if from == to then
    return {}, 0
  end
  
  -- Manahattan distance heuristic
  local heuristic = function(from, to)
    return math.floor(math.abs(from.x - to.x)) + math.floor(math.abs(from.y - to.y))
  end
  local realcost = function(edge)
    return self:lengthOfEdge(edge.id) * edge.weight
  end
  
  local queue = PriorityQueue()
  local tStart = love.timer.getTime()
  
  
  -- Set up tracking data
  local startId = from
  local startEdge = self.edges[startId]
  local startCoords = self:pointOnEdge(startId, fromDist)
  local endId = to
  local endEdge = self.edges[endId]
  local endCoords = self:pointOnEdge(endId, toDist)
  local visited = {}
  visited[startEdge.from] = {
    -- running real cost from start
    cost = realcost(startEdge) * self:percentageAlongEdge(from, fromDist),
    from = nil, -- previous node
  }
  queue:push({
        id = startEdge.from,
        cost = visited[startEdge.from].cost,
      }, visited[startEdge.from].cost + heuristic(self.nodes[startEdge.from], endCoords))
  visited[startEdge.to] = {
    -- running real cost from start
    cost = realcost(startEdge) * (1-self:percentageAlongEdge(from, fromDist)),
    from = nil, -- previous node
  }
  queue:push({
        id = startEdge.to,
        cost = visited[startEdge.to].cost,
      }, visited[startEdge.to].cost + heuristic(self.nodes[startEdge.to], endCoords))

  while queue.size > 0 and not visited[endEdge.from] and not visited[endEdge.to] do
    local cur = queue:pop()
    if cur.cost < visited[cur.id].cost or not visited[cur.id].processed then
      for _,edgeId in ipairs(self.nodes[cur.id].edges) do
        local edge = self.edges[edgeId]
        local nextId = edge.from
        if nextId == cur.id then
          nextId = edge.to
        end
        local nextCost = visited[cur.id].cost + realcost(edge)
        if not visited[nextId] or visited[nextId].cost > nextCost then
          visited[nextId] = {cost = nextCost, from = cur.id}
          queue:push({
                id = nextId,
                cost = nextCost
            }, nextCost + heuristic(self.nodes[nextId], endCoords))
        end
      end
      visited[cur.id].processed = true
    end
  end
  
  -- check if found end, build node list connecting two points
  local path
  if visited[endEdge.from] or visited[endEdge.to] then
    path = {}
    
    -- Choose cheapest entry point to edge
    local curId = endEdge.from
    local toPercent = self:percentageAlongEdge(to, toDist)
    if not visited[endEdge.from]
        or (visited[endEdge.to]
            and visited[endEdge.to].cost + realcost(endEdge) * (1-toPercent)
                < visited[endEdge.from].cost + realcost(endEdge) * toPercent) then
      curId = endEdge.to
    end
    
    repeat
      table.insert(path, 1, curId)
      curId = visited[curId].from
    until not curId --== nil
  else
    path = nil
  end
  
  local tEnd = love.timer.getTime()
  local tTotal = tEnd - tStart
  print("A* runtime: "..tTotal)
  
  return path
end

function graph:draw()
  local drawPass = function(lineThickness)
    love.graphics.setLineWidth(lineThickness)
    for _,edge in ipairs(self.edges) do
      local from = self.nodes[edge.from]
      local to = self.nodes[edge.to]
      love.graphics.line(from.x, from.y, to.x, to.y)
    end
    local circleRadius = lineThickness / 2
    for _,node in ipairs(self.nodes) do
      if node.id == self.selectedNode then
        love.graphics.ellipse('fill', node.x, node.y, circleRadius * 2, circleRadius * 2)
      else
        love.graphics.ellipse('fill', node.x, node.y, circleRadius, circleRadius)
      end
    end
  end
  
  love.graphics.setColor(255, 255, 255)
  drawPass(12)
  love.graphics.setColor(127, 127, 127)
  drawPass(6)
end

return graph
