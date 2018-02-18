local class = require 'me.strangepan.libs.lua.v1.class'

local mock_turtle = class.build()

local NORTH = 0
local EAST = 1
local SOUTH = 2
local WEST = 3

function mock_turtle:_init()
  self._x = 0
  self._y = 0
  self._z = 0
  self._d = NORTH

  self._verbose = false
  self._delay = 0.5
end

function mock_turtle:_do_boolean_action(action)
  if self._verbose then
    local direction = (
        self._d == NORTH and 'NORTH'
        or self._d == EAST and 'EAST'
        or self._d == SOUTH and 'SOUTH'
        or self._d == WEST and 'WEST')
    print(action..'  ('..self._x..','..self._y..','..self._z..') '..direction)
    os.sleep(turtle.delay)
  end
  return true
end

function mock_turtle:forward()
  if self._d == NORTH then
    self._z =self._z - 1
  elseif d == EAST then
    self._x = self._x + 1
  elseif d == SOUTH then
    self._z = self._z + 1
  else
    self._x = self._x - 1
  end
  return self:_do_boolean_action('forward')
end

function mock_turtle:back()
  if self._d == NORTH then
    self._z = self._z + 1
  elseif d == EAST then
    self._x = self._x - 1
  elseif d == SOUTH then
    self._z = self._z - 1
  else
    self._x = self._x + 1
  end
  return self:_do_boolean_action('back')
end

function mock_turtle:up()
  self._y = self._y + 1
  return self:_do_boolean_action('up')
end

function mock_turtle:down()
  self._y = self._y - 1
  return self:_do_boolean_action('down')
end

function mock_turtle:turnRight()
  self._d = self._d + 1
  while self._d > 3 do self._d = self._d - 4 end
  return self:_do_boolean_action('turnRight')
end

function mock_turtle:turnLeft()
  self._d = self._d - 1
  while self._d < 0 do self._d = self._d + 4 end
  return self:_do_boolean_action('turnLeft')
end

function mock_turtle:dig()
  return self:_do_boolean_action('dig')
end

function mock_turtle:digUp()
  return self:_do_boolean_action('digUp')
end

function mock_turtle:digDown()
  return self:_do_boolean_action('digDown')
end


-- Mocker

local mock_turtle_builder = {}

function mock_turtle_builder.build_mocks(current_turtle)
  if current_turtle then
    return current_turtle, false
  end
  local new_mock_turtle = mock_turtle()
  local new_turtle = {}
  for key,val in pairs(new_mock_turtle) do
    if type(val) == 'function' and string.sub(key, 1, 1) ~= '_' then
      new_turtle[key] = function(...)
        return new_mock_turtle[key](new_mock_turtle, ...)
      end
    end
  end
  return new_turtle, true
end

return mock_turtle_builder
