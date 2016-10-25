package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "NetworkedEntityType"
require "ServerConnectionManager"
require "ServerNetworkedEntityManager"
require "Wall"

function love.load()
  rootSecretary = LoveSecretary():captureLoveEvents()
  connection = ServerConnectionManager()
  entityManager = ServerNetworkedEntityManager(connection):registerWithSecretary(rootSecretary)
  
  rootSecretary:registerEventListener(
    connection,
    connection.receiveAllMessages,
    EventType.PRE_STEP)
  rootSecretary:registerEventListener(
    connection,
    connection.terminateAllConnections,
    EventType.SHUTDOWN)
  
  buildWalls()
end

function buildWalls()
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
  
  for wallY,row in ipairs(wallCodes) do
    for wallX,wallCode in ipairs(row) do
      if wallCode == 1 then
        entityManager:spawnEntity(
            NetworkedEntityType.WALL,
            (wallX - 1) * 32,
            (wallY - 1) * 32)
      end
    end
  end
end
