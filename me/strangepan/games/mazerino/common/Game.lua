local Secretary = require "me.strangepan.games.mazerino.common.strangepan.secretary.Secretary"
local class = require "me.strangepan.libs.lua.v1.class"
local type = require "me.strangepan.games.mazerino.common.strangepan.util.type"

local Game = class.build()

function Game:_init(secretary)
  class.superclass(Game)._init(self)
  self.secretary = assertClass(secretary, Secretary, "secretary")
end

function Game:start()
  return self
end

function Game:stop()
  return self
end

function Game:getSecretary()
  return self.secretary
end
