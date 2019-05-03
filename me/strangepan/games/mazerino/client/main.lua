local ClientConnectionManager = require "me.strangepan.games.mazerino.client.ClientConnectionManager"
local ClientGame = require "me.strangepan.games.mazerino.client.ClientGame"
local ClientNetworkedEntityManager = require "me.strangepan.games.mazerino.client.ClientNetworkedEntityManager"
local Player = require "me.strangepan.games.mazerino.common.entities.Player"
local Wall = require "me.strangepan.games.mazerino.common.entities.Wall"
local LoveSecretary = require "me.strangepan.games.mazerino.common.strangepan.secretary.LoveSecretary"

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
