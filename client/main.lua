package.path = package.path .. ";./common/?.lua;./common/entities/?.lua;./common/networking/?.lua"

require "LoveSecretary"
require "Player"
require "Wall"
require "Camera"
require "ClientConnectionManager"
require "CustomNetworkedEntityManager"
require "CommandMap"
require "LocalPlayerController"

local connection

function love.load()
  rootSecretary = LoveSecretary():captureLoveEvents()
  camera = Camera():registerWithSecretary(rootSecretary)
  player = Player():registerWithSecretary(rootSecretary)
  commandMap = CommandMap()
  playerController = LocalPlayerController(player, commandMap)
  
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
  entityManager = CustomNetworkedEntityManager(connection):registerWithSecretary(rootSecretary)
  connection:connectToServer()
  
  rootSecretary:registerEventListener(
    connection,
    connection.receiveAllMessages,
    EventType.PRE_STEP)
  rootSecretary:registerEventListener(
    connection,
    connection.terminateAllConnections,
    EventType.SHUTDOWN)
end
