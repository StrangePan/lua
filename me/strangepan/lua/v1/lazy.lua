local class = require 'me.strangepan.lua.v1.class'
local assert_that = require 'me.strangepan.lua.truth.v1.assert_that'

--[[ A handy way to require a module lazily.

Usage:
    local lazy = require 'me.strangepan.lua.v1.lazy'
    local lazy_my_module = lazy 'my.custom.module'

    function do_something()
      lazy_my_module:get().do_some_other_thing()
    end

You can even omit the ':get' altogether:
    function do_something()
      lazy_my_module().do_some_other_thing()
    end

You can even replace the 'require' function used by this class:
    lazy.require_function = function(requirement)
      -- Spy on requirements loaded lazyily by printing the requirement to std out
      print(requirement)
      return require(requirement)
    end
]]

local lazy = class.build()
lazy.require_function = require

function lazy:_init(requirement)
  self.requirement = assert_that(requirement):is_a_string():and_return()

  -- Make it so that users don't even have to reference the get() method explicitly
  local new_metatable = {}
  new_metatable.__index = lazy
  new_metatable.__call = function()
    return self:get()
  end
  setmetatable(new_metatable, lazy)
  setmetatable(self, new_metatable)
end

function lazy:get()
  return lazy.require_function(self.requirement)
end

return lazy
