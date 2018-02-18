package.path = package.path..";common/?.lua"
local luaunit = require('luaunit')
local translation = require('mazerino.util.translation')

local GRID_VALUES = {1, 2, 5, 0, -20, 132}
local SCREEN_VALUES = {32, 64, 160, 0, -640, 4224}
local UNEVEN_SCREEN_VALUES = {36, 64, 160, 0.2, -640, 4227}

TestClass = {}

function TestClass:test_toScreen_didMultiplyBy32()
  luaunit.assertItemsEquals({translation.toScreen(unpack(GRID_VALUES))}, SCREEN_VALUES)
end

function TestClass:test_toGrid_didDivideBy32AndFloor()
  luaunit.assertItemsEquals({translation.toGrid(unpack(UNEVEN_SCREEN_VALUES))}, GRID_VALUES)
end

os.exit(luaunit.LuaUnit.run())
