local luaunit = require 'luaunit'
local enum = require 'me.strangepan.libs.util.v1.enum'

TestObject = {}

function TestObject:test_build_whenEmpty_isEmpty()
  luaunit.assertEquals(enum.build().n, 0)
end

function TestObject:test_build_withData_didSetN()
  luaunit.assertEquals(enum.build('A', 'B', 'C').n, 3)
end

function TestObject:test_build_withData_didAssignIndices()
  local under_test = enum.build('A', 'B', 'C')

  luaunit.assertEquals(under_test.A, 1)
  luaunit.assertEquals(under_test.B, 2)
  luaunit.assertEquals(under_test.C, 3)
end

function TestObject:test_build_withData_canAccessViaIndices()
  local under_test = enum.build('A', 'B', 'C')

  luaunit.assertEquals(under_test[1], 'A')
  luaunit.assertEquals(under_test[2], 'B')
  luaunit.assertEquals(under_test[3], 'C')
end

os.exit(luaunit.LuaUnit.run())
