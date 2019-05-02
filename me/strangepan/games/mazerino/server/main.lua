require "me.strangepan.games.mazerino.common.networking.NetworkedEntityType"
require "me.strangepan.games.mazerino.common.strangepan.secretary.LoveSecretary"
require "me.strangepan.games.mazerino.server.ServerConnectionManager"
require "me.strangepan.games.mazerino.server.ServerGame"
require "me.strangepan.games.mazerino.server.ServerNetworkedEntityManager"

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
