package.path = package.path .. ";./common/?.lua"

require "ServerConnection"

local connection = ServerConnection()

function love.load()
end

function love.update(dt)
  connection:update()
end