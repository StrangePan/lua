local Rx = require 'libs.rxlua.rx'
local class = require 'me.strangepan.libs.util.v1.class'
local Vector = require 'me.strangepan.games.spacecargo.util.vector'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

local Smoke = class.build()

local LIFESPAN = 1 -- secs

function Smoke:_init(position, velocity)
  self._state = {
    position = assert_that(position):is_instance_of(Vector):and_return(),
    velocity = assert_that(velocity):is_instance_of(Vector):and_return(),
    lifespan = LIFESPAN,
  }

  self._subscriptions = {
    Rx.Observable.zip(
        love.update
            :map(function(dt) return self._state.velocity:scale(dt) end)
            :map(function(dp) return self._state.position:add(dp) end),
        love.update
            :map(function(dt) return math.max(0, self._state.lifespan - LIFESPAN * dt) end))
        :map(function(pos, li)
          return {
            position = pos,
            velocity = self._state.velocity,
            lifespan = li,
          }
        end)
        :subscribe(function(state) self._state = state end),

    love.draw:subscribe(function()
      local g = love.graphics
      local x, y = self._state.position:x(), self._state.position:y()
      g.push()
      g.translate(x, y)
      g.setColor(255, 255, 255, (1 - self._state.lifespan / LIFESPAN) * 255)
      g.circle('fill', x, y, (1 - self._state.lifespan / LIFESPAN) * 10)
      g.pop()
    end),

    love.update
        :filter(function() return self._state.lifespan <= 0 end)
        :subscribe(function() self:destroy() end),
  }
end

function Smoke:destroy()
  for _,s in ipairs(self._subscriptions) do
    s:unsubscribe()
  end
end

return Smoke
