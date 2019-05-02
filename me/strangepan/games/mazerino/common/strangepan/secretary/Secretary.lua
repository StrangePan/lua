require "me.strangepan.games.mazerino.common.strangepan.secretary.QuadTree"
require "me.strangepan.games.mazerino.common.strangepan.secretary.EventType"
require "me.strangepan.games.mazerino.common.strangepan.secretary.DrawLayer"
require "me.strangepan.games.mazerino.common.strangepan.secretary.Entity"
require "me.strangepan.games.mazerino.common.strangepan.secretary.PhysObject"
require "me.strangepan.games.mazerino.common.strangepan.util.class"
require "me.strangepan.games.mazerino.common.strangepan.util.functions"
require "me.strangepan.games.mazerino.common.strangepan.util.type"
require "me.strangepan.games.mazerino.common.strangepan.util.SortedSet"
require "me.strangepan.games.mazerino.common.strangepan.util.FunctionQueue"

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
  assertClass(object, PhysObject, "object")
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
  assertClass(object, PhysObject, "object")
  
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
  assertClass(child, Secretary, "child")
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
  assertTable(object, "object")
  assert(listener ~= nil, "Argument 'listener' cannot be nil")
  assert(eventType ~= nil, "Argument 'eventType' cannot be nil")
  eventType = EventType.fromId(eventType)
  assert(eventType ~= nil, "eventType must be a valid EventType")
  
  -- Verify optional arguments
  local priority = class.DEFAULT_PRIORITY
  local watchObject = object
  
  if eventType == EventType.DESTROY and arg[1] ~= nil then
    -- Users is registering for desruction, optional parameter can be object to watch
    assertClass(arg[1], Entity, 'optional parameter 1')
    watchObject = arg[1]
    
    -- second optional parameter can be priority
    if arg[2] ~= nil then
      assertInteger(arg[2], 'optional parameter 2')
      priority = arg[2]
    end
  elseif arg[1] ~= nil then
    -- Optional parameter can be layer
    assertInteger(arg[1], 'optional parameter 1')
    priority = arg[1]
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
    index = 0,
    priority = priority,
    watchObject = eventType == EventType.DESTROY and watchObject or nil
  }
  
  -- Insert callback into callback table indexed by event type
  if not self.callbacks[eventType] then
    self.callbacks[eventType] = {}
  end
  local callbacks = self.callbacks[eventType]

  if eventType == EventType.DESTROY then
    if not callbacks[callback.watchObject] then
      callbacks[callback.watchObject] = {}
    end
    callbacks = callbacks[callback.watchObject]
  end
  
  if not callbacks.priorities then
    callbacks.priorities = SortedSet()
  end

  if not callbacks[priority] then
    callbacks[priority] = {n = 0}
    callbacks.priorities:insert(priority)
  end
  callbacks = callbacks[priority]

  local n = callbacks.n + 1
  callbacks[n] = callback
  callback.index = n
  callbacks.n = n

  -- Create table entry for object if none exists
  if not self.callbacks[object] then
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
  self:setEventPriority(object, listener, EventType.DRAW, drawLayer)
end

function class:setEventPriority(object, listener, eventType, priority, watchObject)
  
  -- Validate arguments
  assertTable(object, "object")
  if listener then
    assertFunction(listener, "listener")
  end
  assert(EventType.fromId(eventType), "eventType must be a valid EventType: "..eventType.." received.")
  assertInteger(priority, "priority")
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:push(self.setDrawLayer, self, object, listener, priority, watchObject)
    return
  end
  
  -- Make sure callbacks exist for the given object
  local callbacks = self.callbacks[object]
  if not callbacks then
    return
  end
  
  -- Search through object's callbacks for a match with parameters
  for i, callback in ipairs(callbacks) do
    if callback
        and callback.eventType == eventType
        and (listener == nil or callback.listener == listener)
        and (watchObject == nil or callback.watchObject == watchObject) then
      
      -- Remove from old priority layer
      local oldCallbacks = self.callbacks[callback.eventType]
      if callback.eventType == EventType.DESTROY then
        oldCallbacks = oldCallbacks[callback.watchObject]
      end
      oldCallbacks = oldCallbacks[callback.priority]
      oldCallbacks[callback.index] = nil
      
      -- Insert into new priority layer at end of list
      local newCallbacks = self.callbacks[callback.eventType]
      if callback.eventType == EventType.DESTROY then
        newCallbacks = newCallbacks[callback.watchObject]
      end
      if not newCallbacks[priority] then
        newCallbacks[priority] = {n = 0}
        newCallbacks.priorities:insert(priority)
      end
      newCallbacks = newCallbacks[priority]
      newCallbacks.n = newCallbacks.n + 1
      newCallbacks[newCallbacks.n] = callback
      
      -- Update values in callback
      callback.index = newCallbacks.n
      callback.priority = priority
    end
  end
end



--[[
Deletes all callbacks associated with the given object.

- object: The object to delete all registered callbacks for.
]]
function class:unregisterAllListeners(object)
  
  -- Validate arguments
  assertTable(object, "object")
  
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
  local destroyCallbacks = (self.callbacks[EventType.DESTROY]
      and self.callbacks[EventType.DESTROY][object])
  if destroyCallbacks then
    for priority in destroyCallbacks.priorities:values() do
      for i,callback in ipairs(destroyCallbacks[priority]) do
        if callback then
          self.queue:push(callback.listener, callback.object, callback.watchObject)
        end
      end
    end
    self.callbacks[EventType.DESTROY][object] = nil
  end
  
  -- Remove each callback from its eventType table
  for i,callback in ipairs(callbacks) do
    if callback then
      if callback.eventType == EventType.DESTROY
          and self.callbacks[callback.eventType][callback.watchObject] then
        self.callbacks[callback.eventType][callback.watchObject][callback.priority][callback.index] = nil
      else
        self.callbacks[callback.eventType][callback.priority][callback.index] = nil
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
  self:executeCallbacks(self.callbacks[EventType.DRAW])
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
  
  if not callbacks then return end
  
  -- Prevent concurrent modification
  self.postpone = true
  
  -- Empty priority layers that will be cleaned up after execution
  local emptyLayers = {}
  
  -- Execute all callbacks registered with Secretary
  for priority in callbacks.priorities:values() do
    
    local lastIndex = 0
    for i = 1,callbacks[priority].n do
      local callback = callbacks[priority][i]
      
      -- Ensure callback exists
      if callback then
        -- Attempt to fill any gaps in table (in event of deleted objects)
        lastIndex = lastIndex + 1
        if lastIndex < i then
          callbacks[priority][lastIndex] = callback
          callback.index = lastIndex
          callbacks[priority][i] = nil
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
  
  -- If gaps were detected and closed, decrease size of callback table
    callbacks[priority].n = lastIndex
    if callbacks[priority].n == 0 then
      table.insert(emptyLayers, priority)
    end
  end
  
  -- Clean up any empty priority layers
  for _,priority in ipairs(emptyLayers) do
    callbacks.priorities:remove(priority)
    callbacks[priority] = nil
  end
  
  -- Enable direct modification of callback lists
  self.postpone = false
  
  -- Empty any event queue we got
  self.queue:executeAll()
end
