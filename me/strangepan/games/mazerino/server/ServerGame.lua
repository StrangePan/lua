local NetworkGame = require "me.strangepan.games.mazerino.common.NetworkGame"
local NetworkedEntityType = require "me.strangepan.games.mazerino.common.networking.NetworkedEntityType"
local ServerConnectionManager = require "me.strangepan.games.mazerino.server.ServerConnectionManager"
local ServerNetworkedEntityManager = require "me.strangepan.games.mazerino.server.ServerNetworkedEntityManager"
local class = require "me.strangepan.libs.util.v1.class"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local ConnectionStatus = require "me.strangepan.games.mazerino.common.networking.ConnectionStatus"

local ServerGame = class.build(NetworkGame)

function ServerGame:_init(secretary, connectionManager, entityManager)
  NetworkGame._init(self, secretary, connectionManager, entityManager)
  assert_that(connectionManager):is_instance_of(ServerConnectionManager):and_return()
  assert_that(entityManager):is_instance_of(ServerNetworkedEntityManager):and_return()

  -- Register for network callbacks
  local connections = self:getConnectionManager()
  connections:registerConnectionStatusListener(
      self,
      self.onConnectionStatusChanged)

  -- Connected players
  self.players = {}
end

function ServerGame:start()
  NetworkGame.start(self)
  self:buildWalls()
  return self
end

function ServerGame:onPlayerConnected(connectionId)
  if self.players[connectionId] then
    return
  end
  
  -- Add connection to entityManager.
  local entityManager = self:getEntityManager()
  entityManager:addConnection(connectionId)

  -- Assign new player a spawn location.
  local spawnX = 2
  local spawnY = 2

  -- Create player entity.
  local entity = entityManager:spawnEntity(
      NetworkedEntityType.PLAYER,
      connectionId,
      spawnX,
      spawnY)

  self.players[connectionId] = {
    id = connectionId,
    entity = entity
  }
end

function ServerGame:onPlayerDisconnected(connectionId)
  local player = self.players[connectionId]
  if not player then
    return
  end

  -- Remove connection from entityManager.
  local entityManager = self:getEntityManager()
  entityManager:removeConnection(connectionId)

  -- Notify other players of disconnect and clean up player.
  player.entity:delete()
end

--
-- Handles a change in connection status.
--
function ServerGame:onConnectionStatusChanged(manager, connectionId, oldStatus)
  local connections = self:getConnectionManager()
  local connection = connections:getConnection(connectionId)
  if not connection then
    return
  end
  
  -- Give local player control when connected
  if connection.status == ConnectionStatus.CONNECTED
      and oldStatus ~= ConnectionStatus.STALLED then
    self:onPlayerConnected(connectionId)
  elseif connection.status == ConnectionStatus.DISCONNECTED then
    self:onPlayerDisconnected(connectionId)
  end
end

--
-- Constructs the level map
--
function ServerGame:buildWalls()
  local wallCodes = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  }

  local entityManager = self:getEntityManager()
  for wallY,row in ipairs(wallCodes) do
    for wallX,wallCode in ipairs(row) do
      if wallCode == 1 then
        entityManager:spawnEntity(NetworkedEntityType.WALL, (wallX - 1), (wallY - 1))
      end
    end
  end
end

return ServerGame
