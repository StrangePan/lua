local class = require 'me.strangepan.libs.lua.v1.class'

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
