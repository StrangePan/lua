package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "Player"
require "Wall"
require "ClientGame"
require "ClientConnectionManager"
require "CustomNetworkedEntityManager"

local connection

function love.load()
  local connection = ClientConnectionManager()
  
  game = ClientGame(
      LoveSecretary():captureLoveEvents(),
      connection,
      CustomNetworkedEntityManager(connection))
  game:start()
end
