require "strangepan.util.class"
require "strangepan.secretary.Secretary"

Game = buildClass()
local Class = Game

function Class:_init(secretary)
  Class.superclass._init(self)
  self.secretary = assertType(secretary, Secretary)
end

function Class:start()
  return self
end

function Class:stop()
  return self
end

function Class:getSecretary()
  return self.secretary
end
