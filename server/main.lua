package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "ServerConnectionManager"
require "CustomNetworkedEntityManager"

function love.load()
  local rootSecretary = LoveSecretary():captureLoveEvents()
  local connection = ServerConnectionManager()
  CustomNetworkedEntityManager(connection):registerWithSecretary(rootSecretary)
end
