require "me.strangepan.games.mazerino.common.strangepan.util.class"
require "me.strangepan.games.mazerino.common.strangepan.util.type"
require "me.strangepan.games.mazerino.common.entities.Player"
require "me.strangepan.games.mazerino.common.entities.Direction"

PlayerController = buildClass()
local Class = PlayerController

function PlayerController:_init(player)
  self:setPlayer(player)
end

function Class:setPlayer(player)
  if player then
    assertClass(player, Player, "player")
  end

  self.player = player
end

function Class:getPlayer()
  return self.player
end

function Class:moveUp()
  return self:move(Direction.UP)
end

function Class:moveRight()
  return self:move(Direction.RIGHT)
end

function Class:moveDown()
  return self:move(Direction.DOWN)
end

function Class:moveLeft()
  return self:move(Direction.LEFT)
end

function Class:move(direction)
  direction = Direction.fromId(direction)
  if direction == nil then return false end
  if not self:getPlayer() then return false end
  return self:getPlayer():move(direction)
end

function Class:emoteSpin()
  if not self:getPlayer() then return false end
  return self:getPlayer():spin()
end
