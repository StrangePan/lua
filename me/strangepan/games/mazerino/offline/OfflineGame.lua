require "me.strangepan.games.mazerino.common.Camera"
require "me.strangepan.games.mazerino.common.Game"
require "me.strangepan.games.mazerino.common.entities.Actor"
require "me.strangepan.games.mazerino.common.entities.Player"
require "me.strangepan.games.mazerino.common.entities.Switch"
require "me.strangepan.games.mazerino.common.CommandMap"
require "me.strangepan.games.mazerino.common.LocalPlayerController"
require "me.strangepan.games.mazerino.common.strangepan.secretary.Secretary"
local GameMap = require "me.strangepan.games.mazerino.common.mazerino.map.GameMap"

OfflineGame = buildClass(Game)
local Class = OfflineGame

function Class:_init(secretary)
  Class.superclass._init(self, secretary)

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

function Class:start()
  Class.superclass.start(self)
  
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

function Class:setUpLevel()
  local gameMap = GameMap.createFromFile('me/strangepan/games/mazerino/maps/offline_test.mmap')
  local secretary = self:getSecretary()

  for _,entity in ipairs(gameMap.entities) do
    entity:registerWithSecretary(secretary)

    -- Set up the player.
    if checkType(entity, Player) then
      LocalPlayerController(entity, self.commandMap)
      self.camera:setSubject(entity)
      self.camera:jumpToSubject(entity)
    end
  end

end