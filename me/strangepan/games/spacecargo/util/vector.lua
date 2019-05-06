local class = require 'me.strangepan.libs.util.v1.class'

local Vector = class.build()

function Vector:_init(x, y)
  self[1] = x
  self[2] = y
end

function Vector:x()
  return self[1]
end

function Vector:y()
  return self[2]
end

function Vector.add(...)
  local x, y = 0, 0
  for v in ipairs({...}) do
    x = x + v[1]
    y = y + v[2]
  end
  return Vector(x, y)
end

function Vector:rotate_by(angle)

end
