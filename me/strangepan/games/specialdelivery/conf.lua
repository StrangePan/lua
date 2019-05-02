function love.conf(t)
  t.version = "0.10.1"
  
  t.window.title = "Special Delivery"
  t.window.highdpi = false
  t.window.width = 800
  t.window.height = 600
  
  t.modules.audio = false
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = false
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = false
  t.modules.sound = false
  t.modules.system = true
  t.modules.timer = true
  t.modules.touch = false
  t.modules.video = false
  t.modules.window = true
  t.modules.thread = true
end
