local class = require 'me.strangepan.libs.lua.v1.class'

local mock_os = class.build()

function mock_os:sleep() end

-- Mocker

local mock_os_builder = {}

function mock_os_builder.build_mocks(current_os)
  local new_mock_os = mock_os()
  local did_mock = false
  for key,val in pairs(new_mock_os) do
    if type(val) == 'function' and string.sub(key, 1, 1) ~= '_' and not current_os[key] then
      current_os[key] = function(...)
        return new_mock_os[key](new_mock_os, ...)
      end
      did_mock = true
    end
  end
  return current_os, did_mock
end

return mock_os_builder
