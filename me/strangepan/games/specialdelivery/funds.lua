local mainFont = require "me.strangepan.games.specialdelivery.font"

local funds = {
  cash = 0,
  drawable = love.graphics.newText(mainFont, "$0")
}

local refreshDrawables = function()
  funds.drawable:set('$'..funds.cash)
end

function funds.add(amount)
  assert(type(amount) == "number")
  funds.cash = funds.cash + amount
  refreshDrawables()
  return funds.cash
end

function funds.subtract(amount)
  assert(type(amount) == "number")
  funds.cash = funds.cash - amount
  refreshDrawables()
  return funds.cash
end

function funds.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(funds.drawable, 4, 4)
end

return funds
