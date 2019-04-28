local builder = require 'me.strangepan.libs.lua.v1.builder'
local class = require 'me.strangepan.libs.lua.v1.class'
local ternary = require 'me.strangepan.libs.lua.v1.ternary'

local button = class.build()
button.HEIGHT = 64

function button:_init(builder_params)
  self.text = builder_params.text
  self._on_click = builder_params.on_click
  self.y = builder_params.y
  self.is_hovered = false
  self.is_pressed = false
end

function button:mousemoved(x, y, dx, dy, istouch)
  self:update_hover_state(x, y)
  self.is_pressed = self.is_pressed and self:is_in_bounds(x, y)
end

function button:mousepressed(x, y, button, istouch)
  if button ~= 1 then return end
  self.is_pressed = self:is_in_bounds(x, y)
  if self.is_pressed then
  end
end

function button:mousereleased(x, y, button, istouch)
  if button ~= 1 then return end
  local was_pressed = self.is_pressed
  self.is_pressed = false
  if was_pressed and self:is_in_bounds(x, y) then
    self:on_click()
  end
end

function button:update_hover_state(x, y)
  self.is_hovered = self:is_in_bounds(x, y)
end

function button:is_in_bounds(x, y)
  return (y >= self.y and y <= self.y + button.HEIGHT)
end

function button:on_click()
  print("clicked button "..self.text)
  self._on_click()
end

function button:draw()
  love.graphics.push()
  love.graphics.translate(0, self.y)
  love.graphics.print({{255, 255, 255, 255}, ternary(self.is_hovered, "> ", "  ")..self.text}, 0, button.HEIGHT / 2)
  love.graphics.pop()
end

function button.builder()

  -- Only define builder class if not previously defined
  if not button._builder_class then
    button._builder_class =
    builder.builder()
        :field({name = 'text', required = true})
        :field({name = 'on_click', required = true})
        :field({name = 'y', required = true})
        :builder_function(function(params) return button(params) end)
        :build()
  end

  -- Return new instance of builder class
  return button._builder_class()
end

return button
