package.path = package.path .. ';libs\\rxlua\\?.lua;libs\\rxlove\\?.lua'
require 'libs.rxlove.rx-love'

local function on_draw()
  love.graphics.printf(
      'this was a triumph',
      0,
      love.graphics.getHeight() / 2,
      love.graphics.getWidth(),
      'center')
end

love.draw:subscribe(on_draw)
