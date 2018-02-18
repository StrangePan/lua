local class = require 'strangepan.lua.class'

local move = class.build()

local function _do_move(turtleFunc, times)
  local count = 0
  times = times or 1
  for i = 1,times do
    if turtleFunc() then
      count = count + 1
    end
  end
  return count
end

function move:forward(blocks)
  return self, _do_move(turtle.forward, blocks)
end

function move:backward(blocks)
  return self, _do_move(turtle.back, blocks)
end

function move:up(blocks)
  return self, _do_move(turtle.up, blocks)
end

function move:down(blocks)
  return self, _do_move(turtle.down, blocks)
end

function move:left(turns)
  return self, _do_move(turtle.turnLeft, turns)
end

function move:right(turns)
  return self, _do_move(turtle.turnRight, turns)
end

return move
