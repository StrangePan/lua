local class = require 'strangepan.lua.class'

local mocker = class.build()

function mocker.mock()
  local didMock = false
  didMock = require 'strangepan.computercraft.turtle.mock'.mock() or didMock
  didMock = require 'strangepan.computercraft.os.mock'.mock() or didMock
  return didMock
end

return mocker
