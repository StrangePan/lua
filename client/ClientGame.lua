require "common/class"
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
      self.onN)
  
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

function Class:run()
  local secretary = self.secretary
  local connections = self.connections
  local commandMap = self.commandMap
  local entities = self.entities
  
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
  rootSecretary:registerEventListener(
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
  
  secretary:remove(entities)
  secretary:remove(connections)
  secretary:remove(self)
  secretary:remove(commandMap)
end



function Class:onStep()
  local time = love.timer.getTime()
  local connection = self.connections:getServerConnection()
  
  if connection
      and connection.status == ConnectionStatus.CONNECTING
      and self.lastSpinTime < time - 2 then
    self.lastSpinTime = time
    player:spin()
  end
end

function Class:onConnectionStatusChanged(manager, connectionId, oldStatus)
  local server = self.connections:getServerConnection()
  if not server or server.id ~= connectionId then
    return
  end
  
  -- Give local player control when connected
  if server.status == ConnectionStatus.CONNECTED then
    self.playerController:setPlayer(player)
  else
    self.playerController:setPlayer(nil)
  end
end
