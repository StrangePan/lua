local class = require 'me.strangepan.libs.util.v1.class'
local Secretary = require 'me.strangepan.libs.secretary.v1.Secretary'
local Rx = require 'libs.rxlua.rx'

local RxLoveSecretary = class.build(Secretary)

--[[ Static constant table that maps love's callback functions to the Secretary's
corresponding methods.

<love function names, Secretary function names>
]]
local capture_map = {
  {'update', 'onLoveUpdate'},
  {'quit', 'onShutdown'},
  {'resize', 'onWindowResize'},
  {'draw', 'onLoveDraw'},
  {'keypressed', 'onKeyboardDown'},
  {'keyreleased', 'onKeyboardUp'},
  {'mousepressed', 'onMouseDown'},
  {'mousereleased', 'onMouseUp'},
  {'mousemoved', 'onMouseMove'},
  {'wheelmoved', 'onMouseWheelMove'},
  {'joystickpressed', 'onJoystickDown'},
  {'joystickreleased', 'onJoystickUp'},
  {'joystickadded', 'onJoystickAdd'},
  {'joystickremoved', 'onJoystickRemove'},
}

function RxLoveSecretary:_init()
  Secretary._init(self)

  -- array containing rx subscriptions for love events
  self._subscriptions = nil

  -- timestamp of last game tick
  self._last_tick = 0
end

function RxLoveSecretary:subscribe_to_love()
  if self._subscriptions then
    return
  end

  require 'libs.rxlove.rx-love'

  self._subscriptions = {}
  for i in 1,#capture_map do
    local secretary_function = self[capture_map[i][2]]
    self._subscriptions[i] =
        love[capture_map[i][1]]:subscribe(function(...) secretary_function(self, ...) end)
  end
end

function RxLoveSecretary:unsubscribe_from_love()
  if not self._subscriptions then
    return
  end

  for _,subscription in self._subscriptions do
    subscription:unsubscribe()
  end
  self._subscriptions = nil
end

function RxLoveSecretary:onLoveUpdate( dt )

  -- Regulate the framerate to 60 fps
  local target_tick = self._last_tick + (1/60 - dt)
  local current_tick = love.timer.getTime()
  while current_tick < target_tick do
    current_tick = love.timer.getTime()
  end
  self._last_tick = current_tick

  -- Call step-based events
  self:onPreStep()
  self:onPrePhysics()
  self:onPhysics()
  self:onPostPhysics()
  self:onStep()
  self:onPostStep()
end

function RxLoveSecretary:onLoveDraw( )
  self:onPreDraw()
  self:onDraw()
end

return RxLoveSecretary
