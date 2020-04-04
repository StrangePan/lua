--[[
Set of util methods for meta class methods. Allows modules to define their own custom classes.
Ironically, the returned table is not indeed a class.

Calling the returned table as a function will call the ._init(...) method, so override this method
in your class to use it as a constructor. Or don't. I'm a comment, not a cop.

Usage:
    local class = require 'me.strangepan.libs.util.v1.class'

    local my_class = class.build()

    function my_class:_init(bar)
      self._bar = bar
    end

    function my_class:print()
      print(self._bar)
    end

    return my_class

To create a subclass of another preexisting class, provide the base class as a parameter.

Usage:
    local class = require 'me.strangepan.libs.util.v1.class'

    local superclass = class.build()
    local subclass = class.build(superclass)
]]

local class = {}

function class.build(superclass, immutable)
  local new_class = {}
  new_class.__index = new_class
  new_class._init = function() end
  new_class.__newindex = function(self, index, value)
    if self._mutation_lock then
      error('attempt to mutate instance of immutable class '..tostring(new_class))
    else
      return rawset(self, index, value)
    end
  end

  local new_metatable = {}
  new_metatable.__call = function(this_class, ...)
    local self = setmetatable({}, this_class)
    self:_init(...)
    self._mutation_lock = true
    return self
  end

  if superclass then
    new_metatable.__index = superclass
    new_metatable.__metatable = superclass
  end

  setmetatable(new_class, new_metatable)
  return new_class
end

--[[ Returns true iff the given table is an instance of a class or subclass. This works by first
comparing the first table with the second table, then comparing each each metatable of the first
table with the second table until a match is found or we reach the end of the metatable hierarchy.

Params:
  - instance the instance in question
  - superclass the possible parent class to compare the instance to
]]
function class.instance_of(instance, superclass)
  while instance do
    if instance == superclass then return true end
    instance = getmetatable(instance)
  end
  return false
end

return class
