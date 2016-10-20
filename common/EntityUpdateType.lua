require "common/enum"

EntityUpdateType = {
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
}

buildEnum(EntityUpdateType)
