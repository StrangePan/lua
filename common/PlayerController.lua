require "common/class"
require "common/functions"
require "Player"
require "Direction"

PlayerController = buildClass()
local Class = PlayerController

function PlayerController:_init(player)
  self:setPlayer(player)
end

function Class:setPlayer(player)
  if player ~= nil then
    assertType(player, "player", Player)
  end
  
  if self.player ~= nil then
    self.player = nil
  end
  
  if player ~= nil then
    self.player = player
  end
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
  if self:isBoundToPlayer() == false then return false end
  return self.player:move(direction)
end

function Class:emoteSpin()
  if self:isBoundToPlayer() == false then return false end
  return self.player:spin()
end
