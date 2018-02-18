package.path = package.path..";../common/?.lua"

require "strangepan.secretary.LoveSecretary"
require "entities.Player"
require "entities.Wall"
require "OfflineGame"

function love.load()
  local secretary = LoveSecretary():captureLoveEvents()
  local game = OfflineGame(secretary):start()
end
