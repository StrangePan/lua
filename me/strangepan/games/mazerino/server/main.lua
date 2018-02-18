package.path = package.path..";../common/?.lua"

require "strangepan.secretary.LoveSecretary"
require "ServerGame"
require "networking.NetworkedEntityType"
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

  secretary:registerEventListener(
      connection.passer,
      connection.passer.releaseMessageBundle,
      EventType.POST_STEP)
  secretary:registerEventListener(
      connection.passer,
      connection.passer.releaseMessageBundle,
      EventType.SHUTDOWN)
end
