local class = require 'me.strangepan.libs.util.v1.class'
local lazy = require 'me.strangepan.libs.util.v1.lazy'
local ternary = require 'me.strangepan.libs.util.v1.ternary'
local builder_lazy = lazy 'me.strangepan.libs.util.v1.builder'
local mock_os_lazy = lazy 'me.strangepan.libs.computercraft.mock.v1.os'
local mock_turtle_lazy = lazy 'me.strangepan.libs.computercraft.mock.v1.turtle'

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
  os = self.os
  turtle = self.turtle
  return self
end

function mock_computercraft:release()
  if not self._is_captured then return self end
  self._is_captured = false
  os = self._real_os
  turtle = self._real_turtle
  self._real_os = nil
  self._real_turtle = nil
  return self
end


-- Builder

local mock_computercraft_builder

function mock_computercraft.builder()
  if not mock_computercraft_builder then
    local default_mock_os = {}
    local default_mock_turtle = {}

    mock_computercraft_builder =
      builder_lazy().builder()
        :field{name = 'mock_os', default = default_mock_os}
        :field{name = 'mock_turtle', default = default_mock_turtle}
        :builder_function(
          function(parameters)
            return mock_computercraft(
              ternary(
                parameters.mock_os ~= default_mock_os,
                parameters.mock_os,
                mock_os_lazy().builder():build_upon(os):build()),
              ternary( -- We don't want to overwrite the current turtle library if possible
                parameters.mock_turtle ~= default_mock_turtle,
                parameters.mock_turtle,
                turtle or mock_turtle_lazy().builder():build_upon(turtle):delay(0):build()))
          end)
        :build()
  end
  return mock_computercraft_builder()
end

return mock_computercraft
