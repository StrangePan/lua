require "strangepan.util.class"

Entity = buildClass()
local Class = Entity

--------------------------------------------------------------------------------
--                                Entity Class                                --
--------------------------------------------------------------------------------



--
-- `Entity` constructor. Initializes data members.
--
function Class:_init()
  Class.superclass._init(self)
  
  -- Assigned secretary object
  self.secretary = nil
end



--
-- Registers this entity with a `Secretary` object. This will also deregister this
-- object from any previously registered `Secretary`.
--
-- Parameter secretary: The `Secretary` object to register with.
--
-- Return: This same object so that this method can be called inline without
--         affecting normal function.
--
function Class:registerWithSecretary(secretary)
  
  -- Ensure secretary is of correct type
  assertType(secretary, "secretary", Secretary)
  
  -- Make sure we're not already registered with a secretary
  if self.secretary ~= nil then
    self:deregisterWithSecretary()
  end
  
  -- Store reference to secretary we are registered with
  self.secretary = secretary
  
  return self
end



--
-- Unregisters this object from the `Secretary` object it had been previously
-- registered with using the `registerWithSecretary()` method, if any.
--
function Class:deregisterWithSecretary()
  
  -- Remove all record of self from current secretary
  if self.secretary ~= nil then
    self.secretary:remove(self)
  end
  
  -- Forget registered secretary
  self.secretary = nil
end



--
-- Gets the `Secretary` object with which this object has been previously
-- registered using a call to the `registerWithSecretary()` method.
--
-- Return: The `Secretary` object that this object is registered with or `nil`
--         if this object has not been registered or if
--         `deregisterWithSecretary()` has been more recently called.
--
function Class:getSecretary()
  return self.secretary
end



--
-- Performs any necessary self-destruction steps, including deregistering this
-- object from any known `Secretary` objects.
--
function Class:destroy()
  self:deregisterWithSecretary()
end
