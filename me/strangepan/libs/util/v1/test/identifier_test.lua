local luaunit = require 'luaunit'
local identifier = require 'me.strangepan.libs.util.v1.identifier'

TestClass = {}

function TestClass:test_isValid_whenAllLetters_isValid()
  luaunit.assertTrue(identifier.is_valid('abc'))
end

function TestClass:test_isValid_whenContainsSpace_isInvalid()
  luaunit.assertFalse(identifier.is_valid('ab c'))
end

function TestClass:test_isValid_whenContainsUnderscore_isValid()
  luaunit.assertTrue(identifier.is_valid('ab_c'))
end

function TestClass:test_isValid_whenBeginsWithUnderscore_isValid()
  luaunit.assertTrue(identifier.is_valid('_abc'))
end

function TestClass:test_isValid_whenBeginsWithDigit_isInvalid()
  luaunit.assertFalse(identifier.is_valid('1abc'))
end

function TestClass:test_isValid_whenContainsDigit_isValid()
  luaunit.assertTrue(identifier.is_valid('abc123'))
end

function TestClass:test_isValid_whenAllUppercase_isValid()
  luaunit.assertTrue(identifier.is_valid('ABC'))
end

function TestClass:test_isValid_whenEmptyString_isInvalid()
  luaunit.assertFalse(identifier.is_valid(''))
end

function TestClass:test_isValid_whenTable_isInvalid()
  luaunit.assertFalse(identifier.is_valid({}))
end

function TestClass:test_isValid_whenNil_isInvalid()
  luaunit.assertFalse(identifier.is_valid(nil))
end

os.exit(luaunit.LuaUnit.run())
