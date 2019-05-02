function love.conf(t)
  t.version = "0.10.1"
  
  t.window.title = "Connectr"
  t.window.highdpi = false
  t.window.width = 400
  t.window.height = 400
  
  t.modules.audio = false
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = false
  t.modules.joystick = false
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = false
  t.modules.physics = false
  t.modules.sound = false
  t.modules.system = true
  t.modules.timer = true
  t.modules.touch = false
  t.modules.video = false
  t.modules.window = true
  t.modules.thread = true
end
