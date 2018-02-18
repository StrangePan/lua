require 'strangepan.util.class'
require 'strangepan.util.type'
require 'entities.Player'
require 'entities.Switch'
require 'entities.Wall'
local GameMap = buildClass()

-- Instantiates an entity of the given type at the given game map coordinates.
local function createEntity(code, x, y)
  if code == "1" then
    return Wall(x, y)
  elseif code == "2" then
    local player = Player()
    player:setPosition(x, y)
    return player
  elseif code == "3" then
    return Switch(x, y)
  end
  return nil
end

-- Opens the file at the given path and instantiates entities according to the codes in the file.
function GameMap.createFromFile(filename)
  assertString(filename, 'filename')
  local file = io.open(filename, 'r')
  local entities = {}
  local y = -1

  for line in file:lines() do
    y = y + 1
    local x = -1

    for i = 1,#line do
      x = x + 1
      local c = line:sub(i, i)
      local e = createEntity(c, x, y)
      if e then
        table.insert(entities, e)
      end
    end
  end

  local gameMap = GameMap()
  gameMap.entities = entities
  return gameMap
end

-- A simple container that contains a list of entities.
function GameMap:_init()
  self.entities = {}
end

return GameMap