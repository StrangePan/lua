package.path = package.path .. ";./common/?.lua"

require "ServerConnection"

local connection

function love.load()
  connection = ServerConnection()
end

function love.update(dt)
  connection:update()
end