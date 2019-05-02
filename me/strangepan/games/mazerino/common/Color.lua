require "me.strangepan.games.mazerino.common.strangepan.util.class"
require "me.strangepan.games.mazerino.common.strangepan.util.type"

--
-- Class for storing color values.
--
Color = buildClass()
local Class = Color

--
-- Valid values are integers between 0 and 255.
-- default r = 0
-- default g = 0
-- default b = 0
-- default a = 255
--
function Class:_init(r, g, b, a)
  self.r = 0
  self.g = 0
  self.b = 0
  self.a = 255
  self:setRGBA(r, g, b, a)
end

--
-- Gets the red, green, blue, and alpha values for the color.
--
function Class:getRGBA()
  return self.r, self.g, self.b, self.a
end

--
-- Sets the red, green, blue, and alpha values for the color.
--
function Class:setRGBA(r, g, b, a)
  if r ~= nil then
    self.r = assertNumber(r, "r")
  end
  if g ~= nil then
    self.g = assertNumber(g, "g")
  end
  if b ~= nil then
    self.b = assertNumber(b, "b")
  end
  if a ~= nil then
    self.a = assertNumber(a, "a")
  end
end
