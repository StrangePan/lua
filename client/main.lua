package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "Player"
require "Wall"
require "ClientGame"
require "ClientConnectionManager"
require "ClientNetworkedEntityManager"

local connection

function love.load()
  local secretary = LoveSecretary()
      :captureLoveEvents()
  local connection = ClientConnectionManager()
  local entityManager = ClientNetworkedEntityManager(connection)
      :registerWithSecretary(secretary)
  local game = ClientGame(secretary, connection, entityManager)
      :start()

  secretary:registerEventListener(
      connection.passer,
      connection.passer.releaseMessageBundle,
      EventType.POST_STEP)
  secretary:registerEventListener(
      connection.passer,
      connection.passer.releaseMessageBundle,
      EventType.SHUTDOWN)
end
