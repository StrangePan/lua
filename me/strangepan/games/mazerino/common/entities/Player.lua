local Actor = require "me.strangepan.games.mazerino.common.entities.Actor"
local class = require "me.strangepan.libs.lua.v1.class"

local Player = class.build(Actor)

function Player:_init()
  class.superclass(Player)._init(self)
end

return Player
