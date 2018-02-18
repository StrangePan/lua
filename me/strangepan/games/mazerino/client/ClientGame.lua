require "NetworkGame"
require "Camera"
require "entities.Actor"
require "entities.Player"
require "strangepan.secretary.Secretary"
require "strangepan.util.type"
require "ClientConnectionManager"
require "CommandMap"
require "LocalPlayerController"

ClientGame = buildClass(NetworkGame)
local Class = ClientGame

function Class:_init(secretary, connectionManager, entityManager)
  Class.superclass._init(self, secretary, connectionManager, entityManager)
  assertClass(connectionManager, ClientConnectionManager, "connectionManager")

  self.lastSpinTime = love.timer.getTime()
  self.idleActor = Actor()
  self.localPlayers = {n = 0}
  self.playerId = nil

  -- Set up command map for player
  local commandMap = CommandMap()
  self.commandMap = commandMap
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_UP, "up")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_RIGHT, "right")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_DOWN, "down")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_LEFT, "left")
  commandMap:mapCommandToKeyboardKey(CommandType.EMOTE_SPIN, "space")

  local connections = self:getConnectionManager()
  connections:registerConnectionStatusListener(
      self,
      self.onConnectionStatusChanged)
end

function Class:start()
  Class.superclass.start(self)
  local secretary = self:getSecretary()
  local connections = self:getConnectionManager()
  local entityManager = self:getEntityManager()
  local commandMap = self.commandMap

  self.idleActor:registerWithSecretary(secretary)
  local idleActor = self.idleActor

  self.camera = Camera():registerWithSecretary(secretary)
  local camera = self.camera
  camera:setSubject(idleActor)
  camera:jumpToSubject(idleActor)

  -- Hook command map up to secretary
  secretary:registerEventListener(
    self.commandMap,
    function(commandMap, key, scancode, isrepeat)
      if not isrepeat then
        commandMap:onKeyboardInput(key)
      end
    end,
    EventType.KEYBOARD_DOWN)
  
  -- Hook up to entity manager, listen up for players
  entityManager:registerEntityCreateListener(
      self, self.onPlayerCreate, NetworkedEntityType.PLAYER)
  entityManager:registerEntityDeleteListener(
      self, self.onPlayerCreate, NetworkedEntityType.PLAYER)

  -- Hook up self to secretary
  secretary:registerEventListener(self, self.onStep, EventType.STEP)

  -- Initialize connection to server
  connections:connectToServer()

  return self
end

function Class:stop()
  Class.superclass.stop(self)
  local entityManager = self:getEntityManager()
  local commandMap = self.commandMap
  local idleActor = self.idleActor
  local camera = self.camera

  -- Hook up to entity manager, listen up for players
  entityManager:unregisterEntityCreateListener(
      self, self.onPlayerCreate, NetworkedEntityType.PLAYER)
  entityManager:unregisterEntityDeleteListener(
      self, self.onPlayerCreate, NetworkedEntityType.PLAYER)

  self:destroy()
  commandMap:destroy()
  idleActor:destroy() -- note: reference to this is retained in case restarted
  camera:destroy()
  return self
end



function Class:onStep()
  local time = love.timer.getTime()
  local connections = self:getConnectionManager()
  local connection = connections:getServerConnection()
  
  if connection
      and connection.status == ConnectionStatus.CONNECTING
      and self.lastSpinTime < time - 2 then
    self.lastSpinTime = time
    self.idleActor:spin()
  end
end

function Class:onPlayerCreate(entityManager, networkedPlayer)
  if networkedPlayer:getOwnerId() ~= self:getConnectionManager().playerId then
    return
  end
  
  -- We are the player's controller; set things up properly.
  local player = networkedPlayer:getLocalEntity()
  local controller = LocalPlayerController(player, self.commandMap)
  table.insert(self.localPlayers, {
      controller = controller,
      player = networkedPlayer,
    })
  networkedPlayer:startBroadcastingUpdates()
  
  self.idleActor:destroy()
  
  self.camera:setSubject(player)
  self.camera:jumpToSubject(player)
end

function Class:onPlayerDestroy(entityManager, networkedPlayer)
  if networkedPlayer:getOwnerId() ~= self:getConnectionManager().playerId then
    return
  end

  for i,localPlayer in ipairs(self.localPlayers) do
    if localPlayer.player == networkedPlayer then
      localPlayer.controller:setPlayer(nil)
      localPlayer.controller:setCommandMap(nil)
      table.remove(localPlayer, i)
      break
    end
  end
  
  if table.getn(self.localPlayers) == 0 then
    self.idleActor:registerWithSecretary(self:getSecretary())
  end
end

function Class:onServerConnected(connectionId)
  local entities = self:getEntityManager()
  entities:addConnection(connectionId)
end

function Class:onServerStalled(connectionId)
  for _,localPlayer in ipairs(self.localPlayers) do
    localPlayer.controller:setPlayer(nil)
    localPlayer.player:stopBroadcastingUpdates()
  end
end

function Class:onServerReconnected(connectionId)
  for _,localPlayer in ipairs(self.localPlayers) do
    localPlayer.controller:setPlayer(localPlayer.player:getLocalEntity())
    localPlayer.player:startBroadcastingUpdates()
  end
end

function Class:onServerDisconnected(connectionId)
  local entities = self:getEntityManager()
  entities:removeConnection(connectionId)
end

--
-- Handles a change in connection status.
--
function Class:onConnectionStatusChanged(manager, connectionId, oldStatus)
  local connections = self:getConnectionManager()
  local connection = connections:getConnection(connectionId)
  if not connection then
    return
  end
  
  -- Only respond to connection events to the server
  if connections:getServerConnection() ~= connection then
    return
  end
  
  -- Give local player control when connected
  if connection.status == ConnectionStatus.CONNECTED
      and oldStatus ~= ConnectionStatus.STALLED then
    self:onServerConnected(connectionId)
  elseif connection.status == ConnectionStatus.CONNECTED then
    self:onServerReconnected(connectionId)
  elseif connection.status == ConnectionStatus.STALLED then
    self:onServerStalled(connectionId)
  elseif connection.status == ConnectionStatus.DISCONNECTED then
    self:onServerDisconnected(connectionId)
  end
end
