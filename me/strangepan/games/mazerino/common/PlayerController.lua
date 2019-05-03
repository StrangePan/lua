local class = require "me.strangepan.libs.lua.v1.class"
local type = require "me.strangepan.games.mazerino.common.strangepan.util.type"
local Player = require "me.strangepan.games.mazerino.common.entities.Player"
local Direction = require "me.strangepan.games.mazerino.common.entities.Direction"

local PlayerController = class.build()

function PlayerController:_init(player)
  self:setPlayer(player)
end

function PlayerController:setPlayer(player)
  if player then
    assertClass(player, Player, "player")
  end

  self.player = player
end

function PlayerController:getPlayer()
  return self.player
end

function PlayerController:moveUp()
  return self:move(Direction.UP)
end

function PlayerController:moveRight()
  return self:move(Direction.RIGHT)
end

function PlayerController:moveDown()
  return self:move(Direction.DOWN)
end

function PlayerController:moveLeft()
  return self:move(Direction.LEFT)
end

function PlayerController:move(direction)
  direction = Direction.fromId(direction)
  if direction == nil then return false end
  if not self:getPlayer() then return false end
  return self:getPlayer():move(direction)
end

function PlayerController:emoteSpin()
  if not self:getPlayer() then return false end
  return self:getPlayer():spin()
end

return PlayerController
