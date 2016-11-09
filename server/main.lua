package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "ServerGame"
require "NetworkedEntityType"
require "ServerConnectionManager"
require "ServerNetworkedEntityManager"

function love.load()
  local secretary = LoveSecretary()
      :captureLoveEvents()
  local connection = ServerConnectionManager()
  local entityManager = ServerNetworkedEntityManager(connection)
      :registerWithSecretary(secretary)
  local game = ServerGame(secretary, connection, entityManager)
      :start()
end
