require "strangepan.secretary.QuadTree"
require "strangepan.secretary.EventType"
require "strangepan.secretary.DrawLayer"
require "strangepan.secretary.Entity"
require "strangepan.secretary.PhysObject"
require "strangepan.util.class"
require "strangepan.util.functions"
require "strangepan.util.SortedSet"
require "strangepan.util.FunctionQueue"

Secretary = buildClass()
local class = Secretary

class.DEFAULT_PRIORITY = 1



function class:_init()
  
  -- Collision detection data structure
  self.tree = QuadTree(1, -1000, 1000, 1000, -1000)
  
  self.paused = false
  self.objectNodes = {}  -- table containing direct references to object quadtree nodes
  self.callbacks = {}    -- table containing all callbacks
  self.queue = FunctionQueue()
  self.postpone = false

  -- sorted table of integers representing indexes into self.callbacks[EventType.DRAW] table.
  self.layers = SortedSet()
  
  -- Prepare callback lists
  for t in EventType.values() do
    self.callbacks[t] = {n = 0}
  end
end





--------------------------------------------------------------------------------
--                            COLLISION SYSTEM                                --
--------------------------------------------------------------------------------

--[[
Registers a new PhysObject with the Secretary.

object: The new object to track collisions with.
]]
function class:registerPhysObject(object)
  
  -- Validate arguments
  assertType(object, "object", PhysObject)
  assert(self.objectNodes[object] == nil, "Object already registered with the secretary")
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:push(self.registerPhysObject, self, object)
    return
  end
  
  -- Store full node path
  self.objectNodes[object] = self.tree:insert(object)
end

--[[
Unregisters a PhysObject with the Secretary, removing them from collision
checks and data structures.

object: The object to unregister.
]]
function class:unregisterPhysObject(object)
  
  -- Validate arguments
  assertType(object, "object", PhysObject)
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:push(self.unregisterPhysObject, self, object)
    return
  end
  
  -- Remove object from quadtree
  self.tree:remove(object, self.objectNodes[object])
end

--[[
Updates an object's status in the quadtree and other lists, updating caches
and indexes for fast access.

object: The object to update information for.
]]
function class:updateObject(object)
  local path = self.tree:getFullIndex(object:getBoundingBox())
  
  if path ~= self.objectNodes[object] then
    self.tree:remove(object, self.objectNodes[object])
    path = self.tree:insert(object)
    self.objectNodes[object] = path
  end
end

--[[
Gets a list of all registered objets whose bouding boxes intersect with the
supplied bounds.

#Parameters
- top - required - number  
  Top coordinate of the bouding box to check.
- right - required - number  
  Right coordinate of the bouding box to check.
- bottom - required - number  
  Bottom coordinate of the bounding box to check.
- left - required - number  
  Left coordinate of the bounding box to check.

#Return
- Table containing indexed array of objects whose bounding boxes intersect
  with the supplied coordinates.
]]
function class:getCollisions(top, right, bottom, left, front, back, ...)
  local arg = {...}
  assert(top and right and bottom and left, "parameter(s) cannot be nil")
  
  if type(front) == "table" then table.insert(arg, front) end
  if type(back) == "table" then table.insert(arg, back) end
  
  -- Initialize variables
  local list = {}
  local i = 1
  
  -- Retrieve list of all possible collisions from tree
  self.tree:retrieve(list, top, right, bottom, left, unpack(arg))
  
  -- Remove objects from list that we do not collide with
  local lastIndex = 1
  while list[i] ~= nil do
    if list[i]:collidesWith(top, right, bottom, left) == true then
      if i ~= lastIndex then
        list[lastIndex] = list[i]
        list[i] = nil
      end
      lastIndex = lastIndex + 1
    else
      list[i] = nil
    end
    i = i + 1
  end
  
  -- Return our compiled list
  return list
end

function class:remove(object)
  if object:instanceOf(PhysObject) then
    self:unregisterPhysObject(object)
  end
  self:unregisterAllListeners(object)
end



