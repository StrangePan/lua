local class = require 'me.strangepan.libs.util.v1.class'
local vector = require 'me.strangepan.libs.data.v1.vector'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

local position = class.build(nil, true)

function position:_init(x, y, z)
  assert_that(x):is_a_number()
  assert_that(y):is_a_number()
  assert_that(z):is_a_number()
  self._vec = vector(x, y, z)
end

function position:x()
  return self._vec[1]
end

function position:y()
  return self._vec[2]
end

function position:z()
  return self._vec[3]
end

function position:as_vector()
  return self._vec
end

function position:as_array()
  return {self:x(), self:y(), self:z()}
end

function position:translate(x, y, z)
  assert_that(x):is_a_number()
  assert_that(y):is_a_number()
  assert_that(z):is_a_number()
  return position(unpack(self._vec + {x, y, z}))
end

return position
