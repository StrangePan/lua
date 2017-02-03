package.path = package.path..";./common/?.lua;./common/entities/?.lua"

require "LoveSecretary"
require "Player"
require "Wall"
require "OfflineGame"

function love.load()
  local secretary = LoveSecretary():captureLoveEvents()
  local game = OfflineGame(secretary):start()
end
