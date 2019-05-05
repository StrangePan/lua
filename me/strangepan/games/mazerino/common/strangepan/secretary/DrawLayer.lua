local enum = require "me.strangepan.libs.util.v1.enum"

-- Enum
-- Defines depth for drawing layers
return enum.build(
  "BACKGROUND",       -- wallpapers, scenery
  "BACKGROUND_PROPS", -- props, behind actors
  "MAIN",             -- where all the action happens
  "SPOTLIGHT",        -- only for the most important actors
  "FOREGROUND_PROPS", -- in-your-face props
  "FOREGROUND",       -- more decoration
  "HUD",              -- meters and stats and stuff
  "UI",               -- only the most important things
  "OVERLAY")          -- higher than even the menu
