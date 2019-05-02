require "me.strangepan.games.mazerino.common.strangepan.secretary.Secretary"
require "me.strangepan.games.mazerino.common.strangepan.util.class"
require "me.strangepan.games.mazerino.common.strangepan.util.type"

Game = buildClass()
local Class = Game

function Class:_init(secretary)
  Class.superclass._init(self)
  self.secretary = assertClass(secretary, Secretary, "secretary")
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
