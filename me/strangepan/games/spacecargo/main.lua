package.path = package.path .. ';libs\\rxlua\\?.lua;libs\\rxlove\\?.lua'
require 'libs.rxlove.rx-love'

local SpaceShip = require 'me.strangepan.games.spacecargo.objects.space_ship'

love.draw:subscribe(function()
  love.graphics.printf(
      'this was a triumph',
      0,
      love.graphics.getHeight() / 2,
      love.graphics.getWidth(),
      'center')
end)

local space_ship = SpaceShip()

love.quit:subscribe(function() space_ship:destroy() end)

love.keypressed
    :filter(function(key) return key == 'backspace' end)
    :subscribe(function() space_ship:destroy() end)
