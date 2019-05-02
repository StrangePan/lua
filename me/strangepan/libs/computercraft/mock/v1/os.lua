local class = require 'me.strangepan.libs.lua.v1.class'
local lazy = require 'me.strangepan.libs.lua.v1.lazy'
local builder = lazy 'me.strangepan.libs.lua.v1.builder'

local mock_os = class.build()

function mock_os:sleep() end


-- Builder

local mock_os_builder

function mock_os.builder()
  if not mock_os_builder then
    local function builder_function(parameters)
      local new_os = {}
      local new_mock_os = mock_os()

      -- Constructs new functions that, when called, call member methods on the mock_turtle object.
      -- Effectively, this maps a static function to a member method.
      for key,val in pairs(mock_os) do
        if type(val) == 'function' and string.sub(key, 1, 1) ~= '_' then
          new_os[key] = function(...)
            return val(new_mock_os, ...)
          end
        end
      end

      -- Any methods not defined on the mock should default to the base
      if parameters.build_upon then
        setmetatable(new_os, {__index = parameters.build_upon})
      end

      -- Return the newly constructed set of static functions instead of the mock_turtle directly.
      return new_os
    end

    mock_os_builder =
      builder().builder()
        :field{name = 'build_upon'}
        :builder_function(builder_function)
        :build()
  end
  return mock_os_builder()
end

return mock_os
