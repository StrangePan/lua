--[[ A basic ternary function!

Usage:
    local ternary = require 'me.strangepan.libs.util.v1.ternary'

    function foo(bar)
      print(ternary(bar == nil, 'unset', bar))
    end
]]

return function(condition, if_true, if_false)
  if condition then return if_true else return if_false end
end
