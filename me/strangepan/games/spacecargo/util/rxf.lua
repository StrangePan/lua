local Rx = require 'libs.rxlua.rx'

local Rxf = {}

Rxf.TRUE = function() return true end
Rxf.FALSE = function() return false end
Rxf.VERBATIM_COMBINER = function(...) return ... end

function Rxf.key_state(key)
  local filter = function(k) return k == key end
  return Rx.Observable.of(false)
      :merge(
          love.keypressed:filter(filter):map(Rxf.TRUE),
          love.keyreleased:filter(filter):map(Rxf.FALSE))
end

return Rxf
