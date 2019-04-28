local button = require "button"
local text = require "text"
local story = require "story"

local buttons = {}
local dialog_window = text()
local story_obj = story(require 'story_content')

function love.load()
  love.graphics.setNewFont('neoletters.ttf', 32)
  load_story_content()
end

function on_click(option)
  story_obj:resolve_option(option)
  load_story_content()
end

function load_story_content()
  dialog_window:set_content(story_obj:current_text())

  buttons = {}
  for i,option in ipairs(story_obj:current_options()) do
    buttons[i] =
    button.builder()
          :text(option.text)
          :y(love.graphics.getHeight() - button.HEIGHT * (3 - i + 1))
          :on_click(
        function()
          local o = i
          on_click(o)
        end
    )
          :build()
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  for _,b in pairs(buttons) do
    b:mousemoved(x, y, dx, dy)
  end
end

function love.mousepressed(x, y, button, istouch)
  for _,b in pairs(buttons) do
    b:mousepressed(x, y, button, istouch)
  end
end

function love.mousereleased(x, y, button, istouch)
  for _,b in pairs(buttons) do
    b:mousereleased(x, y, button, istouch)
  end
end

function love.wheelmoved(x, y)
  dialog_window:wheelmoved(x, y)
end

function love.draw()
  for _,b in pairs(buttons) do
    b:draw()
  end
  dialog_window:draw()
end