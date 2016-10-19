require "Secretary"

--
-- Secretary object that is specifically compatible with Love2D and
-- is capable of capturing love events and restoring them on command.
--
LoveSecretary = buildClass(Secretary)
local Class = LoveSecretary

function Class:_init()
  Class.superclass._init(self)
end

--
-- Static private variable for tracking the instance that is currently
-- capturing the Love events and the originally replaced love functions.
--
local captured = {
  instance = nil,
  functions = {},
}

--
-- Static constant table that maps love's callback functions to the Secretary's
-- corresponding methods.
-- Col1 = love function names
-- Col2 = Secretary function names
--
local captureMap = {
  {'update', 'onLoveUpdate'},
  {'quit', 'onShutdown'},
  {'resize', 'onWindowResize'},
  {'draw', 'onLoveDraw'},
  {'keypressed', 'onKeyboardDown'},
  {'keyreleased', 'onKeyboardUp'},
  {'mousepressed', 'onMouseDown'},
  {'mousereleased', 'onMouseUp'},
  {'mousemoved', 'onMouseMoved'},
  {'wheelmoved', 'onMouseWheelMove'},
  {'joystickpressed', 'onJoystickDown'},
  {'joystickreleased', 'onJoystickUp'},
  {'joystickadded', 'onJoystickAdded'},
  {'joystickremoved', 'onJoystickRemoved'},
}


--
-- Static function for getting the instance that is currently capturing
-- the Love events. Returns `nil` if no instance exists that is capturing
-- the Love events.
--
function Class.getCapturingInstance()
  return captured.instance
end

--
-- Makes this instance capture Love2D's events. If another instance is already
-- capturing the Love events, will throw an error.
--
-- Returns self if successful.
--
function Class:captureLoveEvents()
  assert(not captured.instance, "Love events already captured. Call releaseLoveEvents() on original LoveSecretary instance.")
  captured.instance = self
  
  for _,row in ipairs(captureMap) do
    local loveFunctionName = row[1]
    local selfFunctionName = row[2]
    
    -- Store the current love function into a function array
    captured.functions[loveFunctionName] = love[loveFunctionName]
    
    -- Replace it with a wrapper function for this instance of the Secretary
    love[loveFunctionName] = function(...)
      self[selfFunctionName](self, ...)
    end
  end
  
  return self
end

--
-- Makes this instance give up its captured Love2D events and restores the
-- original functionality. If this instance is not already capturing Love's
-- events, then this method does nothing.
--
function Class:releaseLoveEvents()
  if captured.instance ~= self then return end
  captured.instance = nil
  
  for _,row in ipairs(captureMap) do
    local loveFunctionName = row[1]
    
    -- Restore each stored love function to the love table
    love[loveFunctionName] = captured.functions[loveFunctionName]
    captured.functions[loveFunctionName] = nil
  end
end

--
-- Overrides the default love.update() method to regulate framerate and execute
-- other event types in a specific order for finer granularity over event
-- timing.
--
function Class:onLoveUpdate( dt )
  
  -- Regulate the framerate to 60 fps
  local targetTime = love.timer.getTime() + (1/60 - dt)
  while love.timer.getTime() < targetTime do end
  
  -- Call step-based events
  self:onPreStep()
  self:onPrePhysics()
  self:onPhysics()
  self:onPostPhysics()
  self:onStep()
end

--
-- Overrides the default love.draw() method, seperating the event into multiple
-- sub-events for finer granularity over event timing.
--
function Class:onLoveDraw( )
  self:onPreDraw()
  self:onDraw()
end
