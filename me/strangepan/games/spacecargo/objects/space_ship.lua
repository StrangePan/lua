local class = require 'me.strangepan.libs.util.v1.class'
local Rx = require 'libs.rxlua.rx'
local ternary = require 'me.strangepan.libs.util.v1.ternary'
local Vector = require 'me.strangepan.games.spacecargo.util.vector'
local Smoke = require 'me.strangepan.games.spacecargo.particles.smoke'

local SpaceShip = class.build()

local thrust = 100 -- pts / sec^2
local angular_thrust = 4 -- radians / sec^2

function SpaceShip:_init()
  self._state = {
    position = Vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2),
    velocity = Vector(0, 0),
    angle = 0,
    angular_velocity = 0,
  }

  local initial_state = self._state
  local position_update =
      love.update
          :map(function(dt) return self._state.velocity:scale(dt) end)
          :map(function(dp) return self._state.position:add(dp) end)
  local velocity_update =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('w'), dt, 0) end)
          :map(function(dt) return thrust * dt end)
          :map(function(dv) return Vector(1, 0):rotate_by(self._state.angle):scale(dv) end)
          :map(function(dxv) return self._state.velocity:add(dxv) end)
  local angle_update =
      love.update
          :map(function(dt) return self._state.angular_velocity * dt end)
          :map(function(da) return self._state.angle + da end)
  local positive_angular_velocity_update =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('a'), dt, 0) end)
          :map(function(dt) return -angular_thrust * dt end)
  local negative_angular_velocity_update =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('d'), dt, 0) end)
          :map(function(dt) return angular_thrust * dt end)
  local angular_velocity_update =
      Rx.Observable.zip(positive_angular_velocity_update, negative_angular_velocity_update)
          :map(function(a, b) return a + b end)
          :map(function(da) return self._state.angular_velocity + da end)

  local state_update =
      Rx.Observable.zip(
          position_update,
          velocity_update,
          angle_update,
          angular_velocity_update)
        :map(
            function(p, v, a, va)
              return {
                position = p,
                velocity = v,
                angle = a,
                angular_velocity = va,
              }
            end)

  local state_reset =
      love.keypressed
          :filter(function(k) return k == 'space' end)
          :map(function() return initial_state end)

  self._subscriptions = {
    state_update:merge(state_reset):subscribe(function(state) self._state = state end),

    -- subscribe the draw event
    love.draw
        :filter(function() return self._state end)
        :subscribe(function()
          local g = love.graphics
          g.push()
          g.translate(self._state.position:x(), self._state.position:y())
          g.rotate(self._state.angle)
          g.setColor(255, 255, 255)
          g.polygon('fill', 20, 0, -10, 10, -10, -10)
          g.pop()
        end),
  }
end

function SpaceShip:destroy()
  for _,subscription in ipairs(self._subscriptions) do
    subscription:unsubscribe()
  end
end

return SpaceShip
