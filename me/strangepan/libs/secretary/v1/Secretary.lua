local QuadTree = require "me.strangepan.libs.secretary.v1.QuadTree"
local EventType = require "me.strangepan.libs.secretary.v1.EventType"
local Entity = require "me.strangepan.libs.secretary.v1.Entity"
local PhysObject = require "me.strangepan.libs.secretary.v1.PhysObject"
local class = require "me.strangepan.libs.util.v1.class"
local SortedSet = require "me.strangepan.libs.data.v1.sorted_set"
local FunctionQueue = require "me.strangepan.libs.data.v1.function_queue"
local assert_that = require "me.strangepan.libs.truth.v1.assert_that"

local Secretary = class.build()

Secretary.DEFAULT_PRIORITY = 1



function Secretary:_init()
  
  -- Collision detection data structure
  self.tree = QuadTree(1, -1000, 1000, 1000, -1000)
  
  self.paused = false
  self.objectNodes = {}  -- table containing direct references to object quadtree nodes
  self.callbacks = {}    -- table containing all callbacks
  self.queue = FunctionQueue()
  self.postpone = false
end





--------------------------------------------------------------------------------
--                            COLLISION SYSTEM                                --
--------------------------------------------------------------------------------

--[[
Registers a new PhysObject with the Secretary.

object: The new object to track collisions with.
]]
function Secretary:registerPhysObject(object)
  
  -- Validate arguments
  assert_that(object):is_instance_of(PhysObject)
  assert(self.objectNodes[object] == nil, "Object already registered with the secretary")
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:enqueue(self.registerPhysObject, self, object)
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
function Secretary:unregisterPhysObject(object)
  
  -- Validate arguments
  assert_that(object):is_instance_of(PhysObject)
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:enqueue(self.unregisterPhysObject, self, object)
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
function Secretary:updateObject(object)
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
function Secretary:getCollisions(top, right, bottom, left, front, back, ...)
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

function Secretary:remove(object)
  if class.instance_of(object, PhysObject) then
    self:unregisterPhysObject(object)
  end
  self:unregisterAllListeners(object)
end



function Secretary:registerChildSecretary(child)
  
  -- Validate parameters
  assert_that(child):is_instance_of(Secretary)
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
function Secretary:registerEventListener(object, listener, eventType, ...)
  local arg = {...}
  
  -- Verify arguments
  assert_that(object):is_a_table()
  assert(listener ~= nil, "Argument 'listener' cannot be nil")
  assert(eventType ~= nil, "Argument 'eventType' cannot be nil")
  eventType = assert_that(eventType):is_a_number():is_a_key_in(EventType):and_return()
  assert(eventType ~= nil, "eventType must be a valid EventType")
  
  -- Verify optional arguments
  local priority = Secretary.DEFAULT_PRIORITY
  local watchObject = object
  
  if eventType == EventType.DESTROY and arg[1] ~= nil then
    -- Users is registering for desruction, optional parameter can be object to watch
    assert_that(arg[1]):is_instance_of(Entity)
    watchObject = arg[1]
    
    -- second optional parameter can be priority
    if arg[2] ~= nil then
      assert_that(arg[2]):is_a_number()
      priority = arg[2]
    end
  elseif arg[1] ~= nil then
    -- Optional parameter can be layer
    assert_that(arg[1]):is_a_number()
    priority = arg[1]
  end
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:enqueue(self.registerEventListener, self, object, listener, eventType, unpack(arg))
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
    callbacks.priorities:add(priority)
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
function Secretary:setDrawLayer(object, drawLayer, listener)
  self:setEventPriority(object, listener, EventType.DRAW, drawLayer)
end

