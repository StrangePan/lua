local Camera = require "me.strangepan.games.mazerino.common.Camera"
local Game = require "me.strangepan.games.mazerino.common.Game"
local Actor = require "me.strangepan.games.mazerino.common.entities.Actor"
local Player = require "me.strangepan.games.mazerino.common.entities.Player"
local Switch = require "me.strangepan.games.mazerino.common.entities.Switch"
local CommandMap = require "me.strangepan.games.mazerino.common.CommandMap"
local CommandType = require "me.strangepan.games.mazerino.common.CommandType"
local LocalPlayerController = require "me.strangepan.games.mazerino.common.LocalPlayerController"
local Secretary = require "me.strangepan.libs.secretary.v1.Secretary"
local GameMap = require "me.strangepan.games.mazerino.common.mazerino.map.GameMap"
local class = require "me.strangepan.libs.util.v1.class"
local EventType = require "me.strangepan.libs.secretary.v1.EventType"

local OfflineGame = class.build(Game)

function OfflineGame:_init(secretary)
  Game._init(self, secretary)

  self.commandMap = CommandMap()
  local commandMap = self.commandMap
  commandMap:mapCommandToKeyboardKey(CommandType.QUIT, "escape")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_UP, "up")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_RIGHT, "right")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_DOWN, "down")
  commandMap:mapCommandToKeyboardKey(CommandType.MOVE_LEFT, "left")
  commandMap:mapCommandToKeyboardKey(CommandType.EMOTE_SPIN, "space")
  
  commandMap:registerCommandListener(CommandType.QUIT, self, function(self)
      self:stop()
      love.event.quit()
    end)
end

function OfflineGame:start()
  Game.start(self)
  
  local secretary = self:getSecretary()
  
  self.camera = Camera():registerWithSecretary(secretary)
  
  -- Hook command map up to secretary
  secretary:registerEventListener(
      self.commandMap,
      function(commandMap, key, scancode, isrepeat)
        if not isrepeat then
          commandMap:onKeyboardInput(key)
        end
      end,
      EventType.KEYBOARD_DOWN)
  
  self:setUpLevel()
  
  return self
end

function OfflineGame:setUpLevel()
  local gameMap = GameMap.createFromFile('me/strangepan/games/mazerino/maps/offline_test.mmap')
  local secretary = self:getSecretary()

  for _,entity in ipairs(gameMap.entities) do
    entity:registerWithSecretary(secretary)

    -- Set up the player.
    if class.instance_of(entity, Player) then
      LocalPlayerController(entity, self.commandMap)
      self.camera:setSubject(entity)
      self.camera:jumpToSubject(entity)
    end
  end
end

return OfflineGame
