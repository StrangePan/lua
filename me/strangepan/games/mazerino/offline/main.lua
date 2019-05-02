require "me.strangepan.games.mazerino.common.entities.Player"
require "me.strangepan.games.mazerino.common.entities.Wall"
require "me.strangepan.games.mazerino.common.strangepan.secretary.LoveSecretary"
require "me.strangepan.games.mazerino.offline.OfflineGame"

function love.load()
  local secretary = LoveSecretary():captureLoveEvents()
  local game = OfflineGame(secretary):start()
end