function Secretary:setEventPriority(object, listener, eventType, priority, watchObject)
  
  -- Validate arguments
  assert_that(object):is_a_table()
  if listener then
    assert_that(listener):is_a_function()
  end
  assert_that(eventType):is_a_number():is_a_key_in(EventType)
  assert_that(priority):is_a_number()
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:enqueue(self.setDrawLayer, self, object, listener, priority, watchObject)
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
        newCallbacks.priorities:add(priority)
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
function Secretary:unregisterAllListeners(object)
  
  -- Validate arguments
  assert_that(object):is_a_table()
  
  -- Postpone if processing events
  if self.postpone then
    self.queue:enqueue(self.unregisterAllListeners, self, object)
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
    for priority in destroyCallbacks.priorities:items() do
      for i,callback in ipairs(destroyCallbacks[priority]) do
        if callback then
          self.queue:enqueue(callback.listener, callback.object, callback.watchObject)
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
function Secretary:setPaused(paused)
  self.paused = paused
end



--[[
Gets whether the secretary is currently paused.

- returns: `true` if the secretary is paused, `false` if not.
]]
function Secretary:isPaused()
  return self.paused
end



--------------------------------------------------------------------------------
--                               EVENT FUNCTIONS                              --
--------------------------------------------------------------------------------


-- Called every draw step
function Secretary:onDraw()
  self:executeCallbacks(self.callbacks[EventType.DRAW])
end

-- Called every game step
function Secretary:onPreStep()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.PRE_STEP])
end

-- Called every game step
function Secretary:onStep()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.STEP])
end

-- Called every game step
function Secretary:onPostStep()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.POST_STEP])
end

-- Called before every physics event
function Secretary:onPrePhysics()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.PRE_PHYSICS])
end

-- CAlled every step to execute physics
function Secretary:onPhysics()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.PHYSICS])
end

-- Called after physics event
function Secretary:onPostPhysics()
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.POST_PHYSICS])
end

-- Called when framework is shutting down
function Secretary:onShutdown()
  self:executeCallbacks(self.callbacks[EventType.SHUTDOWN])
end

-- Called when a keyboard button is pressed
function Secretary:onKeyboardDown(key, scancode, isrepeat)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.KEYBOARD_DOWN], key, scancode, isrepeat)
end

-- Called when a keyboard button is released
function Secretary:onKeyboardUp(key, scancode)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.KEYBOARD_UP], key, scancode )
end

-- Called when a mouse button is pressed
function Secretary:onMouseDown(x, y, button, istouch)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.MOUSE_DOWN], x, y, button, istouch)
end

-- Called when a mouse button is released
function Secretary:onMouseUp(x, y, button, istouch)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.MOUSE_UP], x, y, button, istouch)
end

-- Called when the mouse is moved
function Secretary:onMouseMove(x, y, dx, dy, istouch)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.MOUSE_MOVE], x, y, dx, dy, istouch)
end

-- Called when the mouse wheel moves
function Secretary:onMouseWheelMove(x, y)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.MOUSE_WHEEL], x, y)
end

-- Called when a joystick button is pressed
function Secretary:onJoystickDown(joystick, button)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.JOYSTICK_DOWN], joystick, button)
end

-- Called when a joystick button is released
function Secretary:onJoystickUp(joystick, button)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.JOYSTICK_UP], joystick, button)
end

-- Called when a joystick is connected
function Secretary:onJoystickAdd(joystick)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.JOYSTICK_ADD], joystick)
end

-- Called when a joystick is released
function Secretary:onJoystickRemove(joystick)
  if self.paused then return end
  self:executeCallbacks(self.callbacks[EventType.JOYSTICK_REMOVE], joystick)
end

-- Called when the game window is resized
function Secretary:onWindowResize(w, h)
  self:executeCallbacks(self.callbacks[EventType.WINDOW_RESIZE], w, h)
end

-- Called before draw events are executed
function Secretary:onPreDraw()
  self:executeCallbacks(self.callbacks[EventType.PRE_DRAW])
end



--[[
Generic function that executes callbacks for a given event type.
Handles errors and takes any variable number of arguments and passes
them along to the callbacks.
]]
function Secretary:executeCallbacks(callbacks, ...)
  local arg = {...}
  
  if not callbacks then return end
  
  -- Prevent concurrent modification
  self.postpone = true
  
  -- Empty priority layers that will be cleaned up after execution
  local emptyLayers = {}
  
  -- Execute all callbacks registered with Secretary
  for priority in callbacks.priorities:items() do
    
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
  self.queue:poll_all()
end

return Secretary
