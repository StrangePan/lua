require "common/class"
require "Camera"
require "Player"
require "Secretary"
require "ClientConnectionManager"
require "NetworkedEntityManager"
require "CommandMap"
require "LocalPlayerController"

ClientGame = buildClass()
local Class = ClientGame

function Class:_init(secretary, connectionManager, entityManager)
  Class.superclass._init(self)
  assertType(secretary, "secretary", Secretary)
  assertType(connectionManager, "connectionManager", ClientConnectionManager)
  assertType(entityManager, "entityManager", NetworkedEntityManager)

  self.secretary = secretary
  self.connections = connectionManager
  self.entities = entityManager

  -- Register for network callbacks
  self.connections:registerConnectionStatusListener(
      self,
      self.onConnectionStatusChanged)
  
  self.lastSpinTime = love.timer.getTime()
  self.playerController = LocalPlayerController()

  -- Set up command map for player
  local commandMap = CommandMap()
  self.commandMap = commandMap
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_UP, "up")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_RIGHT, "right")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_DOWN, "down")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_LEFT, "left")
  commandMap:mapCommandToKeyboardKey(CommandType.EMOTE_SPIN, "space")

  self.playerController:setCommandMap(commandMap)
end

function Class:start()
  local secretary = self.secretary
  local connections = self.connections
  local commandMap = self.commandMap
  local entities = self.entities

  self.player = Player():registerWithSecretary(secretary)
  local player = self.player
  local px, py = player:getPosition()
  local pw, ph = player:getSize()

  self.camera = Camera():registerWithSecretary(secretary)
  local camera = self.camera
  camera:setSubject(player)
  camera:jumpTo(px + pw / 2, py + ph / 2)

  -- Hook up entity manager to secretary
  entities:registerWithSecretary(secretary)
  
  -- Hook up connection manager to secretary.
  secretary:registerEventListener(
    connections,
    connections.receiveAllMessages,
    EventType.PRE_STEP)
  secretary:registerEventListener(
    connections,
    connections.terminateAllConnections,
    EventType.SHUTDOWN)
  
  -- Hook command map up to secretary
  secretary:registerEventListener(
    self.commandMap,
    function(commandMap, key, scancode, isrepeat)
      if isrepeat == false then
        commandMap:onKeyboardInput(key)
      end
    end,
    EventType.KEYBOARD_DOWN)
  
  -- Hook up self to secretary
  secretary:registerEventListener(
    self,
    self.onStep,
    EventType.STEP)
  
  -- Initialize connection to server
  connections:connectToServer()
end

function Class:stop()
  local secretary = self.secretary
  local connections = self.connections
  local entities = self.entities
  local commandMap = self.commandMap
  local player = self.player
  local camera = self.camera
  
  entities:destroy()
  connections:destroy()
  self:destroy()
  commandMap:destroy()
  player:destroy()
  camera:destroy()
end



function Class:onStep()
  local time = love.timer.getTime()
  local connection = self.connections:getServerConnection()
  
  if connection
      and connection.status == ConnectionStatus.CONNECTING
      and self.lastSpinTime < time - 1.75 then
    self.lastSpinTime = time
    self.player:spin()
  end
end

function Class:onConnectionStatusChanged(manager, connectionId, oldStatus)
  local server = self.connections:getServerConnection()
  if not server or server.id ~= connectionId then
    return
  end
  
  -- Give local player control when connected
  if server.status == ConnectionStatus.CONNECTED then
    self.playerController:setPlayer(self.player)
  else
    self.playerController:setPlayer(nil)
  end
end
