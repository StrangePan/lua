local class = require 'me.strangepan.libs.util.v1.class'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

local Vector = class.build()

function Vector:_init(x, y)
  self[1] = assert_that(x):is_a_number():and_return()
  self[2] = assert_that(y):is_a_number():and_return()
end

Vector.UNIT_X = Vector(1, 0)
Vector.UNIT_Y = Vector(0, 1)
Vector.ZERO = Vector(0, 0)

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

function Vector.__add(a, b)
  assert_that(a):is_instance_of(Vector)
  assert_that(b):is_instance_of(Vector)
  return Vector.add(a, b)
end

function Vector.subtract(a, b)
  assert_that(a):is_instance_of(Vector)
  assert_that(b):is_instance_of(Vector)
  return Vector(a[1] - b[1], a[2] - b[2])
end

function Vector.__sub(a, b)
  assert_that(a):is_instance_of(Vector)
  assert_that(b):is_instance_of(Vector)
  return Vector.subtract(a, b)
end

function Vector.rotate(vector, angle)
  assert_that(vector):is_instance_of(Vector)
  assert_that(angle):is_a_number()
  local sin = math.sin(angle)
  local cos = math.cos(angle)
  return Vector(vector[1] * cos - vector[2] * sin, vector[1] * sin + vector[2] * cos)
end

function Vector.scale(vector, scale)
  assert_that(vector):is_instance_of(Vector)
  assert_that(scale):is_a_number()
  return Vector(vector[1] * scale, vector[2] * scale)
end

function Vector.__mul(a, b)
  local n, v
  if type(a) == 'number' then
    n = a
    v = b
  else
    n = b
    v = a
  end
  return Vector.scale(v, n)
end

function Vector.__div(v, n)
  assert_that(v):is_instance_of(Vector)
  assert_that(n):is_a_number()
  return Vector.scale(v, 1 / n)
end

function Vector.__eq(a, b)
  return a[1] == b[1] and a[2] == b[2]
end

function Vector.__tostring(v)
  return 'Vector: ('..v[1]..','..v[2]..')'
end

return Vector
