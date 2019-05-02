require "me.strangepan.games.mazerino.common.strangepan.util.type"
require "me.strangepan.games.mazerino.common.strangepan.util.class"
require "me.strangepan.games.mazerino.common.strangepan.secretary.Entity"

EventCoordinator = buildClass(Entity)

function EventCoordinator:_init()
  self.listeners = {n = 0}
end



function EventCoordinator:registerListener(object, callback)
  
  -- verify argument types
  if type(object) ~= "table" then object = nil end
  if type(callback) ~= "function" then return end
  
  if object ~= nil then
    if self.listeners[object] == nil then
      self.listeners[object] = {n = 0}
    end
    self.listeners[object].n = self.listeners[object].n + 1
    self.listeners[object][self.listeners[object].n] = callback
    
    -- register for destroy callbacks with the secretary
    if checkType(object, Entity) then
      local secretary = self:getSecretary()
      if secretary ~= nil then
        secretary:registerEventListener(self, self.unregisterListener, EventType.DESTROY, object)
      end
    end
  else
    -- if no object is given
    self.listeners.n = self.listeners.n + 1
    self.listeners[self.listeners.n] = callback
  end
end



function EventCoordinator:unregisterListener(object, callback)
  
  -- verify argument types
  if type(object) ~= "table" then object = nil end
  if type(callback) ~= "function" then callback = nil end
  
  if object and callback then
    if self.listeners[object] then
      for i,entry in ipairs(self.listeners[object]) do
        if entry == callback then
          table.remove(self.listeners[object], i)
          self.listeners[object].n = self.listeners[object].n - 1
          return
        end
      end
    end
  elseif object and not callback then
    self.listeners[object] = nil
  elseif callback and not object then
    for i,entry in ipairs(self.listeners) do
      if entry == callback then
        table.remove(self.listeners, i)
        self.listeners.n = self.listeners.n - 1
        return
      end
    end
  end
end



function EventCoordinator:notifyListeners(...)
  local arg = {...}
  
  for i,entry in pairs(self.listeners) do
    if type(entry) == "number" then
      -- do nothing
    elseif type(i) == "number" then
      entry(unpack(arg))
    else
      for _,callback in ipairs(entry) do
        callback(i, unpack(arg))
      end
    end
  end
end
