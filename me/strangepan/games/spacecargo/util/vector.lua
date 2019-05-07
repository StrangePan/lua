local class = require 'me.strangepan.libs.util.v1.class'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

local Vector = class.build()

function Vector:_init(x, y)
  self[1] = assert_that(x):is_a_number():and_return()
  self[2] = assert_that(y):is_a_number():and_return()
end

function Vector:x()
  return self[1]
end

function Vector:y()
  return self[2]
end

function Vector:magnitude()
  return math.sqrt(self[1] * self[1] + self[2] * self[2])
end

function Vector.add(...)
  local x = 0
  local y = 0
  for _,v in ipairs({...}) do
    assert_that(v):is_instance_of(Vector)
    x = x + v[1]
    y = y + v[2]
  end
  return Vector(x, y)
end

function Vector.rotate_by(vector, angle)
  assert_that(vector):is_instance_of(Vector)
  assert_that(angle):is_a_number()
  local sin = math.sin(angle)
  local cos = math.cos(angle)
  return Vector(vector[1] * cos - vector[2] * sin, vector[1] * sin + vector[2] * cos)
end

function Vector.copy_with_magnitude(vector, magnitude)
  return Vector.scale(vector, magnitude / vector:magnitude())
end

function Vector.scale(vector, scale)
  assert_that(vector):is_instance_of(Vector)
  assert_that(scale):is_a_number()
  return Vector(vector[1] * scale, vector[2] * scale)
end

return Vector
