require "font"
require "funds"

gameGraph = require "graph"
require "van"
require "delivery"
require "van2"

vans = {}
delivery = nil
selectedVan = nil
walkerVan = nil

function love.load()
  local gg = gameGraph
  gg:addNode(100, 100)
  gg:addNode(133, 100)
  gg:addNode(166, 100)
  gg:addNode(200, 100)
  gg:addNode(117, 200)
  gg:addNode(150, 225)
  gg:addNode(200, 150) --7
  
  gg:addEdge(1, 2)
  gg:addEdge(2, 3)
  gg:addEdge(3, 4)
  gg:addEdge(1, 5)
  gg:addEdge(5, 6)
  gg:addEdge(6, 3)
  gg:addEdge(6, 2)
  gg:addEdge(6, 7)
  gg:addEdge(7, 4)
  
  gg:addNode(300, 100)
  gg:addNode(400, 100)
  gg:addEdge(9, 8)
  gg:addNode(500, 100)
  gg:addEdge(10, 9)
  gg:addNode(600, 100)
  gg:addEdge(11, 10)
  gg:addNode(700, 100)
  gg:addEdge(12, 11)
  gg:addNode(300, 200)
  gg:addEdge(13, 8)
  gg:addEdge(13, 7)
  gg:addNode(400, 200)
  gg:addEdge(14, 13)
  gg:addEdge(14, 9)
  gg:addNode(500, 200)
  gg:addEdge(15, 14)
  gg:addEdge(15, 10)
  gg:addNode(600, 200)
  gg:addEdge(16, 15)
  gg:addEdge(16, 11)
  gg:addNode(700, 200)
  gg:addEdge(17, 16)
  gg:addEdge(17, 12)
  gg:addNode(300, 300)
  gg:addEdge(18, 13)
  gg:addNode(400, 300)
  gg:addEdge(19, 18)
  gg:addEdge(19, 14)
  gg:addNode(500, 300)
  gg:addEdge(20, 19)
  gg:addEdge(20, 15)
  gg:addNode(600, 300)
  gg:addEdge(21, 20)
  gg:addEdge(21, 16)
  gg:addNode(700, 300)
  gg:addEdge(22, 21)
  gg:addEdge(22, 17)
  
  gg:addNode(400, 500)
  gg:addEdge(23, 20)
  
  math.randomseed(os.time())
end

function love.keypressed(key)
  if key == "space" then
    funds.add(1)
  elseif key == "escape" then
    love.event.quit()
  elseif key == "return" then
    local startId = math.random(#gameGraph.edges)
    local startDist = math.random() * gameGraph:lengthOfEdge(startId)
    local endId = math.random(#gameGraph.edges-1)
    local endDist = math.random() * gameGraph:lengthOfEdge(endId)
    if endId >= startId then
      endId = endId + 1
    end
    delivery = Delivery(startId, startDist, endId, endDist)
    if walkerVan then
      walkerVan:destroy()
    end
    walkerVan = Van2(delivery.path)
  elseif key == "1" then
    print("made van")
    local edge = math.random(#gameGraph.edges)
    local van = Van(edge, math.random() * gameGraph:lengthOfEdge(edge))
    if math.random(2) == 1 then
      van.direction = -1
    end
    table.insert(vans, van)
  elseif key == "2" then
    table.remove(vans)
  elseif key == "3" then
    for _,van in ipairs(vans) do
      van.location.edgeId = math.random(#gameGraph.edges)
      van.location.dist = math.random() * gameGraph:lengthOfEdge(van.location.edgeId)
      if math.random(2) == 1 then
        van.direction = -1
      else
        van.direction = 1
      end
    end
  elseif key == "up" then
    Van2.VAN_SPEED = Van2.VAN_SPEED + 5
    print("speed at "..Van2.VAN_SPEED.." px/sec")
  elseif key == "down" then
    Van2.VAN_SPEED = math.max(10, Van2.VAN_SPEED - 5)
    print("speed at "..Van2.VAN_SPEED.." px/sec")
  end
end

function love.mousepressed(x, y, button)
  for i,van in ipairs(vans) do
    if van:mousepressed(x, y, button) then
      selectedVan = i
      break
    end
  end
end

local frameTime = 0
function love.update(dt)
  while love.timer.getTime() - frameTime < 1/60 do end
  frameTime = love.timer.getTime()

  for _,van in ipairs(vans) do
    van:update()
  end
  if walkerVan then
    walkerVan:update()
  end
end

function love.draw()
  funds.draw()
  gameGraph:draw()
  
  if delivery then
    delivery:draw()
  end
  
  if selectedVan and vans[selectedVan] then
    local van = vans[selectedVan]
    local coords = gameGraph:pointOnEdge(van.location.edgeId, van.location.dist)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(3)
    love.graphics.ellipse("line", coords.x, coords.y, 18, 18)
  end
  
  for _,van in ipairs(vans) do
    van:draw()
  end

  if walkerVan then
    local van = walkerVan
    local coords = gameGraph:pointOnEdge(van.walker.location.edgeId, van.walker.location.dist)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(3)
    love.graphics.ellipse("line", coords.x, coords.y, 18, 18)
    walkerVan:draw()
  end
end
