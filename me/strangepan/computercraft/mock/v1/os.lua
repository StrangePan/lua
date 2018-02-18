local class = require 'me.strangepan.libs.lua.v1.class'

local _os = class.build()

function _os:sleep() end

function _os:mock()
  self = self or _os()
  local didMock = false
  if not os.sleep then
    os.sleep = function(...) return self:sleep(...) end
    didMock = true
  end
  return didMock
end

return _os
