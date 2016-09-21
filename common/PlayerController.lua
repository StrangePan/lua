require "common/class"
require "common/functions"
require "Player"
require "Direction"

PlayerController = buildClass()

function PlayerController:_init(player)
  self:setPlayer(player)
end

function LocalPlayerController:setPlayer(player)
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

function LocalPlayerController:moveUp()
  return self:move(Direction.UP)
end

function LocalPlayerController:moveRight()
  return self:move(Direction.RIGHT)
end

function LocalPlayerController:moveDown()
  return self:move(Direction.DOWN)
end

function LocalPlayerController:moveLeft()
  return self:move(Direction.LEFT)
end

function LocalPlayerController:move(direction)
  direction = Direction.fromId(direction)
  if direction == nil then return false end
  if self:isBoundToPlayer() == false then return false end
  return self.player:move(direction)
end

function LocalPlayerController:emoteSpin()
  if self:isBoundToPlayer() == false then return false end
  return self.player:spin()
end
