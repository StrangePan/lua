local class = require 'me.strangepan.libs.lua.v1.class'

local text = class.build()

text.MAX_LINES = 8.5
text.CHAR_WIDTH = 20
text.MAX_WIDTH = math.floor(love.graphics.getWidth() / text.CHAR_WIDTH)
text.LINE_HEIGHT = 40
text.LINE_V_OFFSET = math.floor(text.LINE_HEIGHT / 2)

function text:_init()
  self:set_content('')
  self.canvas =
      love.graphics.newCanvas(
          text.MAX_WIDTH * text.CHAR_WIDTH, text.MAX_LINES * text.LINE_HEIGHT)
end

function text:set_content(content)
  local lines = {}
  local num_lines = 0

  local i = 1
  local line_start = 1
  local breakpoint = 1
  local len = string.len(content)
  while i <= len do
    local c = string.sub(content, i, i)
    if i == len then
      breakpoint = i
    elseif c == ' ' or c == '\n' then
      breakpoint = i - 1
    end
    if i - line_start + 1 > text.MAX_WIDTH or i == len or c == '\n' then
      num_lines = num_lines + 1
      lines[num_lines] = string.sub(content, line_start, breakpoint)
      breakpoint = breakpoint + 2 -- move to char after delimiter
      line_start = breakpoint
      print(content, i, num_lines, 'parsed out line:\n'..lines[num_lines])
    end
    i = i + 1
  end

  self.content = lines
  self.scroll_pos = 0
end

function text:wheelmoved(x, y)
  self.scroll_pos = self.scroll_pos - y * 10
  self.scroll_pos = math.min(
      self.scroll_pos,
      table.getn(self.content) * text.LINE_HEIGHT - text.MAX_LINES * text.LINE_HEIGHT)
  self.scroll_pos = math.max(0, self.scroll_pos)
end

function text:draw()
  local canvas = self.canvas

  love.graphics.push()
  love.graphics.setCanvas(canvas)

  love.graphics.clear()
  love.graphics.translate(0, -self.scroll_pos)

  local first_line = math.floor(self.scroll_pos / text.LINE_HEIGHT) + 1
  local last_line = math.min(
      math.floor((self.scroll_pos / text.LINE_HEIGHT) + (text.MAX_LINES)) + 1,
      table.getn(self.content))

  local i = first_line
  while i <= last_line do
    love.graphics.print(
        {{255, 255, 255, 255}, self.content[i]}, 0, (i - 1) * text.LINE_HEIGHT + text.LINE_V_OFFSET)
    i = i + 1
  end

  love.graphics.setCanvas()
  love.graphics.pop()
  love.graphics.draw(canvas)
end

return text
