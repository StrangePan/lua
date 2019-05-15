local class = require 'me.strangepan.libs.util.v1.class'
local Rx = require 'libs.rxlua.rx'
local ternary = require 'me.strangepan.libs.util.v1.ternary'
local Vector = require 'me.strangepan.games.spacecargo.util.vector'
local Smoke = require 'me.strangepan.games.spacecargo.particles.smoke'
local Physics = require 'me.strangepan.games.spacecargo.newton.physics'
local Rxf = require 'me.strangepan.games.spacecargo.util.rxf'

local SpaceShip = class.build()

local thrust = 100 -- pts / sec^2
local angular_thrust = 4 -- radians / sec^2

function SpaceShip:_init()
  local initial_state = {
    position = Vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2),
    velocity = Vector(0, 0),
    angle = 0,
    angular_velocity = 0,
  }

  self._state = Rx.BehaviorSubject.create(initial_state)

  local positional_acceleration =
      love.update
          :with(Rxf.key_state('w'), self._state)
          :map(function(_, e, s) return e and Vector(thrust, 0):rotate(s.angle) or Vector.ZERO end)
  local positional_velocity = self._state:map(function(s) return s.velocity end)
  local position = self._state:map(function(s) return s.position end)
  local angular_acceleration =
      Rx.Observable.combineLatest(Rxf.key_state('d'), Rxf.key_state('a'), Rxf.VERBATIM_COMBINER())
          :map(function(right, left) return ternary(left, -1, 0) + ternary(right, 1, 0) end)
          :map(function(a) return a * angular_thrust end)
  local angular_velocity = self._state:map(function(s) return s.angular_velocity end)
  local angle = self._state:map(function(s) return s.angle end)

  local state_update =
      love.update:with(
          positional_acceleration,
          positional_velocity,
          position,
          angular_acceleration,
          angular_velocity,
          angle)
          :map(
            function(dt, pa, pv, p, aa, av, a)
              local _p, _pv = Physics.increment(dt, p, pv, pa)
              local _a, _av = Physics.increment(dt, a, av, aa)
              return _p, _pv, _a, _av
            end)
          :map(
            function(p, pv, a, av)
              return {
                position = p,
                velocity = pv,
                angle = a,
                angular_velocity = av,
              }
            end)

  local state_reset =
      love.keypressed
          :filter(function(k) return k == 'space' end)
          :map(function() return initial_state end)

  self._subscriptions = Rx.CompositeSubscription.create(
      state_update:merge(state_reset):subscribe(self._state),
      love.draw
          :with(self._state)
          :subscribe(
            function(_,s)
              local g = love.graphics
              g.push()
              g.translate(s.position:x(), s.position:y())
              g.rotate(s.angle)
              g.setColor(255, 255, 255)
              g.polygon('fill', 20, 0, -10, 10, -10, -10)
              g.pop()
            end))
end

function SpaceShip:destroy()
  self._subscriptions:unsubscribe()
end

return SpaceShip
