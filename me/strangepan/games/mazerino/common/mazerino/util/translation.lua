local translation = {}

local GRID_SIZE = 32

-- Private helper function that applies a mapping function to an array and returns it.
local function map(mapping_function, values)
  for i,v in ipairs(values) do
    values[i] = mapping_function(v)
  end
  return values
end

-- Converts any number of game coordinates to screen coordinates.
function translation.toScreen(...)
  return unpack(map(function(v) return v * GRID_SIZE end, {...}))
end

-- Converts any number of screen coordinates to game coordinates, floored.
function translation.toGrid(...)
  return unpack(map(function(v) return math.floor(v / GRID_SIZE) end, {...}))
end

return translation
