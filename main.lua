require "config"
require "Secretary"
require "Entity"

rootSecretary = Secretary()

require "loveevents"
require "Player"

function love.load()
  player = Player():registerWithSecretary(rootSecretary)
end
