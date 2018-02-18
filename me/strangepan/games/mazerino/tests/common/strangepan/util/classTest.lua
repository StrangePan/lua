package.path = package.path..";common/?.lua"
luaunit = require('luaunit')
require 'strangepan.util.class'

TestClass = {}

function TestClass:setUp()
  self.underTest = buildClass()
end

function TestClass:test_buildClass_didSetIndex()
  luaunit.assertIs(self.underTest.__index, self.underTest)
end

function TestClass:test_buildClass_didSetSuperclass()
  luaunit.assertIs(self.underTest.superclass, Object)
end

function TestClass:test_buildClass_didSetMetatable()
  luaunit.assertIs(getmetatable(self.underTest), Object)
end

function TestClass:test_buildClass_thenConstruct_didSetMetatable()
  local newInstance = self.underTest()
  luaunit.assertIs(getmetatable(newInstance), self.underTest)
end

os.exit(luaunit.LuaUnit.run())
