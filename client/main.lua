package.path = package.path .. ";./common/?.lua"

require "Secretary"
require "Player"
require "Wall"
require "Camera"
require "ClientConnectionManager"
require "EntityConnectionManager"
require "CommandMap"
require "LocalPlayerController"

rootSecretary = Secretary()

require "loveevents"

local connection

function love.load()
  camera = Camera():registerWithSecretary(rootSecretary)
  player = Player():registerWithSecretary(rootSecretary)
  commandMap = CommandMap()
  playerController = LocalPlayerController(player, commandMap)
  buildWalls()
  
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_UP, "up")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_RIGHT, "right")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_DOWN, "down")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_LEFT, "left")
  commandMap:mapCommandToKeyboardKey(CommandType.EMOTE_SPIN, "space")
  
  rootSecretary:registerEventListener({}, function()
      local px, py = player:getPosition()
      local pw, ph = player:getSize()
      camera:moveTo(px+(pw/2), py+(ph/2))
    end, EventType.STEP)
  
  rootSecretary:registerEventListener({}, function(_, key, scancode, isrepeat)
      if isrepeat == false then
        commandMap:onKeyboardInput(key)
      end
    end, EventType.KEYBOARD_DOWN)
  
  connection = ClientConnectionManager()
  EntityConnectionManager(connection):registerWithSecretary(rootSecretary)
  connection:connectToServer()
end

function buildWalls()
  local wallCodes = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  }
  
  for wallY,row in ipairs(wallCodes) do
    for wallX,wallCode in ipairs(row) do
      if wallCode == 1 then
        local newWall = Wall()
        newWall:setPosition((wallX - 1) * 32, (wallY - 1) * 32)
        newWall:registerWithSecretary(rootSecretary)
      end
    end
  end
end
