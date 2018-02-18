local class = require 'me.strangepan.libs.lua.v1.class'
local os = require 'me.strangepan.computercraft.mock.v1.os'
local turtle = require 'me.strangepan.computercraft.mock.v1.turtle'

local mocker = class.build()

function mocker:mock()
  local didMock = false
  didMock = turtle:mock() or didMock
  didMock = os():mock() or didMock
  return didMock
end

return mocker
