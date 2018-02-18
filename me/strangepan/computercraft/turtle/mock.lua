local class = require 'strangepan.lua.class'

local _turtle = class.build()

local NORTH = 0
local EAST = 1
local SOUTH = 2
local WEST = 3
local x = 0
local y = 0
local z = 0
local d = NORTH

_turtle.verbose = false
_turtle.delay = 0.5

function _turtle._reset()
  x = 0
  y = 0
  z = 0
  d = NORTH
end

local function _do_boolean_action(action)
  if _turtle.verbose then
    local direction = (
        d == NORTH and 'NORTH'
        or d == EAST and 'EAST'
        or d == SOUTH and 'SOUTH'
        or d == WEST and 'WEST')
    print(action..'  ('..x..','..y..','..z..') '..direction)
    os.sleep(_turtle.delay)
  end
  return true
end

function _turtle.forward()
  if d == NORTH then
    z = z - 1
  elseif d == EAST then
    x = x + 1
  elseif d == SOUTH then
    z = z + 1
  else
    x = x - 1
  end
  return _do_boolean_action('forward')
end

function _turtle.back()
  if d == NORTH then
    z = z + 1
  elseif d == EAST then
    x = x - 1
  elseif d == SOUTH then
    z = z - 1
  else
    x = x + 1
  end
  return _do_boolean_action('back')
end

function _turtle.up()
  y = y + 1
  return _do_boolean_action('up')
end

function _turtle.down()
  y = y - 1
  return _do_boolean_action('down')
end

function _turtle.turnRight()
  d = d + 1
  while d > 3 do d = d - 4 end
  return _do_boolean_action('turnRight')
end

function _turtle.turnLeft()
  d = d - 1
  while d < 0 do d = d + 4 end
  return _do_boolean_action('turnLeft')
end

function _turtle.dig()
  return _do_boolean_action('dig')
end

function _turtle.digUp()
  return _do_boolean_action('digUp')
end

function _turtle.digDown()
  return _do_boolean_action('digDown')
end

function _turtle.mock()
  local didMock = false
  if not turtle then
    turtle = _turtle
    didMock = true
  end
  return didMock
end

return _turtle
