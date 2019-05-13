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

  -- x  = x0 + v0 * t + a / 2 * t * t

  local initial_state = self._state
  local acceleration_vector =
      love.update
          :map(
            function()
              return ternary(
                  love.keyboard.isDown('w'),
                  Vector(thrust, 0):rotate(self._state.angle),
                  Vector.ZERO)
            end)
  local velocity_vector =
      love.update
          :zip(acceleration_vector)
          :map(function(dt, av) return av * dt + self._state.velocity end)
  local position_vector =
  love.update
      :zip(acceleration_vector)
      :map(
        function(dt, av)
          return self._state.position + self._state.velocity * dt + av * (dt * dt / 2)
        end)
  local positive_angular_acceleration =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('d'), dt, 0) end)
  local negative_angular_acceleration =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('a'), -dt, 0) end)
  local angular_acceleration =
      positive_angular_acceleration
          :zip(negative_angular_acceleration)
          :map(function(pa, na) return angular_thrust * (pa + na) end)
  local angular_velocity =
      angular_acceleration
          :map(function(da) return self._state.angular_velocity + da end)
  local angle =
      love.update
          :zip(angular_acceleration)
          :map(
            function(dt, aa)
                return self._state.angle + self._state.angular_velocity * dt + aa * (dt * dt / 2)
            end)

  local state_update =
      Rx.Observable.zip(
          position_vector,
          velocity_vector,
          angle,
          angular_velocity)
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
