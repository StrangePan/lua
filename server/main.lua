package.path = package.path .. ";./common/?.lua"

require "Secretary"
require "ServerConnectionManager"
require "EntityConnectionManager"

rootSecretary = Secretary()

require "loveevents"

local connection

function love.load()
  connection = ServerConnectionManager()
  EntityConnectionManager(connection):registerWithSecretary(rootSecretary)
end
