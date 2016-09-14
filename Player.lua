require "common/class"

Player = buildClass(Entity)
Player.BOX_WIDTH = 32
Player.BOX_HEIGHT = 32
Player.X_STEP = 32
Player.Y_STEP = 32

function Player:_init()
  -- Optional constructor
  self.x = Player.BOX_WIDTH
  self.y = Player.BOX_HEIGHT
  
  self.width = Player.BOX_WIDTH
  self.height = Player.BOX_HEIGHT
  
  self.xStep = Player.X_STEP
  self.yStep = Player.Y_STEP
end

function Player:registerWithSecretary(secretary)
  Player.superclass:registerWithSecretary(secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onKeyPress, EventType.KEYBOARD_DOWN)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
end

function Player:onKeyPress(key, scancode, isrepeat)
  if key == "up" then
    self.y = self.y - self.yStep
  elseif key == "right" then
    self.x = self.x + self.xStep
  elseif key == "down" then
    self.y = self.y + self.yStep
  elseif key == "left" then
    self.x = self.x - self.xStep
  end
end

function Player:draw()
  love.graphics.setColor(63, 63, 255)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