function class:registerChildSecretary(child)
  
  -- Validate parameters
  assertType(child, "child", Secretary)
  assert(child ~= self, "A Secretary cannot register itself as a child, unless you're a sadist and WANT infinite loops")
  
  -- Register event methods of child with self
  self:registerEventListener(child, child.onDraw, EventType.DRAW)
  self:registerEventListener(child, child.onPreStep, EventType.PRE_STEP)
  self:registerEventListener(child, child.onStep, EventType.STEP)
  self:registerEventListener(child, child.onPreStep, EventType.POST_STEP)
  self:registerEventListener(child, child.onPrePhysics, EventType.PRE_PHYSICS)
  self:registerEventListener(child, child.onPhysics, EventType.PHYSICS)
  self:registerEventListener(child, child.onPostPhysics, EventType.POST_PHYSICS)
  self:registerEventListener(child, child.onShutdown, EventType.SHUTDOWN)
  self:registerEventListener(child, child.onKeyboardDown, EventType.KEYBOARD_DOWN)
  self:registerEventListener(child, child.onKeyboardUp, EventType.KEYBOARD_UP)
  self:registerEventListener(child, child.onMouseDown, EventType.MOUSE_DOWN)
  self:registerEventListener(child, child.onMouseUp, EventType.MOUSE_UP)
  self:registerEventListener(child, child.onMouseMove, EventType.MOUSE_MOVE)
  self:registerEventListener(child, child.onJoystickDown, EventType.JOYSTICK_DOWN)
  self:registerEventListener(child, child.onJoystickUp, EventType.JOYSTICK_UP)
  self:registerEventListener(child, child.onJoystickAdd, EventType.JOYSTICK_ADD)
  self:registerEventListener(child, child.onJoystickRemove, EventType.JOYSTICK_REMOVE)
  self:registerEventListener(child, child.onWindowResize, EventType.WINDOW_RESIZE)
  self:registerEventListener(child, child.onPreDraw, EventType.PRE_DRAW)
end



--------------------------------------------------------------------------------
--                              EVENT SYSTEM                                  --
--------------------------------------------------------------------------------

--[[
Adds a function to the callback table, indexing by event type and by owning
object.

Additional parameters can be supplied that are context-sensitive. If
`eventType` is `DRAW`, then only one additional optional parameter will be
accepted: the layer at which to draw the object.

If `eventType` is `DESTROY`, then only one optional paramter will be accepted:
a previously registered object whose destruction is to be monitered.

- object: Table that "owns" the listener function
- listener: Function to be called on event trigger. The "object" parameter will
  be passed as the first argument, followed by any other parameters that are
  required for the given event type.
- eventType: type of event the listener is listening for.
]]
function class:registerEventListener(object, listener, eventType, ...)
  local arg = {...}
  
  -- Verify arguments
  assertType(object, "object", "table")
  assert(listener ~= nil, "Argument 'listener' cannot be nil")
  assert(eventType ~= nil, "Argument 'eventType' cannot be nil")
  eventType = EventType.fromId(eventType)
  assert(eventType ~= nil, "eventType must be a valid EventType")
  
  -- Verify optional arguments
  local drawLayer = class.DEFAULT_PRIORITY
  local watchObject = object
  
  if eventType == EventType.DRAW and arg[1] ~= nil then
    
    -- User is registering for drawing, optional parameter can be layer
    assertType(drawLayer, 'optional parameter 1', 'integer')
  elseif eventType == EventType.DESTROY and arg[1] ~= nil then
    
    -- Users is registering for desruction, optional parameter can be object to watch
    watchObject = arg[1]
    assertType(watchObject, "watchObject", Entity)
  end
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:push(self.registerEventListener, self, object, listener, eventType, unpack(arg))
    return
  end
  
  assert(watchObject == object or self.callbacks[watchObject] ~= nil)
  
  -- Create callback object
  local callback = {
    object = object,
    listener = listener,
    eventType = eventType,
    index = 0
  }
  
  -- Customize callback object based on callback type
  if eventType == EventType.DRAW then
    callback.drawLayer = drawLayer
  elseif eventType == EventType.DESTROY then
    callback.watchObject = watchObject
  end
  
  -- Insert callback into callback table indexed by event type
  local callbacks = self.callbacks[eventType]
  if eventType == EventType.DRAW then
    if not callbacks[drawLayer] then
      callbacks[drawLayer] = {n = 0}
    end
    callbacks = callbacks[drawLayer]
    self.layers:insert(drawLayer)
  elseif eventType == EventType.DESTROY then
    if callbacks[callback.watchObject] == nil then
      callbacks[callback.watchObject] = {n = 0}
    end
    callbacks = callbacks[callback.watchObject]
  end
  local n = callbacks.n + 1
  callbacks[n] = callback
  callbacks.n = n
  callback.index = n
  
  -- Create table entry for object if none exists
  if self.callbacks[object] == nil then
    self.callbacks[object] = {n = 0}
  end
  
  -- Insert callback into callback table indexed by calling object
  n = self.callbacks[object].n + 1
  self.callbacks[object][n] = callback
  self.callbacks[object].n = n
