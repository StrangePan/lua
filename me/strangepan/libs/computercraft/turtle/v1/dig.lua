local class = require 'me.strangepan.libs.util.v1.class'

--[[ Class to concisely express turtle dig operations.

Example:
    local dig_class = require 'me.strangepan.libs.computercraft.turtle.v1.dig'

    local dig = dig_class()
    dig:forward():up():down()

Yeah. It's that easy. Each method returns two values: 1) the `move` instance that the method was
invoked with and 2) a boolean representing whether or not a block was dig.

Example:
    local _,result = dig:forward()
    if result then
      print('Turtle dug block in front of it')
    end
]]

local dig = class.build()

function dig:forward()
  return self, turtle.dig()
end

function dig:up()
  return self, turtle.digUp()
end

function dig:down()
  return self, turtle.digDown()
end

return dig
