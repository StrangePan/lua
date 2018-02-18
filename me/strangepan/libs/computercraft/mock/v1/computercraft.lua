local class = require 'me.strangepan.libs.lua.v1.class'
local mock_os = require 'me.strangepan.libs.computercraft.mock.v1.os'
local mock_turtle = require 'me.strangepan.libs.computercraft.mock.v1.turtle'

local mock_computercraft = class.build()

function mock_computercraft:_init(os, turtle)
  self.os = os
  self.turtle = turtle
  self._is_captured = false
end

function mock_computercraft:capture()
  if self._is_captured then return self end
  self._is_captured = true
  self._real_os = os
  self._real_turtle = turtle
  --noinspection GlobalCreationOutsideO
  os = self.os
  --noinspection GlobalCreationOutsideO
  turtle = self.turtle
  return self
end

function mock_computercraft:release()
  if not self._is_captured then return self end
  self._is_captured = false
  --noinspection GlobalCreationOutsideO
  os = self._real_os
  --noinspection GlobalCreationOutsideO
  turtle = self._real_turtle
  self._real_os = nil
  self._real_turtle = nil
  return self
end


-- Mocker

local computercraft_mocker = class.build()

function computercraft_mocker:mock_os(mock_os)
  self._mock_os = mock_os
  return self
end

function computercraft_mocker:mock_turtle(mock_turtle)
  self._mock_turtle = mock_turtle
  return self
end

function computercraft_mocker:build_mocks()
  if not self._mock_os then
    self._mock_os = mock_os().mocker():build_upon(os):build_mocks()
  end

  if not self._mock_turtle then
    self._mock_turtle = mock_turtle().mocker():build_upon(turtle):maybe_build_mocks()
  end

  return mock_computercraft(self._mock_os, self._mock_turtle)
end

function mock_computercraft.mocker()
  return computercraft_mocker()
end

return mock_computercraft
