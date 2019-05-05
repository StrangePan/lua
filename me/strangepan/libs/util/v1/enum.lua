local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

--[[ Builder functions creating enums.

Usage:
    local enum = require 'me.strangepan.libs.util.v1.enum'

    local my_enum = enum.build(
        'ENUM_VALUE_ALPHA',
        'ENUM_VALUE_BETA',
        'ENUM_VALUE_CHARLIE')

    function get_data()
      local data = {}
      data.type = my_enum.ENUM_VALUE_ALPHA
      return data
    end
]]

local enum = {}

function enum.build(...)
  local new_enum = {...}
  local n = 1
  while new_enum[n] ~= nil do
    new_enum[assert_that(new_enum[n]):is_a_string():and_return()] = n
    n = n + 1
  end
  new_enum.n = n - 1
  return new_enum
end

return enum
