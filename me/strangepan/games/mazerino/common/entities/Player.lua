require "me.strangepan.games.mazerino.common.entities.Actor"

Player = buildClass(Actor)

function Player:_init()
  Player.superclass._init(self)
end
