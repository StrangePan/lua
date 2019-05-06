local class = require 'me.strangepan.libs.util.v1.class'
local Rx = require 'libs.rxlua.rx'
local ternary = require 'me.strangepan.libs.util.v1.ternary'

local SpaceShip = class.build()

local thrust_force = 100 -- pts / sec^2
local angular_force = 2 -- radians / sec^2

function SpaceShip:_init()
  self._state = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2,
    velocity = {
      x = 0,
      y = 0,
    },
    angle = 0,
    angular_velocity = 0,
  }

  local x_update =
      love.update
          :map(function(dt) return self._state.velocity.x * dt end)
          :map(function(dx) return self._state.x + dx end)
  local y_update =
      love.update
          :map(function(dt) return self._state.velocity.y * dt end)
          :map(function(dy) return self._state.y + dy end)
  local x_velocity_update =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('w'), dt, 0) end)
          :map(function(dt) return thrust_force * dt end)
          :map(function(dv) return math.cos(self._state.angle) * dv end)
          :map(function(dxv) return self._state.velocity.x + dxv end)
  local y_velocity_update =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('w'), dt, 0) end)
          :map(function(dt) return thrust_force * dt end)
          :map(function(dv) return math.sin(self._state.angle) * dv end)
          :map(function(dyv) return self._state.velocity.y + dyv end)
  local angle_update =
      love.update
          :map(function(dt) return self._state.angular_velocity * dt end)
          :map(function(da) return self._state.angle + da end)
  local positive_angular_velocity_update =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('a'), dt, 0) end)
          :map(function(dt) return -angular_force * dt end)
  local negative_angular_velocity_update =
      love.update
          :map(function(dt) return ternary(love.keyboard.isDown('d'), dt, 0) end)
          :map(function(dt) return angular_force * dt end)
  local angular_velocity_update =
      Rx.Observable.zip(positive_angular_velocity_update, negative_angular_velocity_update)
          :map(function(a, b) return a + b end)
          :map(function(da) return self._state.angular_velocity + da end)

  local initialState =
      Rx.Observable.of()

  local stateUpdate =
      Rx.Observable.zip(
          x_update,
          y_update,
          x_velocity_update,
          y_velocity_update,
          angle_update,
          angular_velocity_update)
        :map(
            function(x, y, vx, vy, a, va)
              return {
                x = x,
                y = y,
                velocity = {
                  x = vx,
                  y = vy,
                },
                angle = a,
                angular_velocity = va,
              }
            end)

  self._subscriptions = {
    initialState:concat(stateUpdate):subscribe(function(state) self._state = state end),

    -- subscribe the draw event
    love.draw
        :filter(function() return self._state end)
        :subscribe(function()
          local g = love.graphics
          g.push()
          g.translate(self._state.x, self._state.y)
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
