require "Game"
require "ServerConnectionManager"
require "ServerNetworkedEntityManager"
require "NetworkedEntityType"

ServerGame = buildClass(Game)
local Class = ServerGame

function Class:_init(secretary, connectionManager, entityManager)
  Class.superclass._init(self, secretary, connectionManager, entityManager)
  assertType(connectionManager, ServerConnectionManager)
  assertType(entityManager, ServerNetworkedEntityManager)
end

function Class:start()
  Class.superclass.start(self)
  self:buildWalls()
  return self
end

function Class:buildWalls()
  local entityManager = self:getEntityManager()
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
