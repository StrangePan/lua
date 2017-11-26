require "Game"
require "Camera"
require "entities.Actor"
require "entities.Player"
require "entities.Switch"
require "strangepan.secretary.Secretary"
require "CommandMap"
require "LocalPlayerController"

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
  local mapCodes = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 2, 0, 1, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 1, 0, 3, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  }

  local secretary = self:getSecretary()
  for mapY,row in ipairs(mapCodes) do
    for mapX,mapCode in ipairs(row) do
      local realX = (mapX - 1)
      local realY = (mapY - 1)
      
      if mapCode == 1 then
        Wall(realX, realY):registerWithSecretary(secretary)
      elseif mapCode == 2 then
        local player = Player():registerWithSecretary(secretary)
        player:setPosition(realX, realY)
        local controller = LocalPlayerController(player, self.commandMap)
        self.camera:setSubject(player)
        self.camera:jumpToSubject(player)
      elseif mapCode == 3 then
        Switch(realX, realY):registerWithSecretary(secretary)
      end
    end
  end

end