--[[
Set of util methods for meta class methods. Allows modules to define their own custom classes.
Ironically, the returned table is not indeed a class.

Calling the returned table as a function will call the ._init(...) method, so override this method
in your class to use it as a constructor. Or don't.

Note: superclasses are not a great practice, and so are not supported.
]]

local class = {}

function class.build()
  local newClass = {}
  newClass.__index = newClass
  newClass._init = function() end

  local newMetatable = {}
  newMetatable.__call = function(thisClass, ...)
    local self = setmetatable({}, thisClass)
    self:_init(...)
    return self
  end

  setmetatable(newClass, newMetatable)
  return newClass
end

return class
