local class = require 'me.strangepan.libs.lua.v1.class'

local mock_os = class.build()

function mock_os:sleep() end


-- Mocker

local os_mocker = class.build()

function os_mocker:build_upon(current_os)
  self.current_os = current_os
  return self
end

function os_mocker:build_mocks()
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
  if self.current_os then
    setmetatable(new_os, {__index = self.current_os})
  end

  -- Return the newly constructed set of static functions instead of the mock_turtle directly.
  return new_os
end

function mock_os.mocker()
  return os_mocker()
end

return mock_os
