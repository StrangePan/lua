local Secretary = require "me.strangepan.libs.secretary.v1.Secretary"
local class = require "me.strangepan.libs.util.v1.class"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

local Game = class.build()

function Game:_init(secretary)
  self.secretary = assert_that(secretary):is_instance_of(Secretary):and_return()
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

return Game
