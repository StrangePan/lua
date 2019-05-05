local class = require "me.strangepan.libs.lua.v1.class"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"
local Player = require "me.strangepan.games.mazerino.common.entities.Player"
local Direction = require "me.strangepan.games.mazerino.common.entities.Direction"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

local PlayerController = class.build()

function PlayerController:_init(player)
  self:setPlayer(player)
end

function PlayerController:setPlayer(player)
  if player then
    assert_that(player):is_instance_of(Player):and_return()
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
  direction = assert_that(direction):is_a_number():is_a_key_in(Direction):and_return()
  if direction == nil then return false end
  if not self:getPlayer() then return false end
  return self:getPlayer():move(direction)
end

function PlayerController:emoteSpin()
  if not self:getPlayer() then return false end
  return self:getPlayer():spin()
end

return PlayerController
