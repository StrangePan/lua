local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'
local class = require 'me.strangepan.libs.util.v1.class'

local vector = class.build(nil, true)

local ORIGIN = vector()

function vector.origin()
  return ORIGIN
end

local function _to_number_array(...)
  local source = {...}
  if #source == 1 and type(source[1]) == 'table' then
    source = source[1]
  end
  assert_that(source):is_a_table()
  for _,n in ipairs(source) do
    assert_that(n):is_a_number()
  end
  return source
end

local function _merge_arrays(first, second, func)
  assert_that(first):is_a_table()
  assert_that(second):is_a_table()
  assert_that(func):is_a_function()
  local result = {}
  for i=1,math.max(#first, #second) do
    local m = first[i] or 0
    local n = second[i] or 0
    assert_that(m):is_a_number()
    assert_that(n):is_a_number()
    result[i] = func(m, n)
  end
  return result
end

local function _map_array(array, func)
  assert_that(array):is_a_table()
  assert_that(func):is_a_function()
  local result = {}
  for i=1,#array do
    local n = array[i]
    assert_that(n):is_a_number()
    result[i] = func(n)
  end
  return result
end

function vector:_init(...)
  self._n = 0
  for i,n in ipairs(_to_number_array(...)) do
    self[i] = n
    self._n = i
  end
end

function vector:__len()
  return self._n
end

function vector.__add(a, b)
  return vector(
      _merge_arrays(
          _to_number_array(a),
          _to_number_array(b),
          function(a, b) return a+b end))
end

function vector.__sub(a, b)
  return vector(
      _merge_arrays(
          _to_number_array(a),
          _to_number_array(b),
          function(a, b) return a-b end))
end

function vector:__str()
  assert_that(self):is_instance_of(vector)
  local s = '{'
  for i=1,#self do
    if i > 1 then
      s = s .. ', '
    end
    s = s .. tostring(self[i])
  end
  s = s .. '}'
  return s
end

local function mul_or_div(a, b, f)
  local t = a
  local n = b
  if type(b) == 'table' then
    t = b
    n = a
  end
  assert_that(t):is_a_table()
  assert_that(n):is_a_number()
  return vector(_map_array(_to_number_array(t), function(v) f(v, n) end))
end

function vector.__mul(a, b)
  return mul_or_div(a, b, function(v, n) return v * n end)
end

function vector.__div(a, b)
  return mul_or_div(a, b, function(v, n) return v / n end)
end

function vector.__mod(a, b)
  return mul_or_div(a, b, function(v, n) return v % n end)
end

function vector.__eq(a, b)
  a = _to_number_array(a)
  b = _to_number_array(b)
  local n = #a
  if n ~= #b then return false end
  for i = 1,n do
    if a[i] ~= b[i] then return false end
  end
  return true
end

return vector
