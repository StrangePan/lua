package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "Player"
require "Wall"
require "ClientGame"
require "ClientConnectionManager"
require "CustomNetworkedEntityManager"

local connection

function love.load()
  local secretary = LoveSecretary()
      :captureLoveEvents()
  local connection = ClientConnectionManager()
  local entityManager = CustomNetworkedEntityManager(connection)
      :registerWithSecretary(secretary)
  local game = ClientGame(secretary, connection, entityManager)
      :start()
end
