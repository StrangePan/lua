local luaunit = require 'luaunit'
local ternary = require 'me.strangepan.libs.util.v1.ternary'

TestClass = {}

function TestClass:test_ternary_true_false_true_didReturnFalse()
  luaunit.assertFalse(ternary(true, false, true))
end

function TestClass:test_ternary_true_true_false_didReturnTrue()
  luaunit.assertTrue(ternary(true, true, false))
end

function TestClass:test_ternary_false_true_false_didReturnFalse()
  luaunit.assertFalse(ternary(false, true, false))
end

function TestClass:test_ternary_false_false_true_didReturnTrue()
  luaunit.assertTrue(ternary(false, false, true))
end

function TestClass:test_ternary_false_132_hi_didReturnHi()
  luaunit.assertEquals(ternary(false, 132, 'hi'), 'hi')
end

function TestClass:test_ternary_true_132_hi_didReturn132()
  luaunit.assertEquals(ternary(true, 132, 'hi'), 132)
end

os.exit(luaunit.LuaUnit.run())
