local ClientConnectionManager = require "me.strangepan.games.mazerino.client.ClientConnectionManager"
local ClientGame = require "me.strangepan.games.mazerino.client.ClientGame"
local ClientNetworkedEntityManager = require "me.strangepan.games.mazerino.client.ClientNetworkedEntityManager"
local LoveSecretary = require "me.strangepan.games.mazerino.common.strangepan.secretary.LoveSecretary"
local EventType = require "me.strangepan.games.mazerino.common.strangepan.secretary.EventType"
local NetworkedEntity = require "me.strangepan.games.mazerino.common.networking.NetworkedEntity"
local NetworkedEntityType = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityType"

function love.load()
  local secretary = LoveSecretary()
      :captureLoveEvents()
  local connection = ClientConnectionManager()
  local entityManager = ClientNetworkedEntityManager(connection)
      :registerWithSecretary(secretary)
  ClientGame(secretary, connection, entityManager):start()

  secretary:registerEventListener(
      connection.passer,
      connection.passer.releaseMessageBundle,
      EventType.POST_STEP)
  secretary:registerEventListener(
      connection.passer,
      connection.passer.releaseMessageBundle,
      EventType.SHUTDOWN)

  NetworkedEntity.registerEntityType(
      NetworkedEntityType.ACTOR,
      require "me.strangepan.games.mazerino.common.networking.NetworkedActor")
  NetworkedEntity.registerEntityType(
      NetworkedEntityType.PLAYER,
      require "me.strangepan.games.mazerino.common.networking.NetworkedPlayer")
  NetworkedEntity.registerEntityType(
      NetworkedEntityType.WALL,
      require "me.strangepan.games.mazerino.common.networking.NetworkedWall")
end
