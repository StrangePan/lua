require "me.strangepan.games.mazerino.client.ClientConnectionManager"
require "me.strangepan.games.mazerino.client.ClientGame"
require "me.strangepan.games.mazerino.client.ClientNetworkedEntityManager"
require "me.strangepan.games.mazerino.common.entities.Player"
require "me.strangepan.games.mazerino.common.entities.Wall"
require "me.strangepan.games.mazerino.common.strangepan.secretary.LoveSecretary"

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
