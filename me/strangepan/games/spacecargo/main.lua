package.path = package.path .. ';libs\\rxlua\\?.lua;libs\\rxlove\\?.lua'
require 'libs.rxlove.rx-love'
local Rx = require 'libs.rxlua.rx'
local Smoke = require 'me.strangepan.games.spacecargo.particles.smoke'
local Vector = require 'me.strangepan.games.spacecargo.util.vector'

local SpaceShip = require 'me.strangepan.games.spacecargo.objects.space_ship'
local scheduler = Rx.CooperativeScheduler.create()

love.update:subscribe(function(dt) scheduler:update(dt) end)

love.draw:subscribe(function()
  love.graphics.printf(
      'this was a triumph',
      0,
      love.graphics.getHeight() / 2 - 100,
      love.graphics.getWidth(),
      'center')
end)

love.update:subscribe(function(dt)
  Smoke(Vector(10, 10), Vector(100, 100))
end)

local space_ship = SpaceShip()

love.quit:subscribe(function() space_ship:destroy() end)

love.keypressed
    :filter(function(key) return key == 'backspace' end)
    :subscribe(function() space_ship:destroy() end)
