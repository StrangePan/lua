local class = require 'me.strangepan.libs.lua.v1.class'

local story = class.build()

function story:_init(content)
  self.content = content
  self.current = self.content['Story Page 1']
end

function story:current_text()
  return self.current.text
end

function story:current_options()
  return self.current.options
end

function story:resolve_option(n)
  assert(n >= 1 and n <= table.getn(self:current_options()))
  self.current = self.content[self.current.options[n].dest]
end

return story
