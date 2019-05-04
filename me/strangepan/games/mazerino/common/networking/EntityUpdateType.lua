local enum = require "me.strangepan.libs.lua.v1.enum"

return enum.build(
  -- When an entity is created, its initial state communicated.
  "CREATING",

  -- When an entity is destroyed and removed from the game.
  "DESTROYING",

  -- When the current state of an entity needs to simply be set. Can be used
  -- to declare that an entity already exists.
  "SYNCHRONIZING",

  -- When an entity incremental update is triggered, such as a player moving
  -- or a wall changing color.
  "INCREMENTING",

  -- When an entity incremental update is triggered but the processing of which
  -- does not meet expectations, this message can be used to indicate to remote
  -- entities that the local copy is out of sync.
  "OUT_OF_SYNC")
