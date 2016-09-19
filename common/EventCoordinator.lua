require "common/class"
require "Entity"

EventCoordinator = buildClass()

function EventCoordinator:_init()
  self.listeners = {n = 1}
end

function EventCoordinator:registerListener(object, callback)
  
  -- verify argument types
  if type(object) ~= "table" then object = nil end
  if type(callback) ~= "function" then return end
  
  if object ~= nil then
    if self.listeners[object] == nil then
      self.listeners[object] = {n = 1}
    end
    self.listeners[object][self.listeners[object].n] = callback
    self.listeners[object].n = self.listeners[object].n + 1
    
    -- register for destroy callbacks with the secretary
    local secretary = self:getSecretary()
    if secretary ~= nil then
      secretary:registerEventListener(self, self.unregisterListener, EventType.DESTROY, object)
    end
  else
    -- if no object is given
    self.listeners[self.listeners.n] = callback
    self.listeners.n = self.listeners.n + 1
  end
end

function EventCoordinator:unregisterListener(object, callback)
  
  -- verify argument types
  if type(object) ~= "table" then object = nil end
  if type(callback) ~= "function" then callback = nil end
  
  if object ~= nil and callback ~= nil then
    if self.listeners[object] ~= nil then
      for i,entry in ipairs(self.listeners[object]) do
        if entry == callback then
          self.listeners[object][i] = nil
          return
        end
      end
    end
  elseif object ~= nil and callback == nil then
    self.listeners[object] = nil
  elseif object == nil and callback ~= nil then
    for i,entry in ipairs(self.listeners) do
      if entry == callback then
        self.listeners[i] = nil
        return
      end
    end
  end
end

function EventCoordinator:notifyListeners(...)
  local arg = {...}
  
  for i,entry in pairs(self.listeners) do
    if type(i) == "number" then
      entry(unpack(arg))
    else
      for _,callback in ipairs(entry) do
        callback(i, unpack(arg))
      end
    end
  end
end
