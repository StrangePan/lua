local Player = require "me.strangepan.games.mazerino.common.entities.Player"
local Wall = require "me.strangepan.games.mazerino.common.entities.Wall"
local LoveSecretary = require "me.strangepan.libs.secretary.v1.LoveSecretary"
local OfflineGame = require "me.strangepan.games.mazerino.offline.OfflineGame"

function love.load()
  local secretary = LoveSecretary():captureLoveEvents()
  local game = OfflineGame(secretary):start()
end
