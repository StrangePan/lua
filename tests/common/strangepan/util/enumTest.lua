package.path = package.path..";common/?.lua"
luaunit = require('luaunit')
require 'strangepan.util.enum'

TestEnum = {}

local ENUM_VALUES = {
  "A",
  "B",
  "C",
}

function TestEnum:setUp()
  self.underTest = buildEnum(table.unpack(ENUM_VALUES))
end

function TestEnum:test_buildEnum_indexByDotOperator()
  luaunit.assertEquals(self.underTest.A, 1)
  luaunit.assertEquals(self.underTest.B, 2)
  luaunit.assertEquals(self.underTest.C, 3)
end

function TestEnum:test_buildEnum_indexByIndex()
  luaunit.assertEquals(self.underTest[1], "A")
  luaunit.assertEquals(self.underTest[2], "B")
  luaunit.assertEquals(self.underTest[3], "C")
end

function TestEnum:test_buildEnum_indexByString()
  luaunit.assertEquals(self.underTest["A"], 1)
  luaunit.assertEquals(self.underTest["B"], 2)
  luaunit.assertEquals(self.underTest["C"], 3)
end

function TestEnum:test_values_didIterateIndexes()
  local iterator = self.underTest.values()
  luaunit.assertEquals(iterator(), 1)
  luaunit.assertEquals(iterator(), 2)
  luaunit.assertEquals(iterator(), 3)
  luaunit.assertEquals(iterator(), nil)
end

function TestEnum:test_fromId_whenValid_didReturnSame()
  luaunit.assertEquals(self.underTest.fromId(1), 1)
  luaunit.assertEquals(self.underTest.fromId(2), 2)
  luaunit.assertEquals(self.underTest.fromId(3), 3)
end

function TestEnum:test_fromId_whenNegative_didReturnNil()
  luaunit.assertEquals(self.underTest.fromId(-1), nil)
end

function TestEnum:test_fromId_whenZero_didReturnNil()
  luaunit.assertEquals(self.underTest.fromId(0), nil)
end

function TestEnum:test_fromId_whenGreater_didReturnNil()
  luaunit.assertEquals(self.underTest.fromId(4), nil)
end

os.exit(luaunit.LuaUnit.run())
