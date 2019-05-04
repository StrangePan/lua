local enum = require "me.strangepan.libs.lua.v1.enum"

return enum.build(
  "BUNDLE",
  "CONNECT_INIT",
  "CONNECT_ACK",
  "CONNECT_ACK_ACK",
  "DISCONNECT",
  "PING",
  "ACK",
  "ACK_REQUEST",
  "ACK_REQUEST_RESET",
  "ENTITY_UPDATE")
