GRID_SIZE = 32

-- Converts any number of game coordinates to screen coordinates.
function toScreen(...)
  local results = {}
  for i,v in ipairs({...}) do
    results[i] = v * GRID_SIZE
  end
  return unpack(results)
end