end



--[[
Moves an object's draw callback(s) to a new draw layer.

- object: Object whose draw function to move to drawLayer
- drawLayer: New layer to move draw callback to
- listener (optional): specific draw function to move to drawLayer in case 
  object has multiple draw callbacks registered
]]
function class:setDrawLayer(object, drawLayer, listener)
  
  -- Validate arguments
  assertType(object, "object", "table")
  assertType(drawLayer, "drawLayer", "integer")
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:push(self.setDrawLayer, self, object, drawLayer, listener)
    return
  end
  
  -- Make sure callbacks exist for the given object
  local callbacks = self.callbacks[object]
  if callbacks == nil then
    return
  end
  
  -- Search through object's callbacks for a match with parameters
  for i, callback in ipairs(callbacks) do
    if callback and
       callback.eventType == EventType.DRAW and
       (listener == nil or callback.listener == listener) and
       callback.drawLayer ~= drawLayer then
      
      -- Remove from old drawing layer
      self.callbacks[callback.eventType][callback.drawLayer][callback.index] = nil
      
      -- Insert into new layer at end of list
      if not self.callbacks[callback.eventType][drawLayer] then
        self.callbacks[callback.eventType][drawLayer] = {n = 0}
        self.layers:insert(drawLayer)
      end
      local newCallbacks = self.callbacks[callback.eventType][drawLayer]
      newCallbacks.n = newCallbacks.n + 1
      newCallbacks[newCallbacks.n] = callback
      
      -- Update values in callback
      callback.index = newCallbacks.n
      callback.drawLayer = drawLayer
    end
  end
end



--[[
Deletes all callbacks associated with the given object.

- object: The object to delete all registered callbacks for.
]]
function class:unregisterAllListeners(object)
  
  -- Validate arguments
  assertType(object, "object", "table")
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:push(self.unregisterAllListeners, self, object)
    return
  end
  
  -- Make sure callbacks exist for the given object
  local callbacks = self.callbacks[object]
  if callbacks == nil then
    return
  end
  
  -- Enqueue destroy callbacks for current object
  local destroyCallbacks = self.callbacks[EventType.DESTROY][object]
  if destroyCallbacks ~= nil then
    for i,callback in ipairs(destroyCallbacks) do
      if callback then
        self.queue:push(callback.listener, callback.object, callback.watchObject)
      end
    end
    self.callbacks[EventType.DESTROY][object] = nil
  end
  
  -- Remove each callback from it's eventType table
  for i,callback in ipairs(callbacks) do
    if callback then
      if callback.eventType == EventType.DRAW then
        self.callbacks[callback.eventType][callback.drawLayer][callback.index] = nil
      elseif callback.eventType == EventType.DESTROY then
        if self.callbacks[callback.eventType][callback.watchObject] ~= nil then
          self.callbacks[callback.eventType][callback.watchObject][callback.index] = nil
        end
      else
        self.callbacks[callback.eventType][callback.index] = nil
      end
    end
  end
  
  -- Remove this object from the callback table, finallizing the process
  self.callbacks[object] = nil
end



--[[
Sets the current pause status of the secretary

- paused: `true` if the secretary should be paused, `false` if it should become unpaused.
]]
function class:setPaused(paused)
  self.paused = paused
end



--[[
Gets whether the secretary is currently paused.

- returns: `true` if the secretary is paused, `false` if not.
]]
function class:isPaused()
  return self.paused
end



--------------------------------------------------------------------------------
--                               EVENT FUNCTIONS                              --
--------------------------------------------------------------------------------


