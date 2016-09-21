package.path = package.path .. ";./common/?.lua"

require "Secretary"
require "Player"
require "Wall"
require "Camera"
require "ClientConnection"

rootSecretary = Secretary()

require "loveevents"

local connection = ClientConnection()

function love.load()
  camera = Camera():registerWithSecretary(rootSecretary)
  player = Player():registerWithSecretary(rootSecretary)
  buildWalls()
  
  rootSecretary:registerEventListener({}, function()
      local px, py = player:getPosition()
      local pw, ph = player:getSize()
      camera:moveTo(px+(pw/2), py+(ph/2))
    end, EventType.STEP)
  
  rootSecretary:registerEventListener({}, function()
      connection:processIncomingMessages()
    end, EventType.STEP)
end

function buildWalls()
  local wallCodes = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  }
  
  for wallY,row in ipairs(wallCodes) do
    for wallX,wallCode in ipairs(row) do
      if wallCode == 1 then
        local newWall = Wall()
        newWall:setPosition((wallX - 1) * 32, (wallY - 1) * 32)
        newWall:registerWithSecretary(rootSecretary)
      end
    end
  end
end
