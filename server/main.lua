package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "ServerConnectionManager"
require "CustomNetworkedEntityManager"

function love.load()
  rootSecretary = LoveSecretary():captureLoveEvents()
  connection = ServerConnectionManager()
  entityManager = CustomNetworkedEntityManager(connection):registerWithSecretary(rootSecretary)
  
  rootSecretary:registerEventListener(
    connection,
    connection.receiveAllMessages,
    EventType.PRE_STEP)
  rootSecretary:registerEventListener(
    connection,
    connection.terminateAllConnections,
    EventType.SHUTDOWN)
end
