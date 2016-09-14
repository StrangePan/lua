require "config"
require "Secretary"
require "Player"

rootSecretary = Secretary()

require "loveevents"

function love.load()
  player = Player():registerWithSecretary(rootSecretary)
end
