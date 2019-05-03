local enum = require "me.strangepan.libs.lua.v1.enum"

-- Enum
-- Event types; used for event registration
return enum.build(
  "DRAW",
  "PRE_STEP",
  "STEP",
  "POST_STEP",
  "PRE_PHYSICS",
  "PHYSICS",
  "POST_PHYSICS",
  "KEYBOARD_DOWN",
  "KEYBOARD_UP",
  "MOUSE_DOWN",
  "MOUSE_UP",
  "MOUSE_MOVE",
  "MOUSE_WHEEL",
  "JOYSTICK_DOWN",
  "JOYSTICK_UP",
  "JOYSTICK_ADD",
  "JOYSTICK_REMOVE",
  "WINDOW_RESIZE",
  "PRE_DRAW",
  "DESTROY",
  "SHUTDOWN")
