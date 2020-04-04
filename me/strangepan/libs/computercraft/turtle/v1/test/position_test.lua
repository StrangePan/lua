local luaunit = require 'luaunit'
local position = require 'me.strangepan.libs.computercraft.turtle.v1.position'
local vector = require 'me.strangepan.libs.data.v1.vector'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

TestObject = {}

local function assert_position_equals(position, coordinates)
  assert_that(coordinates):is_a_table()
  assert_that(#coordinates):is_equal_to(3)
  assert_that(coordinates[1]):is_a_number()
  assert_that(coordinates[2]):is_a_number()
  assert_that(coordinates[3]):is_a_number()

  luaunit.assert_equals(position:x(), coordinates[1])
  luaunit.assert_equals(position:y(), coordinates[2])
  luaunit.assert_equals(position:z(), coordinates[3])
  luaunit.assert_is(position:as_vector(), vector(coordinates))
  luaunit.assert_equals(position:as_array(), coordinates)
end

function TestObject:test_init_atOrigin_isOrigin()
  local under_test = position(0, 0, 0)

  assert_position_equals(under_test, {0, 0, 0})
end

function TestObject:test_init_atSomeValue_isEqual()
  local under_test = position(-4, 11, 1234)

  assert_position_equals(under_test, {-4, 11, 1234})
end

function TestObject:test_translate_returnsTranslatedPosition()
  local original = position(6, -145, 33)
  local translated = original:translate(66, 12, -1)

  assert_position_equals(translated, {72, -133, 32})
end

function TestObject:test_translate_doesNotMutateOriginal()
  local original = position(6, -145, 33)
  local translated = original:translate(66, 12, -1)

  assert_position_equals(original, {6, -145, 33})
end

os.exit(luaunit.LuaUnit.run())
