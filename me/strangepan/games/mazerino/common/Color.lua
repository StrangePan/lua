local class = require "me.strangepan.libs.lua.v1.class"
local assert_that = require "me.strangepan.libs.lua.truth.v1.assert_that"

--
-- Color for storing color values.
--
local Color = class.build()

--
-- Valid values are integers between 0 and 255.
-- default r = 0
-- default g = 0
-- default b = 0
-- default a = 255
--
function Color:_init(r, g, b, a)
  self.r = 0
  self.g = 0
  self.b = 0
  self.a = 255
  self:setRGBA(r, g, b, a)
end

--
-- Gets the red, green, blue, and alpha values for the color.
--
function Color:getRGBA()
  return self.r, self.g, self.b, self.a
end

--
-- Sets the red, green, blue, and alpha values for the color.
--
function Color:setRGBA(r, g, b, a)
  if r ~= nil then
    self.r = assert_that(r):is_a_number():and_return()
  end
  if g ~= nil then
    self.g = assert_that(g):is_a_number():and_return()
  end
  if b ~= nil then
    self.b = assert_that(b):is_a_number():and_return()
  end
  if a ~= nil then
    self.a = assert_that(a):is_a_number():and_return()
  end
end

return Color
