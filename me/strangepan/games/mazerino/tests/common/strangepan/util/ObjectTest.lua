package.path = package.path..";common/?.lua"
luaunit = require('luaunit')
require 'strangepan.util.Object'

TestObject = {}

function TestObject:setUp()
  self.underTest = Object()
end

function TestObject:test_getClass_isSameAsObject()
  luaunit.assertIs(self.underTest:getClass(), Object)
end

function TestObject:test_init_differentInstances()
  luaunit.assertNotIs(self.underTest, Object())
end

function TestObject:test_instanceOf_Object_isTrue()
  luaunit.assertIsTrue(self.underTest:instanceOf(Object))
end

function TestObject:test_instanceOf_otherInstance_isFalse()
  luaunit.assertIsFalse(self.underTest:instanceOf(Object()))
end

function TestObject:test_instanceOf_anonymousTabls_isFalse()
  luaunit.assertIsFalse(self.underTest:instanceOf({}))
end

os.exit(luaunit.LuaUnit.run())
