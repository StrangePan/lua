package.path = package.path .. ";./common/?.lua"

require "LoveSecretary"
require "ServerConnectionManager"
require "EntityConnectionManager"

function love.load()
  local rootSecretary = LoveSecretary():captureLoveEvents()
  local connection = ServerConnectionManager()
  EntityConnectionManager(connection):registerWithSecretary(rootSecretary)
end
