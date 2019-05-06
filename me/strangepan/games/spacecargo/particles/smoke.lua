local Rx = require 'libs.rxlua.rx'
local class = require 'me.strangepan.libs.util.v1.class'
local Vector = require 'me.strangepan.games.spacecargo.util.vector'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

local Smoke = class.build()

local LIFESPAN = 0.5 -- secs
local FADE_RATE = 2 -- % / sec
local FRICTION = 100 -- pts / sec^2
local GROWTH_RATE = 20 -- pts / sec

function Smoke:_init(position, velocity)
  self._state = {
    position = assert_that(position):is_instance_of(Vector):and_return(),
    velocity = assert_that(velocity):is_instance_of(Vector):and_return(),
    opacity = 1,
    size = 5,
    lifespan = LIFESPAN,
  }

  self._subscriptions = {
    Rx.Observable.zip(
        love.update
            :map(function(dt) return dt, self._state.vector end)
            :map(function(dt) return v:scale(dt) end)
            :map(function(dxy) return self._state.position:add(dxy) end),
        love.update
            :map(function(dt) return FRICTION * dt end)
            :map(function(fr) return fr, self._state.velocity end)
            :map(function(fr, v) return Vector.copy_with_magnitude(v, v:magnitude() - fr) end),
        love.update
            :map(function(dt) return self._state.opacity - FADE_RATE * dt end),
        love.update
            :map(function(dt) return self._state.size + GROWTH_RATE * dt end),
        love.update
            :map(function(dt) return math.max(0, self._state.lifespan - LIFESPAN * dt) end))
        :map(function(pos, vel, op, si, li)
          return {
            position = pos,
            velocity = vel,
            opacity = op,
            size = si,
            lifespan = li,
          }
        end)
        :subscribe(function(state) self._state = state end),

    love.draw:subscribe(function()
      local g = love.graphics
      local x, y = self._state.position:x(), self._state.position:y()
      g.push()
      g.translate(x, y)
      g.setColor(255, 255, 255, self._state.opacity)
      g.circle('fill', x, y, self._state.size / 2)
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
