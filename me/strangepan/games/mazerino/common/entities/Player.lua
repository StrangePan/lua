local Actor = require "me.strangepan.games.mazerino.common.entities.Actor"
local class = require "me.strangepan.libs.util.v1.class"

local Player = class.build(Actor)

function Player:_init()
  Actor._init(self)
end

return Player