-- Called every draw step
function class:onDraw()
  local emptyLayers = {}

  for layer in self.layers:values() do
    self:executeCallbacks(self.callbacks[EventType.DRAW][layer])
    if self.callbacks[EventType.DRAW][layer].n == 0 then
      table.insert(emptyLayers, layer)
    end
  end
  
  for _,layer in ipairs(emptyLayers) do
    self.layers:remove(layer)
    self.callbacks[EventType.DRAW][layer] = nil
  end
end

-- Called every game step
function class:onPreStep()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.PRE_STEP])
end

-- Called every game step
function class:onStep()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.STEP])
end

-- Called every game step
function class:onPostStep()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.POST_STEP])
end

-- Called before every physics event
function class:onPrePhysics()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.PRE_PHYSICS])
end

-- CAlled every step to execute physics
function class:onPhysics()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.PHYSICS])
end

-- Called after physics event
function class:onPostPhysics()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.POST_PHYSICS])
end

-- Called when framework is shutting down
function class:onShutdown()
  self:executeCallbacks(self.callbacks[EventType.SHUTDOWN])
end

-- Called when a keyboard button is pressed
function class:onKeyboardDown(key, scancode, isrepeat)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.KEYBOARD_DOWN], key, scancode, isrepeat)
end

-- Called when a keyboard button is released
function class:onKeyboardUp(key, scancode)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.KEYBOARD_UP], key, scancode )
end

-- Called when a mouse button is pressed
function class:onMouseDown(x, y, button, istouch)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.MOUSE_DOWN], x, y, button, istouch)
end

-- Called when a mouse button is released
function class:onMouseUp(x, y, button, istouch)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.MOUSE_UP], x, y, button, istouch)
end

-- Called when the mouse is moved
function class:onMouseMove(x, y, dx, dy, istouch)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.MOUSE_MOVE], x, y, dx, dy, istouch)
end

-- Called when the mouse wheel moves
function class:onMouseWheelMove(x, y)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.MOUSE_WHEEL], x, y)
end

-- Called when a joystick button is pressed
function class:onJoystickDown(joystick, button)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.JOYSTICK_DOWN], joystick, button)
end

-- Called when a joystick button is released
function class:onJoystickUp(joystick, button)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.JOYSTICK_UP], joystick, button)
end

-- Called when a joystick is connected
function class:onJoystickAdd(joystick)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.JOYSTICK_ADD], joystick)
end

-- Called when a joystick is released
function class:onJoystickRemove(joystick)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.JOYSTICK_REMOVE], joystick)
end

-- Called when the game window is resized
function class:onWindowResize(w, h)
  self:executeCallbacks(self.callbacks[EventType.WINDOW_RESIZE], w, h)
end

-- Called before draw events are executed
function class:onPreDraw()
  self:executeCallbacks(self.callbacks[EventType.PRE_DRAW])
end



--[[
Generic function that executes callbacks for a given event type.
Handles errors and takes any variable number of arguments and passes
them along to the callbacks.
]]
function class:executeCallbacks(callbacks, ...)
  local arg = {...}
  
  -- Prevent concurrent modification
  self.postpone = true
  
  -- Execute all registered callbacks registered with Secretary
  local lastIndex = 0
  for i = 1,callbacks.n do
    local callback = callbacks[i]
    
    -- Ensure callback exists
    if callback then
      
      -- Attempt to fill any gaps in table (in event of deleted objects)
      lastIndex = lastIndex + 1
      if lastIndex < i then
        callbacks[lastIndex] = callback
        callback.index = lastIndex
        callbacks[i] = nil
      end
      
      -- Convenience variables
      local listener = callback.listener
      local object = callback.object
      
      -- Use xpcall to prevent errors from destroying everything
      local success, errmessage = xpcall(
          function() return listener(object, unpack(arg)) end,
          catchError --[[ function to handle errors ]])
      
      -- If error occured, display traceback and continue
      if success == false then
        print("Caused by:", errmessage)
      end
    end
  end
  
  -- Enable direct modification of callback lists
  self.postpone = false
  
  -- If gaps were detected and closed, decrease size of callback table
  callbacks.n = lastIndex
  
  -- Empty any event queue we got
  self.queue:executeAll()
end
