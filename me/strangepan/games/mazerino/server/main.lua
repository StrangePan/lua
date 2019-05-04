local EventType = require "me.strangepan.games.mazerino.common.strangepan.secretary.EventType"
local LoveSecretary = require "me.strangepan.games.mazerino.common.strangepan.secretary.LoveSecretary"
local ServerConnectionManager = require "me.strangepan.games.mazerino.server.ServerConnectionManager"
local ServerGame = require "me.strangepan.games.mazerino.server.ServerGame"
local ServerNetworkedEntityManager = require "me.strangepan.games.mazerino.server.ServerNetworkedEntityManager"
local NetworkedEntityType = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityType"
local NetworkedEntity = require "me.strangepan.games.mazerino.common.networking.NetworkedEntity"

function love.load()
  local secretary = LoveSecretary()
      :captureLoveEvents()
  local connection = ServerConnectionManager()
  local entityManager = ServerNetworkedEntityManager(connection)
      :registerWithSecretary(secretary)

  NetworkedEntity.registerEntityType(
      NetworkedEntityType.ACTOR,
      require "me.strangepan.games.mazerino.common.networking.NetworkedActor")
  NetworkedEntity.registerEntityType(
      NetworkedEntityType.PLAYER,
      require "me.strangepan.games.mazerino.common.networking.NetworkedPlayer")
  NetworkedEntity.registerEntityType(
      NetworkedEntityType.WALL,
      require "me.strangepan.games.mazerino.common.networking.NetworkedWall")

  ServerGame(secretary, connection, entityManager):start()

  secretary:registerEventListener(
      connection.passer,
      connection.passer.releaseMessageBundle,
      EventType.POST_STEP)
  secretary:registerEventListener(
      connection.passer,
      connection.passer.releaseMessageBundle,
      EventType.SHUTDOWN)
end
