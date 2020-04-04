local luaunit = require 'luaunit'
local vector = require 'me.strangepan.libs.data.v1.vector'

TestClass = {}

unpack = table.unpack
local TEST_ARRAY = {0, 1, 3, 3, 8, -100}

local function assert_vector_equals(vec, data)
  luaunit.assertEquals(#vec, #data)
  for i in ipairs(data) do
    luaunit.assertEquals(vec[i], data[i])
  end
end

function TestClass:test_createVector_containsEqualValues()
  local under_test = vector(unpack(TEST_ARRAY))

  assert_vector_equals(under_test, TEST_ARRAY)
end

function TestClass:test_createVectorWithArray_containsEqualValues()
  local under_test = vector(TEST_ARRAY)

  assert_vector_equals(under_test, TEST_ARRAY)
end

function TestClass:test_init_withoutParams_isEmpty()
  local under_test = vector()

  luaunit.assertEquals(#under_test, 0)
end

function TestClass:test_init_withString_throwsError()
  luaunit.assertError(function() vector('123') end)
end

function TestClass:test_init_withFunction_throwsError()
  luaunit.assertError(function() vector(function() end) end)
end

function TestClass:test_init_withTable_ofStrings_throwsError()
  luaunit.assertError(function() vector({'test'}) end)
end

function TestClass:test_init_numbersAndStrings_throwsError()
  luaunit.assertError(function() vector(123, 4, 'hi') end)
end

function TestClass:test_init_withTable_ofNumbersAndStrings_throwsError()
  luaunit.assertError(function() vector({123, 4, 'hi'}) end)
end

function TestClass:test_init_withVector_copiesVector()
  local first = vector(TEST_ARRAY)
  local second = vector(first)

  assert_vector_equals(first, second)
end

function TestClass:test_equivalentVectors_areEqual()
  local first = vector(TEST_ARRAY)
  local second = vector(TEST_ARRAY)
  luaunit.assertIsTrue(first == second)
end

function TestClass:test_addVector_withVector_addsVector()
  local first = vector(3, 6, -1, 22, 5, 0)
  local second = vector(67, 5, 12, 55)
  local sum = first + second

  luaunit.assertNotIs(first, sum)
  luaunit.assertNotIs(second, sum)
  luaunit.assertEquals(#sum, #first)
  for i = 1,#second do
    luaunit.assertEquals(sum[i], first[i] + second[i])
  end
  for i = 5,6 do
    luaunit.assertEquals(sum[i], first[i])
  end
end

os.exit(luaunit.LuaUnit.run())
