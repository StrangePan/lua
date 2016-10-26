package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "Player"
require "Wall"
require "Camera"
require "ClientGame"
require "ClientConnectionManager"
require "CustomNetworkedEntityManager"

local connection

function love.load()
  rootSecretary = LoveSecretary():captureLoveEvents()
  camera = Camera():registerWithSecretary(rootSecretary)
  player = Player():registerWithSecretary(rootSecretary)
  
  rootSecretary:registerEventListener({}, function()
      local px, py = player:getPosition()
      local pw, ph = player:getSize()
      camera:moveTo(px+(pw/2), py+(ph/2))
    end, EventType.STEP)
    
  connection = ClientConnectionManager()
  entityManager = CustomNetworkedEntityManager(connection)  
  game = ClientGame(rootSecretary, connection, entityManager)
  game:run()
end
