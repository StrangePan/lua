
--
-- Test if argument 1 is an instance of argument 2
-- Returns `true` or `false`
--
function instanceOf(object, class)
  while object ~= nil and class ~= nil do
    if object == class then
      return true
    else
      --Compares all parent classes
      object = getmetatable(object)
    end
  end
  --No match found
  return false
end

--
-- Function for catching errors and returning the traceback (AKA stack trace).
--
function catchError(err)
  if debug then
    return err..debug.traceback().."\n"
  end
end

--
-- Convenience function for type assertions
--
-- Value to check
-- String name of value (optional)
-- Type to check against; can be a Class or a primitive type name
--
-- return: If assertion is true, returns the original value. Otherwise, throws
--         an assertion.
--
function assertType(value, name, t)

  -- name is optional, meaning if t is nil, then t = name
  if not t then
    t = name
    name = nil
  end

  local errMsg = nil
  
  if type(t) == "table" then
    assertType(value, name, "table")
    if not instanceOf(value, t) then
      if name then
        errMsg = "Unexpected type for "..name..": Object not instance of "
            .."expected type."
      else
        errMsg = "Unexpected type: Object not instance of expected type."
      end
    end
  elseif type(t) == "string" then
    if type(value) ~= t then
      if name then
        errMsg = "Unexpected type for "..name..": "..t.." expected, "
            ..type(object).." received."
      else
        errMsg = "Unexpected type: "..t.." expected, "
            ..type(object).." received."
      end
    end
  end
  
  if errMsg then
    assert(false, errMsg)
  end
  return value
end
