package.path = package.path .. ";./common/?.lua"

require "ServerConnectionManager"

local connection

function love.load()
  connection = ServerConnectionManager()
end

function love.update(dt)
  connection:update()
end

function love.quit()
  connection:onShutdown()
end
