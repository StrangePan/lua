--[[
Set of util methods for meta class methods. Allows modules to define their own custom classes.
Ironically, the returned table is not indeed a class.

Calling the returned table as a function will call the ._init(...) method, so override this method
in your class to use it as a constructor. Or don't.

Note: superclasses are not a great practice, and so are not supported.

Usage:
    local class = require 'me.strangepan.libs.lua.v1.class'

    local my_class = class.build()

    function my_class:_init(bar)
      self._bar = bar
    end

    function my_class:print()
      print(self._bar)
    end

    return my_class
]]

local class = {}

function class.build()
  local new_class = {}
  new_class.__index = new_class
  new_class._init = function() end

  local new_metatable = {}
  new_metatable.__call = function(thisClass, ...)
    local self = setmetatable({}, thisClass)
    self:_init(...)
    return self
  end

  setmetatable(new_class, new_metatable)
  return new_class
end

return class
